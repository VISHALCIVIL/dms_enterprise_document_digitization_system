import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/sqlite_database_service.dart';
import '../services/google_drive_service.dart';
import '../errors/failures.dart';
import '../../features/documents/domain/scanned_file_model.dart';

enum SyncStatusState { idle, syncing, offline, error, unconfigured, completed }

class SyncResult {
  final int syncedCount;
  final int failedCount;
  final String? errorMessage;
  final bool isUnconfigured;

  const SyncResult({
    required this.syncedCount,
    required this.failedCount,
    this.errorMessage,
    this.isUnconfigured = false,
  });
}

class SyncManager {
  final SqliteDatabaseService _sqlite = SqliteDatabaseService.instance;
  final GoogleDriveService _driveService;
  final FirebaseFirestore? _firestore;

  final _statusController = StreamController<SyncStatusState>.broadcast();
  Stream<SyncStatusState> get syncStatusStream => _statusController.stream;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  SyncManager({
    required GoogleDriveService driveService,
    FirebaseFirestore? firestore,
  })  : _driveService = driveService,
        _firestore = firestore;

  /// Trigger sync process. Drains SQLite pending uploads to Google Drive & Firestore.
  Future<SyncResult> syncPendingQueue({bool force = false}) async {
    if (_isSyncing) return const SyncResult(syncedCount: 0, failedCount: 0);
    _isSyncing = true;
    _statusController.add(SyncStatusState.syncing);

    int syncedCount = 0;
    int failedCount = 0;
    String? lastErrorMessage;
    bool driveUnconfigured = false;

    try {
      if (!force) {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity.contains(ConnectivityResult.none)) {
          _statusController.add(SyncStatusState.offline);
          _isSyncing = false;
          return const SyncResult(
            syncedCount: 0,
            failedCount: 0,
            errorMessage: 'Offline: No network connection available.',
          );
        }
      }

      final pendingRows = await _sqlite.getAllFiles();
      final unSyncedRows = pendingRows.where((f) => f['sync_status'] != 'FULLY_SYNCED').toList();

      if (unSyncedRows.isEmpty) {
        _statusController.add(SyncStatusState.idle);
        _isSyncing = false;
        return const SyncResult(syncedCount: 0, failedCount: 0);
      }

      for (final row in unSyncedRows) {
        final fileModel = ScannedFileModel.fromSqliteMap(row);
        try {
          await _processSingleFileSync(fileModel);
          syncedCount++;
        } catch (e) {
          failedCount++;
          if (e is GoogleDriveNotConfiguredFailure) {
            driveUnconfigured = true;
            lastErrorMessage = e.message;
          } else {
            lastErrorMessage = e.toString();
          }
        }
      }

      if (driveUnconfigured) {
        _statusController.add(SyncStatusState.unconfigured);
      } else if (failedCount > 0) {
        _statusController.add(SyncStatusState.error);
      } else {
        _statusController.add(SyncStatusState.completed);
      }

      return SyncResult(
        syncedCount: syncedCount,
        failedCount: failedCount,
        errorMessage: lastErrorMessage,
        isUnconfigured: driveUnconfigured,
      );
    } catch (e) {
      _statusController.add(SyncStatusState.error);
      return SyncResult(
        syncedCount: syncedCount,
        failedCount: failedCount,
        errorMessage: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processSingleFileSync(ScannedFileModel fileModel) async {
    try {
      // 1. Google Drive Folder Lookup & File Upload
      String driveFolderId = fileModel.googleDriveFolderId ?? '';
      if (driveFolderId.isEmpty) {
        driveFolderId = await _driveService.ensureFolderPath(
          project: fileModel.projectId,
          area: fileModel.areaId,
          department: fileModel.departmentId,
          year: DateTime.now().year.toString(),
          batch: fileModel.batchId,
        );
      }

      String driveFileId = fileModel.googleDriveFileId ?? '';
      if (driveFileId.isEmpty) {
        final localFile = File(fileModel.localPath);
        if (await localFile.exists()) {
          driveFileId = await _driveService.uploadFile(
            localFile: localFile,
            fileName: fileModel.fileName,
            folderId: driveFolderId,
          );
        } else {
          throw GoogleDriveFailure('Local file does not exist at path: ${fileModel.localPath}');
        }
      }

      // 2. Cloud Firestore Document Record Update
      final firestore = _firestore;
      if (firestore != null) {
        await firestore.collection('scanned_documents').doc(fileModel.id).set({
          ...fileModel.toSqliteMap(),
          'googleDriveFileId': driveFileId,
          'googleDriveFolderId': driveFolderId,
          'syncStatus': 'FULLY_SYNCED',
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 3. SQLite Local DB Update
      final updatedModel = fileModel.copyWith(
        googleDriveFileId: driveFileId,
        googleDriveFolderId: driveFolderId,
        uploadStatus: 'COMPLETED',
        syncStatus: 'FULLY_SYNCED',
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await _sqlite.updateFileStatus(fileModel.id, updatedModel.toSqliteMap());
    } catch (e) {
      final failedModel = fileModel.copyWith(
        uploadStatus: 'FAILED',
        syncStatus: e is GoogleDriveNotConfiguredFailure ? 'NOT_CONFIGURED' : 'SYNC_ERROR',
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _sqlite.updateFileStatus(fileModel.id, failedModel.toSqliteMap());
      rethrow;
    }
  }
}
