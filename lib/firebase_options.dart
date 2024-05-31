// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Configure web options here if needed
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDgRChcNALF1FLt4GbJSmJM6Pa-TTBnh8U',
    appId: '1:95862460828:android:4d483bc35b50dd0994f859',
    messagingSenderId: '95862460828',
    projectId: 'pbbfirebase-15958',
    storageBucket: 'pbbfirebase-15958.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAGJdhLAoV2MAauP2UrLkQtVlRIY2jKGAo',
    appId: '1:95862460828:ios:9b046bf821703da994f859',
    messagingSenderId: '95862460828',
    projectId: 'pbbfirebase-15958',
    storageBucket: 'pbbfirebase-15958.appspot.com',
    iosBundleId: 'com.example.modernlogintute',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAGJdhLAoV2MAauP2UrLkQtVlRIY2jKGAo',
    appId: '1:95862460828:ios:9b046bf821703da994f859',
    messagingSenderId: '95862460828',
    projectId: 'pbbfirebase-15958',
    storageBucket: 'pbbfirebase-15958.appspot.com',
    iosBundleId: 'com.example.modernlogintute',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}