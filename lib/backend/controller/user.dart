import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../service/auth.dart';
import '../service/user.dart';
import '../../models/user.dart';
import 'package:roadsense_unang_hirit/models/models.dart';

class UserController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // =========================
  // STATE (single source of truth = services)
  // =========================

  User? get firebaseUser => _authService.currentUser;
  UserModel? _userModel;

  UserModel? get userModel => _userModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _authService.isAuthenticated;
  String? get uid => _authService.uid;

  // =========================
  // LOGIN
  // =========================
  Future<void> login(String email, String password) async {
    try {
      _setLoading(true);

      await _authService.login(email, password);

      // fetch profile after login
      _userModel = await _userService.getCurrentUser();

      notifyListeners();
    } catch (e) {
      throw Exception("Login failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // SIGNUP
  // =========================
  Future<void> signup({
    required String firstName,
    required String middleName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String vehicleType,
    required String vehicleNickname,
  }) async {
    try {
      _setLoading(true);

      final cred = await _authService.register(email, password);

      final newUser = UserModel(
        uid: cred.user!.uid,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now().toIso8601String(),
        vehicleType: vehicleType,
        vehicleNickname: vehicleNickname,
      );

      await _userService.createUser(newUser);

      _userModel = newUser;

      notifyListeners();
    } catch (e) {
      // 🔥 IMPORTANT: rollback auth if firestore fails
      await _authService.deleteAccount();
      throw Exception("Signup failed: $e");
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _authService.logout();

    _userModel = null;

    notifyListeners();
  }

  // =========================
  // REFRESH USER
  // =========================
  Future<void> refreshUser() async {
    print("🔄 REFRESH USER CALLED");
    _userModel = await _userService.getCurrentUser();
    print("👤 USER MODEL AFTER FETCH: $_userModel");

    notifyListeners();
  }

  // =========================
  // UPDATE PROFILE
  // =========================
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _userService.updateCurrentUser(data);
    await refreshUser();
  }

  // =========================
  // DELETE ACCOUNT
  // =========================
  Future<void> deleteAccount() async {
    await _userService.deleteCurrentUser();

    await _authService.deleteAccount();

    _userModel = null;

    notifyListeners();
  }

  // =========================
  // LOADING HELPER
  // =========================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
