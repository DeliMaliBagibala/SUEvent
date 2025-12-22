import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "PASTE_YOUR_API_KEY_HERE",
    appId: "PASTE_YOUR_APP_ID_HERE",
    messagingSenderId: "PASTE_YOUR_SENDER_ID_HERE",
    projectId: "suevent-3614b",
    storageBucket: "suevent-3614b.firebasestorage.app",
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: "PASTE_YOUR_API_KEY_HERE",
    appId: "PASTE_YOUR_APP_ID_HERE",
    messagingSenderId: "PASTE_YOUR_SENDER_ID_HERE",
    projectId: "suevent-3614b",
    storageBucket: "suevent-3614b.firebasestorage.app",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBF7UJqeqr7u6NlwOH0JRFPtTAzKTD92es',
    appId: '1:747790250914:android:b6e70c193186882063f8fb',
    messagingSenderId: '747790250914',
    projectId: 'suevent-3614b',
    storageBucket: 'suevent-3614b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDq4L5SUnk1881HvrCIN7_HZctOa_lApaE',
    appId: '1:747790250914:ios:a720a30834aea9f863f8fb',
    messagingSenderId: '747790250914',
    projectId: 'suevent-3614b',
    storageBucket: 'suevent-3614b.firebasestorage.app',
    iosBundleId: 'com.example.suEvent',
  );
}
