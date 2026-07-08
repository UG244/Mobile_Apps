import 'package:flutter/material.dart';

import '../db/auth_db.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  Future<bool> login(String username, String password) async {
    final user = await AuthDb.instance.getUserByCredentials(username, password);
    if (user == null) {
      return false;
    }

    _currentUser = user;
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

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
