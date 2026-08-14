import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/failures.dart';

class GitHubReleaseInfo {
  final String tagName;
  final String releaseName;
  final String downloadUrl;
  final String publishedAt;

  const GitHubReleaseInfo({
    required this.tagName,
    required this.releaseName,
    required this.downloadUrl,
    required this.publishedAt,
  });
}

class GitHubService {
  static const String _storageKeyGitHubToken = 'scandigitize_github_pat_token';
  static const String repoOwner = 'VISHALCIVIL';
  static const String repoName = 'dms_enterprise_document_digitization_system';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> getSavedToken() async {
    return await _storage.read(key: _storageKeyGitHubToken);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _storageKeyGitHubToken, value: token.trim());
  }

  Map<String, String> _headers(String? token) {
    final Map<String, String> map = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'ScanDigitize-Flutter-App',
    };
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }

  /// Fetch latest release build artifact details from GitHub Releases API
  Future<GitHubReleaseInfo?> getLatestRelease() async {
    try {
      final token = await getSavedToken();
      final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
      final response = await http.get(url, headers: _headers(token));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final assets = json['assets'] as List?;
        String downloadUrl = '';
        if (assets != null && assets.isNotEmpty) {
          downloadUrl = assets.first['browser_download_url'] as String? ?? '';
        }

        return GitHubReleaseInfo(
          tagName: json['tag_name'] as String? ?? 'v1.0.0',
          releaseName: json['name'] as String? ?? 'ScanDigitize Release',
          downloadUrl: downloadUrl,
          publishedAt: json['published_at'] as String? ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Automatically create a GitHub Issue when a critical scanning batch or hardware alert fails
  Future<String> createIssueReport({
    required String title,
    required String body,
  }) async {
    final token = await getSavedToken();
    if (token == null || token.isEmpty) {
      throw const AuthFailure('GitHub Personal Access Token required to submit issue reports.');
    }

    try {
      final url = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/issues');
      final response = await http.post(
        url,
        headers: _headers(token),
        body: jsonEncode({
          'title': title,
          'body': body,
          'labels': ['bug', 'automated-alert'],
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['html_url'] as String;
      } else {
        throw AuthFailure('Failed to create GitHub issue: ${response.body}');
      }
    } catch (e) {
      throw AuthFailure('GitHub API Issue Creation Error: $e');
    }
  }
}
