import 'package:firebase_core/firebase_core.dart';

/// Firebase config supplied at build time via --dart-define (so no secret file
/// is committed). Cloud sync stays OFF until these are provided.
///
/// Get the values from Firebase console → Project settings → your Android app:
///
///   flutter run \
///     --dart-define=FIREBASE_API_KEY=... \
///     --dart-define=FIREBASE_APP_ID=1:1234:android:abcd \
///     --dart-define=FIREBASE_SENDER_ID=1234567890 \
///     --dart-define=FIREBASE_PROJECT_ID=sangam-xxxx \
///     --dart-define=FIREBASE_STORAGE_BUCKET=sangam-xxxx.appspot.com
class DefaultFirebaseOptions {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  /// True only when the minimum required keys are present.
  static bool get isConfigured =>
      _apiKey.isNotEmpty && _appId.isNotEmpty && _projectId.isNotEmpty && _senderId.isNotEmpty;

  static FirebaseOptions get currentPlatform => FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _senderId,
        projectId: _projectId,
        storageBucket: _storageBucket.isEmpty ? '$_projectId.appspot.com' : _storageBucket,
      );
}
