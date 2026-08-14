/// Scanned Document Domain Model.
/// Holds all metadata required for SQLite local queue, Google Drive API upload, and Firestore sync.
class ScannedFileModel {
  final String id;
  final String fileName;
  final String projectId;
  final String areaId;
  final String departmentId;
  final String batchId;
  final String operatorId;
  final String date; // YYYY-MM-DD
  final int timestamp;
  final int pageCount;
  final int fileSize;
  final String localPath;
  final String? googleDriveFileId;
  final String? googleDriveFolderId;
  final String ocrStatus; // PENDING, PROCESSING, COMPLETED, FAILED
  final String? ocrText;
  final String pdfStatus; // PENDING, COMPLETED, FAILED
  final String uploadStatus; // PENDING, UPLOADING, COMPLETED, FAILED
  final String syncStatus; // LOCAL_ONLY, DRIVE_SYNCED, FIREBASE_SYNCED, FULLY_SYNCED
  final int retryCount;
  final String? lastError;
  final int createdAt;
  final int updatedAt;

  const ScannedFileModel({
    required this.id,
    required this.fileName,
    required this.projectId,
    required this.areaId,
    required this.departmentId,
    required this.batchId,
    required this.operatorId,
    required this.date,
    required this.timestamp,
    required this.pageCount,
    required this.fileSize,
    required this.localPath,
    this.googleDriveFileId,
    this.googleDriveFolderId,
    required this.ocrStatus,
    this.ocrText,
    required this.pdfStatus,
    required this.uploadStatus,
    required this.syncStatus,
    this.retryCount = 0,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'file_name': fileName,
      'project_id': projectId,
      'area_id': areaId,
      'department_id': departmentId,
      'batch_id': batchId,
      'operator_id': operatorId,
      'scan_date': date,
      'timestamp': timestamp,
      'page_count': pageCount,
      'file_size': fileSize,
      'local_path': localPath,
      'google_drive_file_id': googleDriveFileId,
      'google_drive_folder_id': googleDriveFolderId,
      'ocr_status': ocrStatus,
      'ocr_text': ocrText,
      'pdf_status': pdfStatus,
      'upload_status': uploadStatus,
      'sync_status': syncStatus,
      'retry_count': retryCount,
      'last_error': lastError,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ScannedFileModel.fromSqliteMap(Map<String, dynamic> map) {
    return ScannedFileModel(
      id: map['id'] as String,
      fileName: map['file_name'] as String,
      projectId: map['project_id'] as String,
      areaId: map['area_id'] as String,
      departmentId: map['department_id'] as String,
      batchId: map['batch_id'] as String,
      operatorId: map['operator_id'] as String,
      date: map['scan_date'] as String,
      timestamp: map['timestamp'] as int,
      pageCount: map['page_count'] as int,
      fileSize: map['file_size'] as int,
      localPath: map['local_path'] as String,
      googleDriveFileId: map['google_drive_file_id'] as String?,
      googleDriveFolderId: map['google_drive_folder_id'] as String?,
      ocrStatus: map['ocr_status'] as String,
      ocrText: map['ocr_text'] as String?,
      pdfStatus: map['pdf_status'] as String,
      uploadStatus: map['upload_status'] as String,
      syncStatus: map['sync_status'] as String,
      retryCount: map['retry_count'] as int? ?? 0,
      lastError: map['last_error'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'fileName': fileName,
      'projectId': projectId,
      'areaId': areaId,
      'departmentId': departmentId,
      'batchId': batchId,
      'operatorId': operatorId,
      'date': date,
      'timestamp': timestamp,
      'pageCount': pageCount,
      'fileSize': fileSize,
      'localPath': localPath,
      'googleDriveFileId': googleDriveFileId,
      'googleDriveFolderId': googleDriveFolderId,
      'ocrStatus': ocrStatus,
      'uploadStatus': uploadStatus,
      'syncStatus': syncStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ScannedFileModel copyWith({
    String? googleDriveFileId,
    String? googleDriveFolderId,
    String? ocrStatus,
    String? ocrText,
    String? pdfStatus,
    String? uploadStatus,
    String? syncStatus,
    int? retryCount,
    String? lastError,
    int? updatedAt,
  }) {
    return ScannedFileModel(
      id: id,
      fileName: fileName,
      projectId: projectId,
      areaId: areaId,
      departmentId: departmentId,
      batchId: batchId,
      operatorId: operatorId,
      date: date,
      timestamp: timestamp,
      pageCount: pageCount,
      fileSize: fileSize,
      localPath: localPath,
      googleDriveFileId: googleDriveFileId ?? this.googleDriveFileId,
      googleDriveFolderId: googleDriveFolderId ?? this.googleDriveFolderId,
      ocrStatus: ocrStatus ?? this.ocrStatus,
      ocrText: ocrText ?? this.ocrText,
      pdfStatus: pdfStatus ?? this.pdfStatus,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
