import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/chat_repository.dart';
import '../utils/constants.dart';
import '../widgets/chat_bubble.dart';

class _Mensagem {
  final String texto;
  final bool isUser;
  final String hora;

  _Mensagem({required this.texto, required this.isUser, required this.hora});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  final List<_Mensagem> _mensagens = [
    _Mensagem(
      texto:
          'Olá! Sou o assistente financeiro do FinTrack. Me pergunte sobre seus gastos ou peça dicas de economia!',
      isUser: false,
      hora: '10:10',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _horaAtual() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarMensagem() async {
    if (_isSending) return;

    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    if (texto.length > kChatPromptMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sua mensagem está muito longa.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _mensagens.add(_Mensagem(texto: texto, isUser: true, hora: _horaAtual()));
    });
    _controller.clear();
    FocusScope.of(context).unfocus();
    _scrollToEnd();

    try {
      final resposta = await context.read<ChatRepository>().ask(texto);

      if (!mounted) return;
      setState(() {
        _mensagens.add(
          _Mensagem(texto: resposta, isUser: false, hora: _horaAtual()),
        );
      });
    } on ChatException catch (error) {
      if (!mounted) return;
      setState(() {
        _mensagens.add(
          _Mensagem(texto: error.message, isUser: false, hora: _horaAtual()),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToEnd();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.gradientStart,
        title: const Text(
          'Atendimento IA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _mensagens.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isSending && index == _mensagens.length) {
                  return ChatBubble(
                    texto: 'Pensando...',
                    isUser: false,
                    hora: _horaAtual(),
                  );
                }

                final msg = _mensagens[index];
                return ChatBubble(
                  texto: msg.texto,
                  isUser: msg.isUser,
                  hora: msg.hora,
                );
              },
            ),
          ),
          Container(
            color: colors.card,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isSending,
                      maxLength: kChatPromptMaxLength,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _enviarMensagem(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.background,
                        hintText: 'Digite sua mensagem...',
                        counterText: '',
                        hintStyle: TextStyle(color: colors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending ? null : _enviarMensagem,
                    child: CircleAvatar(
                      backgroundColor: _isSending
                          ? colors.textSecondary.withValues(alpha: 0.4)
                          : colors.accent,
                      radius: 22,
                      child: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
