import 'dart:async';
import 'dart:convert';

import '../services/api_client.dart';
import '../utils/constants.dart';
import 'chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<String> ask(String prompt) async {
    final sanitizedPrompt = prompt.trim();
    if (sanitizedPrompt.isEmpty) {
      throw const ChatException('Digite uma mensagem para continuar.');
    }
    if (sanitizedPrompt.length > kChatPromptMaxLength) {
      throw const ChatException('Sua mensagem está muito longa.');
    }

    try {
      final response = await _apiClient.postJson(
        '/ai/chat',
        body: {'prompt': sanitizedPrompt},
        timeout: kAiChatTimeout,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid chat response.');
        }

        final answer = decoded['response'];
        if (answer is! String || answer.trim().isEmpty) {
          throw const FormatException('Invalid chat response.');
        }

        return answer.trim();
      }

      throw ChatException(_messageForStatus(response.statusCode));
    } on ChatException {
      rethrow;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        throw const ChatException('Sua sessão expirou. Faça login novamente.');
      }
      throw const ChatException(
        'Não foi possível consultar a IA agora. Tente novamente.',
      );
    } on TimeoutException {
      throw const ChatException(
        'A IA demorou demais para responder. Tente novamente em instantes.',
      );
    } on FormatException {
      throw const ChatException(
        'Não foi possível interpretar a resposta da IA.',
      );
    } catch (_) {
      throw const ChatException(
        'Não foi possível consultar a IA agora. Tente novamente.',
      );
    }
  }

  @override
  void close() => _apiClient.close();

  String _messageForStatus(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return 'Sua sessão expirou. Faça login novamente.';
    }
    if (statusCode >= 500) {
      return 'A IA está indisponível no momento. Tente novamente depois.';
    }
    return 'Não foi possível consultar a IA agora. Tente novamente.';
  }
}
