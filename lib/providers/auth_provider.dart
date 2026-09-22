import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/app_user.dart';

enum AuthResult {
  success,
  invalidCredentials,
  emailTaken,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({DatabaseHelper? helper}) : _db = helper ?? DatabaseHelper.instance;

  static const _sessionKey = 'auth_user_id';

  final DatabaseHelper _db;

  AppUser? _user;
  bool _loading = true;
  String? _error;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> restoreSession() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt(_sessionKey);
      if (id != null) {
        _user = await _db.getUserById(id);
        if (_user == null) {
          await prefs.remove(_sessionKey);
        }
      }
    } catch (_) {
      _error = 'Could not restore your session.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _error = null;
    try {
      if (await _db.emailExists(email)) {
        return AuthResult.emailTaken;
      }
      final user = await _db.createUser(
        name: name,
        email: email,
        password: password,
      );
      await _persistSession(user);
      return AuthResult.success;
    } catch (_) {
      _error = 'Could not create your account.';
      notifyListeners();
      return AuthResult.error;
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _error = null;
    try {
      final user = await _db.authenticate(email: email, password: password);
      if (user == null) {
        return AuthResult.invalidCredentials;
      }
      await _persistSession(user);
      return AuthResult.success;
    } catch (_) {
      _error = 'Could not sign in.';
      notifyListeners();
      return AuthResult.error;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  Future<void> _persistSession(AppUser user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, user.id);
    notifyListeners();
  }
}
