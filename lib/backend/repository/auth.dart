import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign up
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Logout
  Future<void> signOut() {
    return _auth.signOut();
  }

  /// Delete auth user
  Future<void> deleteAuthUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// UID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Required user (throws if null)
  User requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }
    return user;
  }

  /// Required UID
  String requireUserId() => requireUser().uid;

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw Exception("No authenticated user");
    }

    // 🔐 reauthenticate is REQUIRED
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);

    // 🔥 update password
    await user.updatePassword(newPassword);
  }
}
