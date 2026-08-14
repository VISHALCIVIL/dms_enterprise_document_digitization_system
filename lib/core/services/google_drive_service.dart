import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../errors/failures.dart';

class GoogleDriveNotConfiguredFailure extends Failure {
  final String errorMessage;
  const GoogleDriveNotConfiguredFailure(this.errorMessage) : super(errorMessage);
  @override
  String get message => errorMessage;
}

class DriveUploadProgress {
  final int bytesUploaded;
  final int totalBytes;
  final double progressFraction;

  const DriveUploadProgress(this.bytesUploaded, this.totalBytes, this.progressFraction);
}

class GoogleDriveService {
  drive.DriveApi? _driveApi;

  bool get isAuthenticated => _driveApi != null;

  /// Initialize Drive API client with authenticated HTTP client.
  void initializeWithClient(http.Client authenticatedClient) {
    _driveApi = drive.DriveApi(authenticatedClient);
  }

  /// Ensure hierarchical folder structure exists on Google Drive:
  /// Project/ -> Area/ -> Department/ -> Year/ -> Batch/
  Future<String> ensureFolderPath({
    required String project,
    required String area,
    required String department,
    required String year,
    required String batch,
  }) async {
    if (_driveApi == null) {
      throw const GoogleDriveNotConfiguredFailure(
        'Google Drive API Integration is not configured or authenticated. No folders or files were uploaded.',
      );
    }

    try {
      String parentId = 'root';
      final pathSegments = [project, area, department, year, batch];

      for (final segment in pathSegments) {
        parentId = await _getOrCreateFolder(segment, parentId);
      }
      return parentId;
    } catch (e) {
      if (e is GoogleDriveNotConfiguredFailure) rethrow;
      throw GoogleDriveFailure('Failed to construct Google Drive folder hierarchy: $e');
    }
  }

  Future<String> _getOrCreateFolder(String folderName, String parentId) async {
    if (_driveApi == null) {
      throw const GoogleDriveNotConfiguredFailure(
        'Google Drive API Integration is not configured or authenticated.',
      );
    }

    final query = "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName' and '$parentId' in parents and trashed = false";
    final fileList = await _driveApi!.files.list(q: query, spaces: 'drive');

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first.id!;
    }

    final folderMetadata = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [parentId];

    final createdFolder = await _driveApi!.files.create(folderMetadata);
    return createdFolder.id!;
  }

  /// Upload file to Google Drive folder with progress reporting.
  Future<String> uploadFile({
    required File localFile,
    required String fileName,
    required String folderId,
    Function(DriveUploadProgress)? onProgress,
  }) async {
    if (_driveApi == null) {
      throw const GoogleDriveNotConfiguredFailure(
        'Google Drive API Integration is not authenticated. File was NOT uploaded to Google Drive.',
      );
    }

    try {
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [folderId];

      final fileLength = await localFile.length();
      final mediaStream = localFile.openRead();

      int uploaded = 0;
      final trackingStream = mediaStream.map((chunk) {
        uploaded += chunk.length;
        onProgress?.call(DriveUploadProgress(uploaded, fileLength, uploaded / fileLength));
        return chunk;
      });

      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: drive.Media(trackingStream, fileLength),
      );

      return uploadedFile.id!;
    } catch (e) {
      if (e is GoogleDriveNotConfiguredFailure) rethrow;
      throw GoogleDriveFailure('Google Drive upload failed: $e');
    }
  }
}
