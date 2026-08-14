import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
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
  static final GoogleDriveService instance = GoogleDriveService._internal();

  factory GoogleDriveService() => instance;

  GoogleDriveService._internal();

  static const String _storageKeyClientId = 'scandigitize_google_client_id';
  static const String _storageKeyClientSecret = 'scandigitize_google_client_secret';
  static const String _storageKeyServiceAccountJson = 'scandigitize_service_account_json';
  static const String defaultClientId = '448747097814-sa70k470t60lfh2lhok2b1h90p9jbljl.apps.googleusercontent.com';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  drive.DriveApi? _driveApi;
  String? _authenticatedUserEmail;

  bool get isAuthenticated => _driveApi != null;
  String? get authenticatedUserEmail => _authenticatedUserEmail;

  /// Load persisted credentials on startup
  Future<bool> initPersistedAuth() async {
    final jsonStr = await _storage.read(key: _storageKeyServiceAccountJson);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      return await signInWithServiceAccount(jsonStr);
    }
    return false;
  }

  Future<String> getClientId() async {
    final saved = await _storage.read(key: _storageKeyClientId);
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }
    return defaultClientId;
  }

  Future<void> setClientId(String clientId) async {
    await _storage.write(key: _storageKeyClientId, value: clientId.trim());
  }

  Future<void> setClientSecret(String clientSecret) async {
    await _storage.write(key: _storageKeyClientSecret, value: clientSecret.trim());
  }

  /// Interactive Google Sign-In handshake
  Future<bool> signInWithGoogle({String? customClientId}) async {
    try {
      final clientId = customClientId ?? await getClientId();
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: clientId.isNotEmpty ? clientId : null,
        scopes: [
          'email',
          'https://www.googleapis.com/auth/drive.file',
        ],
      );

      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account == null) return false;

      final httpClient = await googleSignIn.authenticatedClient();
      if (httpClient != null) {
        _driveApi = drive.DriveApi(httpClient);
        _authenticatedUserEmail = account.email;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate using Google Service Account JSON Key file contents
  Future<bool> signInWithServiceAccount(String serviceAccountJson) async {
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(serviceAccountJson);
      final credentials = auth.ServiceAccountCredentials.fromJson(jsonMap);
      final scopes = [drive.DriveApi.driveFileScope];

      final client = await auth.clientViaServiceAccount(credentials, scopes);
      _driveApi = drive.DriveApi(client);
      _authenticatedUserEmail = credentials.email;

      // Save key permanently for future automatic background logins
      await _storage.write(key: _storageKeyServiceAccountJson, value: serviceAccountJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Authenticate from Key File Path (.json)
  Future<bool> signInWithKeyFile(File keyFile) async {
    if (!await keyFile.exists()) return false;
    final jsonStr = await keyFile.readAsString();
    return await signInWithServiceAccount(jsonStr);
  }

  /// Manual client initialization
  void initializeWithClient(http.Client authenticatedClient, {String? email}) {
    _driveApi = drive.DriveApi(authenticatedClient);
    _authenticatedUserEmail = email ?? 'Authenticated User';
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
        'Google Drive API Integration is not authenticated. Please select your Service Account Key File (.json) or Sign In in Settings.',
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
        'Google Drive API Integration is not authenticated.',
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
