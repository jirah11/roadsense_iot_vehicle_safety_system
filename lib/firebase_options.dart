import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC6BXYRHDpBwLt8zda54PhqT9p3zgg9O-0',
    appId: '1:944857380273:web:069b74078ea43309833990',
    messagingSenderId: '944857380273',
    projectId: 'roadsense-3b3ea',
    authDomain: 'roadsense-3b3ea.firebaseapp.com',
    storageBucket: 'roadsense-3b3ea.firebasestorage.app',
  );
}
