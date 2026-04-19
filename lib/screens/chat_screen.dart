import 'dart:async';

import 'package:flutter/material.dart';

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

  void _enviarMensagem() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensagens.add(_Mensagem(texto: texto, isUser: true, hora: _horaAtual()));
    });
    _controller.clear();
    _scrollToEnd();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _mensagens.add(
          _Mensagem(
            texto: 'Não funciona kk',
            isUser: false,
            hora: _horaAtual(),
          ),
        );
      });
      _scrollToEnd();
    });
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
              itemCount: _mensagens.length,
              itemBuilder: (context, index) {
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
                      onSubmitted: (_) => _enviarMensagem(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.background,
                        hintText: 'Digite sua mensagem...',
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
                    onTap: _enviarMensagem,
                    child: CircleAvatar(
                      backgroundColor: colors.accent,
                      radius: 22,
                      child: const Icon(
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
