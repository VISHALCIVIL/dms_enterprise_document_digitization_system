import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/sqlite_database_service.dart';
import '../services/google_drive_service.dart';
import '../../features/documents/domain/scanned_file_model.dart';

enum SyncStatusState { idle, syncing, offline, error, completed }

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
  Future<int> syncPendingQueue({bool force = false}) async {
    if (_isSyncing) return 0;
    _isSyncing = true;
    _statusController.add(SyncStatusState.syncing);

    int syncedCount = 0;

    try {
      if (!force) {
        final connectivity = await Connectivity().checkConnectivity();
        if (connectivity.contains(ConnectivityResult.none)) {
          _statusController.add(SyncStatusState.offline);
          _isSyncing = false;
          return 0;
        }
      }

      final pendingRows = await _sqlite.getAllFiles();
      final unSyncedRows = pendingRows.where((f) => f['sync_status'] != 'FULLY_SYNCED').toList();

      if (unSyncedRows.isEmpty) {
        _statusController.add(SyncStatusState.idle);
        _isSyncing = false;
        return 0;
      }

      for (final row in unSyncedRows) {
        final fileModel = ScannedFileModel.fromSqliteMap(row);
        await _processSingleFileSync(fileModel);
        syncedCount++;
      }

      _statusController.add(SyncStatusState.completed);
      return syncedCount;
    } catch (e) {
      _statusController.add(SyncStatusState.error);
      return syncedCount;
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
          driveFileId = 'gdrive_file_id_${fileModel.id}';
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
        syncStatus: 'SYNC_ERROR',
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _sqlite.updateFileStatus(fileModel.id, failedModel.toSqliteMap());
    }
  }
}
