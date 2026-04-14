import 'package:firebase_auth/firebase_auth.dart';

import '../repository/user.dart';
import '../service/auth.dart';
import '../../models/user.dart';

class UserService {
  final UserRepository _repo = UserRepository();
  final AuthService _auth = AuthService();

  // =========================
  // AUTH HELPERS
  // =========================

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.uid;
  bool get isAuthenticated => _auth.isAuthenticated;

  /// Require logged-in user (throws if not authenticated)
  String get requireUid => _auth.requireUid;

  User get requireUser => _auth.requireUser;

  // =========================
  // CREATE USER PROFILE
  // =========================
  Future<void> createUser(UserModel user) async {
    await _repo.createUser(user.uid, user.toMap());
  }

  /// CREATE PROFILE FOR CURRENT USER
  Future<void> createCurrentUser(UserModel user) async {
    final uid = requireUid;
    await _repo.createUser(uid, user.toMap());
  }

  // =========================
  // GET USER BY UID
  // =========================
  Future<UserModel?> getUser(String uid) async {
    final data = await _repo.getUser(uid);

    if (data == null) return null;

    return UserModel.fromMap(data, uid);
  }

  /// GET CURRENT USER PROFILE (SAFE)
  Future<UserModel?> getCurrentUser() async {
    final uid = currentUid;

    print("🆔 CURRENT UID: $uid");

    if (uid == null) return null;

    final data = await _repo.getUser(uid);

    print("📦 FIRESTORE DATA: $data");

    if (data == null) return null;

    return UserModel.fromMap(data, uid);
  }

  /// GET CURRENT USER PROFILE (STRICT)
  Future<UserModel> requireCurrentUser() async {
    final uid = requireUid;

    final data = await _repo.getUser(uid);

    if (data == null) {
      throw Exception("User profile not found");
    }

    return UserModel.fromMap(data, uid);
  }

  // =========================
  // UPDATE USER PROFILE
  // =========================
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _repo.updateUser(uid, data);
  }

  /// UPDATE CURRENT USER ONLY
  Future<void> updateCurrentUser(Map<String, dynamic> data) async {
    final uid = requireUid;
    await _repo.updateUser(uid, data);
  }

  // =========================
  // DELETE USER PROFILE
  // =========================
  Future<void> deleteUser(String uid) async {
    await _repo.deleteUser(uid);
  }

  /// DELETE CURRENT USER PROFILE
  Future<void> deleteCurrentUser() async {
    final uid = requireUid;
    await _repo.deleteUser(uid);
  }

  // =========================
  // ADMIN
  // =========================
  Future<List<UserModel>> getAllUsers() async {
    final list = await _repo.getAllUsers();

    return list.map((data) {
      final uid = data['uid'] ?? '';
      return UserModel.fromMap(data, uid);
    }).toList();
  }
}
