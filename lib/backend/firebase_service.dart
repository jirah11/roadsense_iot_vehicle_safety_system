import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:roadsense_unang_hirit/models/user.dart';

/// Wrapper for Firebase Auth + Firestore operations.
///
/// This keeps Firebase logic in one place so the UI code can stay clean.
class FirebaseService {
  static firebase_auth.FirebaseAuth get auth => firebase_auth.FirebaseAuth.instance;
  static cloud_firestore.FirebaseFirestore get firestore => cloud_firestore.FirebaseFirestore.instance;

  static Future<firebase_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<firebase_auth.UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> createUserDocument(UserModel user) {
    return firestore.collection('users').doc(user.uid).set(user.toMap());
  }
}
