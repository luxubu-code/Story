// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAhbS0OGiMeebL39nCMF2qbWLJNADmcE8s',
    appId: '1:972875575774:web:fea98f82dc885349d56d4f',
    messagingSenderId: '972875575774',
    projectId: 'story-80873',
    authDomain: 'story-80873.firebaseapp.com',
    storageBucket: 'story-80873.firebasestorage.app',
    measurementId: 'G-MJTF0JTQ69',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSC3ilZYmsxDtmCvN1zljLjM8TDmUOmh4',
    appId: '1:972875575774:android:a7c0a7a4a3ca337cd56d4f',
    messagingSenderId: '972875575774',
    projectId: 'story-80873',
    storageBucket: 'story-80873.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDAcj9YsfY0VOVqj1hI3J3CY14T43DnZHk',
    appId: '1:972875575774:ios:91de20a4b70d7dc3d56d4f',
    messagingSenderId: '972875575774',
    projectId: 'story-80873',
    storageBucket: 'story-80873.firebasestorage.app',
    androidClientId: '972875575774-8esf84dj3m9q1ml1ci1bqg7qkevcuo53.apps.googleusercontent.com',
    iosClientId: '972875575774-sf00immc5crj4hi57en6o5eop4l1fc49.apps.googleusercontent.com',
    iosBundleId: 'com.example.story',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDAcj9YsfY0VOVqj1hI3J3CY14T43DnZHk',
    appId: '1:972875575774:ios:91de20a4b70d7dc3d56d4f',
    messagingSenderId: '972875575774',
    projectId: 'story-80873',
    storageBucket: 'story-80873.firebasestorage.app',
    androidClientId: '972875575774-8esf84dj3m9q1ml1ci1bqg7qkevcuo53.apps.googleusercontent.com',
    iosClientId: '972875575774-sf00immc5crj4hi57en6o5eop4l1fc49.apps.googleusercontent.com',
    iosBundleId: 'com.example.story',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAhbS0OGiMeebL39nCMF2qbWLJNADmcE8s',
    appId: '1:972875575774:web:a304ea4eeb8ca5bbd56d4f',
    messagingSenderId: '972875575774',
    projectId: 'story-80873',
    authDomain: 'story-80873.firebaseapp.com',
    storageBucket: 'story-80873.firebasestorage.app',
    measurementId: 'G-JV1QK0P552',
  );
}
