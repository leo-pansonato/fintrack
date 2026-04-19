import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _biometricEnabled = true;

  static const _nome = 'Leonardo Pansonato';
  static const _email = 'leo@email.com';

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  void _showAppearanceSheet() {
    final themeNotifier = context.read<ThemeNotifier>();
    final colors = Theme.of(context).extension<AppColors>()!;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: themeNotifier,
        child: const _AppearanceSheet(),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Em breve')));
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final currentTheme = context.watch<ThemeNotifier>().themeMode;

    const double headerBase = 180;
    const double avatarSize = 100;
    const double radius = 30;
    final topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = headerBase + topPadding;
    final double contentTop = headerHeight - radius;
    final double avatarTop = contentTop - avatarSize / 2;

    return Scaffold(
      backgroundColor: colors.gradientStart,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Gradient header
            Container(
              height: headerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.gradientStart, colors.gradientEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Content with rounded top
            Column(
              children: [
                SizedBox(height: contentTop),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(radius),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: avatarSize / 2 + 12),
                      Text(
                        _nome,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _email,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Settings
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildSettingsGroup(
                              title: 'Conta',
                              colors: colors,
                              items: [
                                _SettingsItem(
                                  icon: Icons.person_outline,
                                  title: 'Editar perfil',
                                  onTap: _showComingSoon,
                                ),
                                _SettingsItem(
                                  icon: Icons.key_outlined,
                                  title: 'Alterar senha',
                                  onTap: _showComingSoon,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSettingsGroup(
                              title: 'Preferências',
                              colors: colors,
                              items: [
                                _SettingsItem(
                                  icon: Icons.palette_outlined,
                                  title: 'Aparência',
                                  trailing: Text(
                                    _themeLabel(currentTheme),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  onTap: _showAppearanceSheet,
                                ),
                                _SettingsItem(
                                  icon: Icons.notifications_outlined,
                                  title: 'Notificações',
                                  onTap: _showComingSoon,
                                ),
                                _SettingsItem(
                                  icon: Icons.attach_money_rounded,
                                  title: 'Moeda padrão',
                                  trailing: Text(
                                    'BRL (R\$)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  onTap: _showComingSoon,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSettingsGroup(
                              title: 'Segurança',
                              colors: colors,
                              items: [
                                _SettingsItem(
                                  icon: Icons.fingerprint,
                                  title: 'Autenticação biométrica',
                                  trailing: Switch(
                                    value: _biometricEnabled,
                                    activeTrackColor: kIncomeGreen,
                                    onChanged: (v) =>
                                        setState(() => _biometricEnabled = v),
                                  ),
                                  showChevron: false,
                                  onTap: () => setState(
                                    () =>
                                        _biometricEnabled = !_biometricEnabled,
                                  ),
                                ),
                                _SettingsItem(
                                  icon: Icons.pin_outlined,
                                  title: 'Código PIN',
                                  onTap: _showComingSoon,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSettingsGroup(
                              title: 'Sobre',
                              colors: colors,
                              items: [
                                _SettingsItem(
                                  icon: Icons.description_outlined,
                                  title: 'Termos de uso',
                                  onTap: _showComingSoon,
                                ),
                                _SettingsItem(
                                  icon: Icons.shield_outlined,
                                  title: 'Política de privacidade',
                                  onTap: _showComingSoon,
                                ),
                                _SettingsItem(
                                  icon: Icons.info_outline,
                                  title: 'Versão do app',
                                  trailing: Text(
                                    '1.0.0',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  showChevron: false,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Logout button
                            GestureDetector(
                              onTap: _logout,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFFF4444),
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Sair da conta',
                                  style: TextStyle(
                                    color: Color(0xFFFF4444),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Avatar
            Positioned(
              top: avatarTop,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({
    required String title,
    required AppColors colors,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: item.onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: isLast
                        ? null
                        : Border(bottom: BorderSide(color: colors.divider)),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 22, color: colors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      if (item.trailing != null) item.trailing!,
                      if (item.showChevron && item.trailing is! Switch)
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });
}

class _AppearanceSheet extends StatelessWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final current = context.watch<ThemeNotifier>().themeMode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aparência',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildOption(context, colors, 'Claro', ThemeMode.light, current),
            _buildOption(context, colors, 'Escuro', ThemeMode.dark, current),
            _buildOption(context, colors, 'Sistema', ThemeMode.system, current),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    AppColors colors,
    String label,
    ThemeMode mode,
    ThemeMode current,
  ) {
    final isSelected = mode == current;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: colors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colors.accent)
          : Icon(Icons.circle_outlined, color: colors.textSecondary),
      onTap: () {
        context.read<ThemeNotifier>().setTheme(mode);
        Navigator.pop(context);
      },
    );
  }
}
