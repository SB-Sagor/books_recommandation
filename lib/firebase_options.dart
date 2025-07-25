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
    apiKey: 'AIzaSyAEBWycC8qejtnAOqRfqcGgyXm9n-Xs6-c',
    appId: '1:847366671097:web:b6b9ad10e46054e93eb028',
    messagingSenderId: '847366671097',
    projectId: 'book-store-7f85f',
    authDomain: 'book-store-7f85f.firebaseapp.com',
    storageBucket: 'book-store-7f85f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCv6zBKSscyksi5mISkzppK7pxs68OS2aU',
    appId: '1:847366671097:android:b272cc483cc2f2bd3eb028',
    messagingSenderId: '847366671097',
    projectId: 'book-store-7f85f',
    storageBucket: 'book-store-7f85f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXSil25Eq0Qbt08CPVTxxZD8jPgGxxgeQ',
    appId: '1:847366671097:ios:3c4e572cc17f47703eb028',
    messagingSenderId: '847366671097',
    projectId: 'book-store-7f85f',
    storageBucket: 'book-store-7f85f.firebasestorage.app',
    iosBundleId: 'com.example.bookStore',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAXSil25Eq0Qbt08CPVTxxZD8jPgGxxgeQ',
    appId: '1:847366671097:ios:3c4e572cc17f47703eb028',
    messagingSenderId: '847366671097',
    projectId: 'book-store-7f85f',
    storageBucket: 'book-store-7f85f.firebasestorage.app',
    iosBundleId: 'com.example.bookStore',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAEBWycC8qejtnAOqRfqcGgyXm9n-Xs6-c',
    appId: '1:847366671097:web:e350f84522a489b63eb028',
    messagingSenderId: '847366671097',
    projectId: 'book-store-7f85f',
    authDomain: 'book-store-7f85f.firebaseapp.com',
    storageBucket: 'book-store-7f85f.firebasestorage.app',
  );
}
