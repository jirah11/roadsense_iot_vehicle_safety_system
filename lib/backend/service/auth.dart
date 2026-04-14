import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth.dart';

class AuthService {
  final AuthRepository _repo = AuthRepository();

  /// LOGIN
  Future<UserCredential> login(String email, String password) {
    return _repo.signIn(email: email, password: password);
  }

  /// REGISTER
  Future<UserCredential> register(String email, String password) {
    return _repo.signUp(email: email, password: password);
  }

  /// LOGOUT
  Future<void> logout() {
    return _repo.signOut();
  }

  /// DELETE AUTH USER
  Future<void> deleteAccount() {
    return _repo.deleteAuthUser();
  }

  /// CURRENT USER
  User? get currentUser => _repo.currentUser;

  /// UID
  String? get uid => _repo.currentUserId;

  /// AUTH STATUS
  bool get isAuthenticated => _repo.currentUser != null;

  /// REQUIRED USER (safe access)
  User get requireUser => _repo.requireUser();

  /// REQUIRED UID
  String get requireUid => _repo.requireUserId();

  /// AUTH STREAM (for UI listeners)
  Stream<User?> get authState => _repo.authStateChanges;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
