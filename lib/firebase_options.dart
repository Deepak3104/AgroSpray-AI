import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError('DefaultFirebaseOptions are not configured for this platform.');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNj6aqfcu3DUhVoNlwz6uvDG-ZeNhTMSY',
    appId: '1:953045139372:android:5096bb586cc0e8b2bec409',
    messagingSenderId: '953045139372',
    projectId: 'agrospray-ai-1476a',
    storageBucket: 'agrospray-ai-1476a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    iosBundleId: 'REPLACE_WITH_IOS_BUNDLE_ID',
  );
}
