import '../models/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> restoreSession();
  Future<AuthSession> login({
    required String username,
    required String password,
  });
  Future<void> logout();
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
