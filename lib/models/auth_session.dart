class AuthSession {
  final String accessToken;
  final int expiresIn;
  final int refreshExpiresIn;
  final String refreshToken;
  final String tokenType;
  final int notBeforePolicy;
  final String sessionState;
  final String scope;
  final DateTime createdAt;
  final DateTime? accessTokenExpiresAt;
  final DateTime? refreshTokenExpiresAt;

  const AuthSession({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.refreshToken,
    required this.tokenType,
    required this.notBeforePolicy,
    required this.sessionState,
    required this.scope,
    required this.createdAt,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
  });

  factory AuthSession.fromJson(
    Map<String, dynamic> json, {
    DateTime? issuedAt,
  }) {
    final accessToken = _readString(json['access_token']);
    final refreshToken = _readString(json['refresh_token']);
    if (accessToken == null || refreshToken == null) {
      throw const FormatException('Invalid authentication response.');
    }

    final createdAt = issuedAt ?? DateTime.now();
    final expiresIn = _readInt(json['expires_in']);
    final refreshExpiresIn = _readInt(json['refresh_expires_in']);

    return AuthSession(
      accessToken: accessToken,
      expiresIn: expiresIn,
      refreshExpiresIn: refreshExpiresIn,
      refreshToken: refreshToken,
      tokenType: _readString(json['token_type']) ?? 'Bearer',
      notBeforePolicy: _readInt(json['not-before-policy']),
      sessionState: _readString(json['session_state']) ?? '',
      scope: _readString(json['scope']) ?? '',
      createdAt: createdAt,
      accessTokenExpiresAt: expiresIn > 0
          ? createdAt.add(Duration(seconds: expiresIn))
          : null,
      refreshTokenExpiresAt: refreshExpiresIn > 0
          ? createdAt.add(Duration(seconds: refreshExpiresIn))
          : null,
    );
  }

  factory AuthSession.stored({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    required int refreshExpiresIn,
    required int notBeforePolicy,
    required String sessionState,
    required String scope,
    required DateTime createdAt,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
  }) {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      refreshExpiresIn: refreshExpiresIn,
      notBeforePolicy: notBeforePolicy,
      sessionState: sessionState,
      scope: scope,
      createdAt: createdAt,
      accessTokenExpiresAt: accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt,
    );
  }

  String get authorizationHeader => '$tokenType $accessToken';

  bool get hasAccessToken => accessToken.trim().isNotEmpty;

  bool get isAccessTokenExpired {
    final expiresAt = accessTokenExpiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  static String? _readString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
