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
///
/// Replace the values below with your actual Firebase project configuration.
/// You can find these values in your Firebase project settings.
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDC47m1WDh1UKreF-tijsoMRc2o2w0jD6E',
    appId: '1:469519052412:web:your_web_app_id', // Will need to be updated when web app is created
    messagingSenderId: '469519052412',
    projectId: 'work-priority-manager',
    authDomain: 'work-priority-manager.firebaseapp.com',
    storageBucket: 'work-priority-manager.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX', // Will need to be updated when web app is created
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDC47m1WDh1UKreF-tijsoMRc2o2w0jD6E',
    appId: '1:469519052412:android:e4e9dd95054bbc0bf723f9',
    messagingSenderId: '469519052412',
    projectId: 'work-priority-manager',
    storageBucket: 'work-priority-manager.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDC47m1WDh1UKreF-tijsoMRc2o2w0jD6E',
    appId: '1:469519052412:ios:your_ios_app_id', // Will need to be updated when iOS app is created
    messagingSenderId: '469519052412',
    projectId: 'work-priority-manager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDC47m1WDh1UKreF-tijsoMRc2o2w0jD6E',
    appId: '1:469519052412:macos:your_macos_app_id', // Will need to be updated when macOS app is created
    messagingSenderId: '469519052412',
    projectId: 'work-priority-manager',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDC47m1WDh1UKreF-tijsoMRc2o2w0jD6E',
    appId: '1:469519052412:windows:your_windows_app_id', // Will need to be updated when Windows app is created
    messagingSenderId: '469519052412',
    projectId: 'work-priority-manager',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDC47m1WDh1UKreF-tijsoMRc2o2w0jD6E',
    appId: '1:469519052412:linux:your_linux_app_id', // Will need to be updated when Linux app is created
    messagingSenderId: '469519052412',
    projectId: 'work-priority-manager',
  );
}