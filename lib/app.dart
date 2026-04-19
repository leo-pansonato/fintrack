import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'utils/constants.dart';

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.light.background,
        cardColor: AppColors.light.card,
        dividerColor: AppColors.light.divider,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.light.accent,
          brightness: Brightness.light,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,

          backgroundColor: AppColors.light.gradientStart,
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
        extensions: const [AppColors.light],
      ),
      darkTheme: ThemeData(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dark.background,
        cardColor: AppColors.dark.card,
        dividerColor: AppColors.dark.divider,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.dark.accent,
          brightness: Brightness.dark,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.dark.gradientStart,
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
        extensions: const [AppColors.dark],
      ),
      themeMode: context.watch<ThemeNotifier>().themeMode,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainShell(),
      },
    );
  }
}
