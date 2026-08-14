import 'dart:convert';
import 'package:flutter/services.dart';

class AppConfig {
  static AppConfig? _instance;

  final String googleClientId;
  final String googleClientSecret;
  final String redirectUri;
  final List<String> googleScopes;
  final String firebaseProjectId;

  AppConfig._({
    required this.googleClientId,
    required this.googleClientSecret,
    required this.redirectUri,
    required this.googleScopes,
    required this.firebaseProjectId,
  });

  static AppConfig get instance {
    if (_instance == null) {
      throw StateError('AppConfig not initialized. Call AppConfig.load() before accessing instance.');
    }
    return _instance!;
  }

  static Future<AppConfig> load() async {
    if (_instance != null) return _instance!;

    try {
      final jsonString = await rootBundle.loadString('assets/config/app_config.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      final googleMap = jsonMap['google_oauth'] as Map<String, dynamic>;
      final firebaseMap = jsonMap['firebase'] as Map<String, dynamic>;

      _instance = AppConfig._(
        googleClientId: googleMap['client_id'] as String,
        googleClientSecret: googleMap['client_secret'] as String,
        redirectUri: googleMap['redirect_uri'] as String,
        googleScopes: List<String>.from(googleMap['scopes'] as List),
        firebaseProjectId: firebaseMap['project_id'] as String,
      );

      return _instance!;
    } catch (e) {
      // Fallback placeholder configuration
      _instance = AppConfig._(
        googleClientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
        googleClientSecret: 'YOUR_GOOGLE_CLIENT_SECRET',
        redirectUri: 'http://localhost:8088/',
        googleScopes: ['https://www.googleapis.com/auth/drive.file'],
        firebaseProjectId: 'scandigitize-enterprise',
      );
      return _instance!;
    }
  }
}
