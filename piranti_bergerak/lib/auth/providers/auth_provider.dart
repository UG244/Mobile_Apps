import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/auth_db.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const _sessionUserIdKey = 'auth.sessionUserId';

  UserModel? _currentUser;
  bool _isLoadingSession = true;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isLoadingSession => _isLoadingSession;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_sessionUserIdKey);
    if (userId != null) {
      _currentUser = await AuthDb.instance.getUserById(userId);
      if (_currentUser == null) {
        await prefs.remove(_sessionUserIdKey);
      }
    }
    _isLoadingSession = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final user = await AuthDb.instance.getUserByCredentials(username, password);
    if (user == null) {
      return false;
    }

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionUserIdKey, user.id);
    notifyListeners();
    return true;
  }

  Future<String?> register(String username, String password) async {
    final exists = await AuthDb.instance.userExists(username);
    if (exists) {
      return 'Username sudah digunakan.';
    }

    await AuthDb.instance.insertUser(username, password, role: 'user');
    return null;
  }

  Future<void> refreshCurrentUser() async {
    final user = _currentUser;
    if (user == null) return;
    final fresh = await AuthDb.instance.getUserByCredentials(user.username, user.password);
    if (fresh != null) {
      _currentUser = fresh;
      notifyListeners();
    }
  }

  Future<String?> updateProfile({
    required String displayName,
    required String email,
    required String phone,
  }) async {
    final user = _currentUser;
    if (user == null) return 'Sesi login tidak ditemukan.';
    await AuthDb.instance.updateUserProfile(
      id: user.id,
      displayName: displayName,
      email: email,
      phone: phone,
    );
    _currentUser = UserModel(
      id: user.id,
      username: user.username,
      password: user.password,
      role: user.role,
      displayName: displayName,
      email: email,
      phone: phone,
    );
    notifyListeners();
    return null;
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;
    if (user == null) return 'Sesi login tidak ditemukan.';
    if (currentPassword != user.password) {
      return 'Password lama tidak sesuai.';
    }
    await AuthDb.instance.updateUserPassword(id: user.id, password: newPassword);
    _currentUser = UserModel(
      id: user.id,
      username: user.username,
      password: newPassword,
      role: user.role,
      displayName: user.displayName,
      email: user.email,
      phone: user.phone,
    );
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserIdKey);
    _currentUser = null;
    notifyListeners();
  }
}
