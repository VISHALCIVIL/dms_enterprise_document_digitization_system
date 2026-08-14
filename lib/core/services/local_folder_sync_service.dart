import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import '../database/sqlite_database_service.dart';
import '../../features/documents/domain/scanned_file_model.dart';

class FolderScanMetrics {
  final String mainFolderPath;
  final int totalSubfolders;
  final int totalLocalFiles;
  final int totalPagesCount;
  final int pendingSyncCount;
  final int syncedCount;

  const FolderScanMetrics({
    required this.mainFolderPath,
    required this.totalSubfolders,
    required this.totalLocalFiles,
    required this.totalPagesCount,
    required this.pendingSyncCount,
    required this.syncedCount,
  });
}

class LocalFolderSyncService {
  static const String _storageKeyMainFolder = 'scandigitize_main_folder_path';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final SqliteDatabaseService _sqlite = SqliteDatabaseService.instance;

  String? _mainFolderPath;

  String? get mainFolderPath => _mainFolderPath;

  /// Load persisted main folder path on startup.
  Future<String?> getSavedMainFolderPath() async {
    _mainFolderPath = await _storage.read(key: _storageKeyMainFolder);
    return _mainFolderPath;
  }

  /// Save main sync root directory permanently.
  Future<void> setMainFolderPath(String path) async {
    _mainFolderPath = path;
    await _storage.write(key: _storageKeyMainFolder, value: path);
    // Automatically trigger index scan of all files & subfolders inside main folder
    await scanAndIndexMainFolder();
  }

  /// Recursively scan main folder and all nested subfolders:
  /// MainFolder/ -> Project/ -> Area/ -> Department/ -> Year/ -> Batch/ -> File001.pdf
  Future<FolderScanMetrics> scanAndIndexMainFolder() async {
    final rootPath = _mainFolderPath ?? await getSavedMainFolderPath();
    if (rootPath == null || rootPath.isEmpty) {
      return const FolderScanMetrics(
        mainFolderPath: '',
        totalSubfolders: 0,
        totalLocalFiles: 0,
        totalPagesCount: 0,
        pendingSyncCount: 0,
        syncedCount: 0,
      );
    }

    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) {
      await rootDir.create(recursive: true);
    }

    int subfolderCount = 0;
    int fileCount = 0;
    int pageCountTotal = 0;

    final List<FileSystemEntity> entities = await rootDir.list(recursive: true, followLinks: false).toList();

    for (final entity in entities) {
      if (entity is Directory) {
        subfolderCount++;
      } else if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (ext == '.pdf' || ext == '.png' || ext == '.jpg' || ext == '.tiff') {
          fileCount++;
          // Estimate page count for PDFs / images if not indexed
          int pages = ext == '.pdf' ? 10 : 1; 
          pageCountTotal += pages;

          // Parse relative subfolder paths to determine hierarchy metadata
          final relative = p.relative(entity.path, from: rootPath);
          final parts = p.split(relative);

          String project = parts.length > 1 ? parts[0] : 'DefaultProject';
          String area = parts.length > 2 ? parts[1] : 'Umred';
          String dept = parts.length > 3 ? parts[2] : 'Operations';
          String batch = parts.length > 4 ? parts[4] : 'BATCH-${DateTime.now().year}-01';

          final String fileId = 'file_${entity.path.hashCode}';
          final String dateStr = DateTime.now().toString().split(' ').first;

          // Register in SQLite DB queue for Google Drive & Firestore sync
          final fileModel = ScannedFileModel(
            id: fileId,
            fileName: p.basename(entity.path),
            projectId: project,
            areaId: area,
            departmentId: dept,
            batchId: batch,
            operatorId: 'Operator_1',
            date: dateStr,
            timestamp: entity.statSync().modified.millisecondsSinceEpoch,
            pageCount: pages,
            fileSize: await entity.length(),
            localPath: entity.path,
            ocrStatus: 'COMPLETED',
            pdfStatus: 'COMPLETED',
            uploadStatus: 'PENDING',
            syncStatus: 'LOCAL_ONLY',
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          );

          await _sqlite.insertPendingFile(fileModel.toSqliteMap());
        }
      }
    }

    final dbFiles = await _sqlite.getAllFiles();
    int pending = dbFiles.where((f) => f['sync_status'] != 'FULLY_SYNCED').length;
    int synced = dbFiles.where((f) => f['sync_status'] == 'FULLY_SYNCED').length;

    return FolderScanMetrics(
      mainFolderPath: rootPath,
      totalSubfolders: subfolderCount,
      totalLocalFiles: fileCount,
      totalPagesCount: pageCountTotal,
      pendingSyncCount: pending,
      syncedCount: synced,
    );
  }
}
