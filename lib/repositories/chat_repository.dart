abstract class ChatRepository {
  Future<String> ask(String prompt);
  void close();
}

class ChatException implements Exception {
  final String message;

  const ChatException(this.message);

  @override
  String toString() => message;
}
