import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../errors/failures.dart';

/// Database Service providing local SQLite persistence for Windows & Android.
/// Enforces offline-first functionality for documents, batches, and daily stats.
class SqliteDatabaseService {
  static SqliteDatabaseService? _instance;
  static Database? _database;

  SqliteDatabaseService._();

  static SqliteDatabaseService get instance {
    _instance ??= SqliteDatabaseService._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docsDir.path, 'scandigitize_local.db');

      return await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE pending_scanned_files (
              id TEXT PRIMARY KEY,
              file_name TEXT NOT NULL,
              project_id TEXT NOT NULL,
              area_id TEXT NOT NULL,
              department_id TEXT NOT NULL,
              batch_id TEXT NOT NULL,
              operator_id TEXT NOT NULL,
              scan_date TEXT NOT NULL,
              timestamp INTEGER NOT NULL,
              page_count INTEGER NOT NULL,
              file_size INTEGER NOT NULL,
              local_path TEXT NOT NULL,
              google_drive_file_id TEXT,
              google_drive_folder_id TEXT,
              ocr_status TEXT NOT NULL,
              ocr_text TEXT,
              pdf_status TEXT NOT NULL,
              upload_status TEXT NOT NULL,
              sync_status TEXT NOT NULL,
              retry_count INTEGER DEFAULT 0,
              last_error TEXT,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE daily_local_stats (
              stat_date TEXT PRIMARY KEY,
              files_scanned INTEGER DEFAULT 0,
              pages_scanned INTEGER DEFAULT 0,
              files_uploaded INTEGER DEFAULT 0,
              pages_uploaded INTEGER DEFAULT 0,
              pending_uploads INTEGER DEFAULT 0,
              failed_uploads INTEGER DEFAULT 0,
              updated_at INTEGER NOT NULL
            )
          ''');
        },
      );
    } catch (e) {
      throw DatabaseFailure('Failed to initialize local SQLite database: $e');
    }
  }

  // --- CRUD OPERATIONS ---

  Future<int> insertPendingFile(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(
      'pending_scanned_files',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingFiles() async {
    final db = await database;
    return await db.query(
      'pending_scanned_files',
      where: 'sync_status != ?',
      whereArgs: ['FULLY_SYNCED'],
      orderBy: 'timestamp ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllFiles() async {
    final db = await database;
    return await db.query('pending_scanned_files', orderBy: 'timestamp DESC');
  }

  Future<int> updateFileStatus(String id, Map<String, dynamic> values) async {
    final db = await database;
    values['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      'pending_scanned_files',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getDailyStats(String dateStr) async {
    final db = await database;
    final results = await db.query(
      'daily_local_stats',
      where: 'stat_date = ?',
      whereArgs: [dateStr],
    );
    if (results.isNotEmpty) return results.first;

    final newRow = {
      'stat_date': dateStr,
      'files_scanned': 0,
      'pages_scanned': 0,
      'files_uploaded': 0,
      'pages_uploaded': 0,
      'pending_uploads': 0,
      'failed_uploads': 0,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    await db.insert('daily_local_stats', newRow);
    return newRow;
  }

  Future<void> incrementDailyStats({
    required String dateStr,
    int scannedFiles = 0,
    int scannedPages = 0,
    int uploadedFiles = 0,
    int uploadedPages = 0,
    int pendingUploads = 0,
    int failedUploads = 0,
  }) async {
    final db = await database;
    await getDailyStats(dateStr); // Ensures row exists
    await db.rawUpdate('''
      UPDATE daily_local_stats
      SET files_scanned = files_scanned + ?,
          pages_scanned = pages_scanned + ?,
          files_uploaded = files_uploaded + ?,
          pages_uploaded = pages_uploaded + ?,
          pending_uploads = pending_uploads + ?,
          failed_uploads = failed_uploads + ?,
          updated_at = ?
      WHERE stat_date = ?
    ''', [
      scannedFiles,
      scannedPages,
      uploadedFiles,
      uploadedPages,
      pendingUploads,
      failedUploads,
      DateTime.now().millisecondsSinceEpoch,
      dateStr,
    ]);
  }
}
