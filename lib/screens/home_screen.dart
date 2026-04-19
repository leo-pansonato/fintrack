import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/gasto_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;

  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _filtroSelecionado = 0;
  bool _valoresVisiveis = true;

  static const double _disponivel = 752.20;

  final _filtros = const ['Todos', 'Receita', 'Despesa'];

  late final DateTime _hoje;
  late final DateTime _ontem;
  late final List<Gasto> _gastos;

  @override
  void initState() {
    super.initState();
    _hoje = DateTime.now();
    _ontem = _hoje.subtract(const Duration(days: 1));
    _gastos = [
      Gasto(
        titulo: 'Supermercado',
        valor: -50.68,
        categoria: 'alimentação',
        data: _hoje,
      ),
      Gasto(titulo: 'Uber', valor: -6.00, categoria: 'transporte', data: _hoje),
      Gasto(titulo: 'Netflix', valor: -39.90, categoria: 'lazer', data: _hoje),
      Gasto(
        titulo: 'Pagamento recebido',
        valor: 650.00,
        categoria: 'pagamento',
        data: _ontem,
      ),
      Gasto(
        titulo: 'Almoço',
        valor: -32.50,
        categoria: 'alimentação',
        data: _ontem,
      ),
    ];
  }

  List<Gasto> get _gastosHoje =>
      _gastos.where((g) => isSameDay(g.data, _hoje)).toList();
  List<Gasto> get _gastosOntem =>
      _gastos.where((g) => isSameDay(g.data, _ontem)).toList();

  String _formatarValor(double valor) =>
      _valoresVisiveis ? formatBRL(valor) : kValorOculto;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            toolbarHeight: 90.0,
            pinned: true,
            elevation: 0,
            backgroundColor: colors.gradientStart,
            titleSpacing: 24.0,
            title: _buildAppBarTitle(colors),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.gradientStart, colors.gradientEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: FlexibleSpaceBar(
                background: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: 50.0,
                      ),
                      child: Row(
                        spacing: 12,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildActionButton(
                            icon: Icons.flag_outlined,
                            label: 'Metas',
                            colors: colors,
                          ),
                          _buildActionButton(
                            icon: Icons.auto_awesome_mosaic_rounded,
                            label: 'Mais',
                            colors: colors,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: colors.background,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transações Recentes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Ver tudo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.accent.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFiltros(colors),
                    const SizedBox(height: 24),
                    _buildGrupo('HOJE', _gastosHoje, colors),
                    const SizedBox(height: 20),
                    _buildGrupo('ONTEM', _gastosOntem, colors),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros(AppColors colors) {
    return Row(
      children: List.generate(_filtros.length, (index) {
        final selecionado = _filtroSelecionado == index;
        return GestureDetector(
          onTap: () => setState(() => _filtroSelecionado = index),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selecionado
                  ? colors.accent.withValues(alpha: 0.05)
                  : colors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: selecionado
                    ? Colors.transparent
                    : Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index == 1) ...[
                  const Icon(Icons.arrow_upward, color: kIncomeGreen, size: 14),
                  const SizedBox(width: 4),
                ] else if (index == 2) ...[
                  const Icon(
                    Icons.arrow_downward,
                    color: kExpenseRed,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  _filtros[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selecionado ? FontWeight.w600 : FontWeight.w500,
                    color: selecionado ? colors.accent : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGrupo(String label, List<Gasto> gastos, AppColors colors) {
    if (gastos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...gastos.map((g) => GastoCard(gasto: g)),
      ],
    );
  }

  Widget _buildAppBarTitle(AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    _formatarValor(_disponivel),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _valoresVisiveis = !_valoresVisiveis),
                    child: Icon(
                      _valoresVisiveis
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 22,
                    ),
                  ),
                ],
              ),
              Text(
                'Gastos Disponíveis',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: widget.onProfileTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    required String label,
    required AppColors colors,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              if (icon != null) Icon(icon, color: colors.accent, size: 20),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: colors.accent,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
