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
    apiKey: 'AIzaSyBcP5p_zV3fzldXq4-OGFYGjUhBMYEkFIw',
    appId: '1:657166917708:web:4dca54c0fd826e763014e9',
    messagingSenderId: '657166917708',
    projectId: 'stroy-ccd63',
    authDomain: 'stroy-ccd63.firebaseapp.com',
    storageBucket: 'stroy-ccd63.firebasestorage.app',
    measurementId: 'G-SKGZTZ65DZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCl_xDMspwT0_nMT_qo2D5HJlUvyCU39M4',
    appId: '1:657166917708:android:b482f32c16a7d6753014e9',
    messagingSenderId: '657166917708',
    projectId: 'stroy-ccd63',
    storageBucket: 'stroy-ccd63.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDKFIiEuUYp66m5Q-IvJynORufZ4mrC-Lw',
    appId: '1:657166917708:ios:3bb91759b4a4a4223014e9',
    messagingSenderId: '657166917708',
    projectId: 'stroy-ccd63',
    storageBucket: 'stroy-ccd63.firebasestorage.app',
    androidClientId: '657166917708-dgguidn4dq0gvere4bco87nnue7ap798.apps.googleusercontent.com',
    iosClientId: '657166917708-eilbvodsn4go5tr9avo4esg3qhp1387p.apps.googleusercontent.com',
    iosBundleId: 'com.example.story',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDKFIiEuUYp66m5Q-IvJynORufZ4mrC-Lw',
    appId: '1:657166917708:ios:3bb91759b4a4a4223014e9',
    messagingSenderId: '657166917708',
    projectId: 'stroy-ccd63',
    storageBucket: 'stroy-ccd63.firebasestorage.app',
    androidClientId: '657166917708-dgguidn4dq0gvere4bco87nnue7ap798.apps.googleusercontent.com',
    iosClientId: '657166917708-eilbvodsn4go5tr9avo4esg3qhp1387p.apps.googleusercontent.com',
    iosBundleId: 'com.example.story',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBcP5p_zV3fzldXq4-OGFYGjUhBMYEkFIw',
    appId: '1:657166917708:web:f65d8e369fd5a9023014e9',
    messagingSenderId: '657166917708',
    projectId: 'stroy-ccd63',
    authDomain: 'stroy-ccd63.firebaseapp.com',
    storageBucket: 'stroy-ccd63.firebasestorage.app',
    measurementId: 'G-HS86KCYDJ5',
  );

}