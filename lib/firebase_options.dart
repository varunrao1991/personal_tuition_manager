import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDrVKmMUsixEHpMQF4Hpn50t8lVWlSM25E',
    appId: '1:487917746282:web:0abaa3b70518874535b213',
    messagingSenderId: '487917746282',
    projectId: 'padmayoga-dc0be',
    authDomain: 'padmayoga-dc0be.firebaseapp.com',
    storageBucket: 'padmayoga-dc0be.appspot.com',
    measurementId: 'G-RNBHZLZ56F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxDP-0M8FutFClCFdzk7oKPC1YSni9qOY',
    appId: '1:487917746282:android:dc3b9bba51eb7a6c35b213',
    messagingSenderId: '487917746282',
    projectId: 'padmayoga-dc0be',
    storageBucket: 'padmayoga-dc0be.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYblHUfCagz6pBE4qIPaGJfTQxlf_zd84',
    appId: '1:487917746282:ios:2d43c12dce91a83d35b213',
    messagingSenderId: '487917746282',
    projectId: 'padmayoga-dc0be',
    storageBucket: 'padmayoga-dc0be.appspot.com',
    iosClientId:
        '487917746282-b4c0tfk0nvd9o0eundj1pjb6te6jnpgk.apps.googleusercontent.com',
    iosBundleId: 'com.padmayoga.yoglogonline',
  );
}
