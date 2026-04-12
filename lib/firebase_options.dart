import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions no están configuradas para web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no están configuradas para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5zjfyY2XDN_K2hcLMkMutDOXq9bpNlfM',
    appId: '1:518924542610:android:91a5c1ddd22d22431c3c4b',
    messagingSenderId: '518924542610',
    projectId: 'fitcoach-6c929',
    storageBucket: 'fitcoach-6c929.firebasestorage.app',
  );
}
