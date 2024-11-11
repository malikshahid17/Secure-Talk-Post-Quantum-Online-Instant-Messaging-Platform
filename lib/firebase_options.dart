// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9r1cs0rzAMKkaTOmuCdPg3U7NkFdUeLQ',
    appId: '1:833464718760:android:75beb7a3ce72aeb1d6f99d',
    messagingSenderId: '833464718760',
    projectId: 'chatapp-f66fa',
    databaseURL: 'https://chatapp-f66fa-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chatapp-f66fa.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCai_Kr_atVF9GsE-9tr81w1TPNhCiguCU',
    appId: '1:833464718760:ios:5ebb4cd30e17b9d7d6f99d',
    messagingSenderId: '833464718760',
    projectId: 'chatapp-f66fa',
    databaseURL: 'https://chatapp-f66fa-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chatapp-f66fa.appspot.com',
    iosClientId: '833464718760-l0odhsrk7si3roq3nj5c6abo3um1ai7f.apps.googleusercontent.com',
    iosBundleId: 'com.harshRajpurohit.weChat',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDFIlWzOUXM8mbRaShOOMJxmZKmXpZCvS4',
    appId: '1:833464718760:web:7691f2f7dbf34cc4d6f99d',
    messagingSenderId: '833464718760',
    projectId: 'chatapp-f66fa',
    authDomain: 'chatapp-f66fa.firebaseapp.com',
    databaseURL: 'https://chatapp-f66fa-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'chatapp-f66fa.appspot.com',
    measurementId: 'G-B6TJFF3HBF',
  );

}