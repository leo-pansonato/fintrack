import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ChatBubble extends StatelessWidget {
  final String texto;
  final bool isUser;
  final String hora;

  const ChatBubble({
    super.key,
    required this.texto,
    required this.isUser,
    required this.hora,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.zero,
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? colors.accent : colors.card,
          borderRadius: borderRadius,
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                color: isUser ? Colors.white : colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hora,
              style: TextStyle(
                fontSize: 11,
                color: (isUser ? Colors.white : colors.textPrimary)
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
