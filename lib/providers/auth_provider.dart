import 'package:flutter/material.dart';

import '../models/auth_session.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.checking;
  AuthSession? _session;
  bool _isLoggingIn = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isChecking => _status == AuthStatus.checking;
  bool get isLoggingIn => _isLoggingIn;
  String? get errorMessage => _errorMessage;
  String? get accessToken => _session?.accessToken;

  Future<void> restoreSession() async {
    _status = AuthStatus.checking;
    notifyListeners();

    final session = await _repository.restoreSession();
    _session = session;
    _status = session == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;

    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    if (_isLoggingIn) return false;

    _isLoggingIn = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _repository.login(
        username: username,
        password: password,
      );
      _status = AuthStatus.authenticated;
      return true;
    } on AuthException catch (error) {
      _session = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = error.message;
      return false;
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _session = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
}
