import 'package:flutter/material.dart';

const String kAppName = 'FinTrack';

// Semantic colors (same in both themes)
const Color kExpenseRed = Color(0xFFFF6B6B);
const Color kIncomeGreen = Color(0xFF4AC28F);

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color gradientStart;
  final Color gradientEnd;
  final Color accent;

  const AppColors({
    required this.background,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.gradientStart,
    required this.gradientEnd,
    required this.accent,
  });

  static const light = AppColors(
    background: Color(0xFFF4F6FC),
    card: Colors.white,
    textPrimary: Color(0xFF1A1A2C),
    textSecondary: Color(0xFF9098B1),
    divider: Color(0xFFF0F0F5),
    gradientStart: Color(0xFF1A4592),
    gradientEnd: Color(0xFF2656AC),
    accent: Color(0xFF1A4592),
  );

  static const dark = AppColors(
    background: Color(0xFF121212),
    card: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFF0F0F5),
    textSecondary: Color(0xFF7A7A8E),
    divider: Color(0xFF2A2A2A),
    gradientStart: Color(0xFF0D2B5E),
    gradientEnd: Color(0xFF1A4592),
    accent: Color(0xFF2656AC),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? gradientStart,
    Color? gradientEnd,
    Color? accent,
  }) {
    return AppColors(
      background: background ?? this.background,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      accent: accent ?? this.accent,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}
