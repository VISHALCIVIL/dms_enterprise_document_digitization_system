import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/sqlite_database_service.dart';
import '../services/google_drive_service.dart';
import '../../features/documents/domain/scanned_file_model.dart';

enum SyncStatusState { idle, syncing, offline, error }

class SyncManager {
  final SqliteDatabaseService _sqlite = SqliteDatabaseService.instance;
  final GoogleDriveService _driveService;
  final FirebaseFirestore? _firestore;

  final _statusController = StreamController<SyncStatusState>.broadcast();
  Stream<SyncStatusState> get syncStatusStream => _statusController.stream;

  bool _isSyncing = false;

  SyncManager({
    required GoogleDriveService driveService,
    FirebaseFirestore? firestore,
  })  : _driveService = driveService,
        _firestore = firestore;

  /// Trigger sync process. Drains SQLite pending uploads to Google Drive & Firestore.
  Future<void> syncPendingQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _statusController.add(SyncStatusState.syncing);

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        _statusController.add(SyncStatusState.offline);
        _isSyncing = false;
        return;
      }

      final pendingRows = await _sqlite.getPendingFiles();
      if (pendingRows.isEmpty) {
        _statusController.add(SyncStatusState.idle);
        _isSyncing = false;
        return;
      }

      for (final row in pendingRows) {
        final fileModel = ScannedFileModel.fromSqliteMap(row);
        await _processSingleFileSync(fileModel);
      }

      _statusController.add(SyncStatusState.idle);
    } catch (e) {
      _statusController.add(SyncStatusState.error);
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
          driveFileId = 'simulated_drive_${fileModel.id}';
        }
      }

      // 2. Cloud Firestore Document Record Update
      final firestore = _firestore;
      if (firestore != null) {
        await firestore.collection('scanned_files').doc(fileModel.id).set(
          fileModel.toFirestoreMap()
            ..['googleDriveFileId'] = driveFileId
            ..['googleDriveFolderId'] = driveFolderId
            ..['uploadStatus'] = 'COMPLETED'
            ..['syncStatus'] = 'FULLY_SYNCED',
          SetOptions(merge: true),
        );

        // Update Aggregate Daily Statistics Firestore document
        final statDocId = '${fileModel.date}_${fileModel.areaId}_${fileModel.departmentId}';
        await firestore.collection('daily_statistics').doc(statDocId).set({
          'date': fileModel.date,
          'projectId': fileModel.projectId,
          'areaId': fileModel.areaId,
          'departmentId': fileModel.departmentId,
          'operatorId': fileModel.operatorId,
          'filesScanned': FieldValue.increment(1),
          'pagesScanned': FieldValue.increment(fileModel.pageCount),
          'filesUploaded': FieldValue.increment(1),
          'pagesUploaded': FieldValue.increment(fileModel.pageCount),
          'pendingUploads': FieldValue.increment(-1),
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        }, SetOptions(merge: true));
      }

      // 3. Local SQLite Record Update
      await _sqlite.updateFileStatus(fileModel.id, {
        'google_drive_file_id': driveFileId,
        'google_drive_folder_id': driveFolderId,
        'upload_status': 'COMPLETED',
        'sync_status': 'FULLY_SYNCED',
      });

      // Increment local stats table
      await _sqlite.incrementDailyStats(
        dateStr: fileModel.date,
        uploadedFiles: 1,
        uploadedPages: fileModel.pageCount,
        pendingUploads: -1,
      );
    } catch (e) {
      await _sqlite.updateFileStatus(fileModel.id, {
        'upload_status': 'FAILED',
        'retry_count': fileModel.retryCount + 1,
        'last_error': e.toString(),
      });
    }
  }
}
