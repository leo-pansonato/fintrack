import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    switch (auth.status) {
      case AuthStatus.authenticated:
        return const MainShell();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.checking:
        final colors = Theme.of(context).extension<AppColors>()!;
        return Scaffold(
          backgroundColor: colors.background,
          body: Center(child: CircularProgressIndicator(color: colors.accent)),
        );
    }
  }
}
