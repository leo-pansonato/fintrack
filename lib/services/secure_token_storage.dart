import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_session.dart';

class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _tokenTypeKey = 'auth.token_type';
  static const _expiresInKey = 'auth.expires_in';
  static const _refreshExpiresInKey = 'auth.refresh_expires_in';
  static const _notBeforePolicyKey = 'auth.not_before_policy';
  static const _sessionStateKey = 'auth.session_state';
  static const _scopeKey = 'auth.scope';
  static const _createdAtKey = 'auth.created_at';
  static const _accessExpiresAtKey = 'auth.access_expires_at';
  static const _refreshExpiresAtKey = 'auth.refresh_expires_at';

  final FlutterSecureStorage _storage;

  Future<void> saveSession(AuthSession session) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: session.accessToken),
      _storage.write(key: _refreshTokenKey, value: session.refreshToken),
      _storage.write(key: _tokenTypeKey, value: session.tokenType),
      _storage.write(key: _expiresInKey, value: session.expiresIn.toString()),
      _storage.write(
        key: _refreshExpiresInKey,
        value: session.refreshExpiresIn.toString(),
      ),
      _storage.write(
        key: _notBeforePolicyKey,
        value: session.notBeforePolicy.toString(),
      ),
      _storage.write(key: _sessionStateKey, value: session.sessionState),
      _storage.write(key: _scopeKey, value: session.scope),
      _storage.write(
        key: _createdAtKey,
        value: session.createdAt.toIso8601String(),
      ),
      if (session.accessTokenExpiresAt != null)
        _storage.write(
          key: _accessExpiresAtKey,
          value: session.accessTokenExpiresAt!.toIso8601String(),
        ),
      if (session.refreshTokenExpiresAt != null)
        _storage.write(
          key: _refreshExpiresAtKey,
          value: session.refreshTokenExpiresAt!.toIso8601String(),
        ),
    ]);
  }

  Future<AuthSession?> readSession() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken == null || accessToken.trim().isEmpty) return null;

    final values = await Future.wait([
      _storage.read(key: _refreshTokenKey),
      _storage.read(key: _tokenTypeKey),
      _storage.read(key: _expiresInKey),
      _storage.read(key: _refreshExpiresInKey),
      _storage.read(key: _notBeforePolicyKey),
      _storage.read(key: _sessionStateKey),
      _storage.read(key: _scopeKey),
      _storage.read(key: _createdAtKey),
      _storage.read(key: _accessExpiresAtKey),
      _storage.read(key: _refreshExpiresAtKey),
    ]);

    final createdAt = DateTime.tryParse(values[7] ?? '') ?? DateTime.now();

    return AuthSession.stored(
      accessToken: accessToken,
      refreshToken: values[0] ?? '',
      tokenType: values[1] ?? 'Bearer',
      expiresIn: int.tryParse(values[2] ?? '') ?? 0,
      refreshExpiresIn: int.tryParse(values[3] ?? '') ?? 0,
      notBeforePolicy: int.tryParse(values[4] ?? '') ?? 0,
      sessionState: values[5] ?? '',
      scope: values[6] ?? '',
      createdAt: createdAt,
      accessTokenExpiresAt: DateTime.tryParse(values[8] ?? ''),
      refreshTokenExpiresAt: DateTime.tryParse(values[9] ?? ''),
    );
  }

  Future<String?> readAuthorizationHeader() async {
    final session = await readSession();
    if (session == null || !session.hasAccessToken) return null;
    if (session.isAccessTokenExpired) {
      await clear();
      return null;
    }
    return session.authorizationHeader;
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _tokenTypeKey),
      _storage.delete(key: _expiresInKey),
      _storage.delete(key: _refreshExpiresInKey),
      _storage.delete(key: _notBeforePolicyKey),
      _storage.delete(key: _sessionStateKey),
      _storage.delete(key: _scopeKey),
      _storage.delete(key: _createdAtKey),
      _storage.delete(key: _accessExpiresAtKey),
      _storage.delete(key: _refreshExpiresAtKey),
    ]);
  }
}
