import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/auth_session.dart';
import '../services/api_client.dart';
import '../services/secure_token_storage.dart';
import '../utils/constants.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureTokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final SecureTokenStorage _tokenStorage;

  @override
  Future<AuthSession?> restoreSession() async {
    final session = await _tokenStorage.readSession();
    if (session == null || !session.hasAccessToken) return null;

    if (session.isAccessTokenExpired) {
      await _tokenStorage.clear();
      return null;
    }

    return session;
  }

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final sistemaId = dotenv.env[kAuthSistemaIdEnvKey]?.trim();
    if (sistemaId == null || sistemaId.isEmpty) {
      throw const AuthException(
        'Configuração de autenticação ausente. Verifique o arquivo .env.',
      );
    }

    try {
      final response = await _apiClient.postJson(
        '/auth/login',
        authenticated: false,
        body: {
          'username': username.trim(),
          'password': password,
          'sistemaId': sistemaId,
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid authentication response.');
        }

        final session = AuthSession.fromJson(decoded);
        await _tokenStorage.saveSession(session);
        return session;
      }

      throw AuthException(_messageForStatus(response.statusCode));
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw const AuthException(
        'A conexão demorou demais. Tente novamente em instantes.',
      );
    } on FormatException {
      throw const AuthException(
        'Não foi possível interpretar a resposta do servidor.',
      );
    } catch (_) {
      throw const AuthException(
        'Não foi possível entrar agora. Verifique sua conexão e tente novamente.',
      );
    }
  }

  @override
  Future<void> logout() => _tokenStorage.clear();

  String _messageForStatus(int statusCode) {
    if (statusCode == 400) {
      return 'Confira usuário e senha antes de tentar novamente.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'Usuário ou senha inválidos.';
    }
    if (statusCode >= 500) {
      return 'O servidor está indisponível no momento. Tente novamente depois.';
    }
    return 'Não foi possível entrar. Tente novamente.';
  }
}
