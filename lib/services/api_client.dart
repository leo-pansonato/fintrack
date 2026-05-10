import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'secure_token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required SecureTokenStorage tokenStorage,
    http.Client? client,
    Uri? baseUri,
  }) : _tokenStorage = tokenStorage,
       _client = client ?? http.Client(),
       _baseUri = baseUri ?? Uri.parse(kApiBaseUrl);

  final SecureTokenStorage _tokenStorage;
  final http.Client _client;
  final Uri _baseUri;

  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<http.Response> postJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      'POST',
      path,
      body: body,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<http.Response> putJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      'PUT',
      path,
      body: body,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      'DELETE',
      path,
      headers: headers,
      authenticated: authenticated,
    );
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      ...?headers,
    };

    if (authenticated) {
      final authorizationHeader = await _tokenStorage.readAuthorizationHeader();
      if (authorizationHeader == null || authorizationHeader.trim().isEmpty) {
        throw const ApiException(
          'Sua sessão expirou. Faça login novamente.',
          statusCode: 401,
        );
      }
      requestHeaders['Authorization'] = authorizationHeader;
    }

    final uri = _resolve(path, queryParameters);
    final encodedBody = body == null ? null : jsonEncode(body);

    return switch (method) {
      'GET' => _client.get(uri, headers: requestHeaders).timeout(kApiTimeout),
      'POST' =>
        _client
            .post(uri, headers: requestHeaders, body: encodedBody)
            .timeout(kApiTimeout),
      'PUT' =>
        _client
            .put(uri, headers: requestHeaders, body: encodedBody)
            .timeout(kApiTimeout),
      'DELETE' =>
        _client.delete(uri, headers: requestHeaders).timeout(kApiTimeout),
      _ => throw ApiException('Método HTTP não suportado: $method'),
    };
  }

  Uri _resolve(String path, Map<String, String>? queryParameters) {
    final base = _baseUri.toString().endsWith('/')
        ? _baseUri
        : Uri.parse('${_baseUri.toString()}/');
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = base.resolve(normalizedPath);

    if (queryParameters == null || queryParameters.isEmpty) return uri;

    return uri.replace(
      queryParameters: {...uri.queryParameters, ...queryParameters},
    );
  }

  void close() => _client.close();
}
