import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../repositories/gasto_repository_impl.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/gasto_card.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final VoidCallback? onProfileTap;
  final VoidCallback? onTransacaoRemovida;

  const HomeScreen({super.key, required this.userId, this.onProfileTap, this.onTransacaoRemovida});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _filtroSelecionado = 0;
  bool _valoresVisiveis = true;
  bool _isLoading = true;
  List<Gasto> _gastos = [];
  final _repository = GastoRepositoryImpl();

  final _filtros = const ['Todos', 'Receita', 'Despesa'];

  static const _meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  String get _mesAtual {
    final now = DateTime.now();
    return '${_meses[now.month - 1]} de ${now.year}';
  }

  String get _saudacao {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia,';
    if (h < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }

  double get _totalReceitas {
    final now = DateTime.now();
    return _gastos
        .where((g) => g.valor > 0 && g.data.year == now.year && g.data.month == now.month)
        .fold(0.0, (sum, g) => sum + g.valor);
  }

  double get _totalDespesas {
    final now = DateTime.now();
    return _gastos
        .where((g) => g.valor < 0 && g.data.year == now.year && g.data.month == now.month)
        .fold(0.0, (sum, g) => sum + g.valor.abs());
  }

  @override
  void initState() {
    super.initState();
    _carregarGastos();
  }

  Future<void> _carregarGastos() async {
    try {
      final lista = await _repository.getAll(widget.userId);
      if (!mounted) return;
      setState(() => _gastos = lista);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _remover(Gasto gasto) async {
    await _repository.remove(gasto.id);
    widget.onTransacaoRemovida?.call();
  }

  List<Gasto> get _gastosFiltrados {
    if (_filtroSelecionado == 0) return _gastos;
    if (_filtroSelecionado == 1) return _gastos.where((g) => g.valor > 0).toList();
    return _gastos.where((g) => g.valor < 0).toList();
  }

  Map<String, List<Gasto>> _agruparPorData(List<Gasto> gastos) {
    final hoje = DateTime.now();
    final ontem = hoje.subtract(const Duration(days: 1));
    final Map<String, List<Gasto>> grupos = {};
    for (final g in gastos) {
      final String label;
      if (isSameDay(g.data, hoje)) {
        label = 'HOJE';
      } else if (isSameDay(g.data, ontem)) {
        label = 'ONTEM';
      } else {
        label = formatDataCurta(g.data).toUpperCase();
      }
      grupos.putIfAbsent(label, () => []).add(g);
    }
    return grupos;
  }

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
            expandedHeight: 280.0,
            toolbarHeight: 70.0,
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
                        bottom: 48.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _mesAtual,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  label: 'Receitas',
                                  valor: _totalReceitas,
                                  icon: Icons.arrow_upward_rounded,
                                  iconColor: kIncomeGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  label: 'Despesas',
                                  valor: _totalDespesas,
                                  icon: Icons.arrow_downward_rounded,
                                  iconColor: kExpenseRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 8,
                              children: [
                                _buildActionButton(
                                  icon: Icons.flag_outlined,
                                  label: 'Metas',
                                  colors: colors,
                                ),
                                _buildActionButton(
                                  icon: Icons.bar_chart_rounded,
                                  label: 'Relatório',
                                  colors: colors,
                                ),
                                _buildActionButton(
                                  icon: Icons.event_repeat_rounded,
                                  label: 'Agendados',
                                  colors: colors,
                                ),
                              ],
                            ),
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
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_gastosFiltrados.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'Nenhuma transação encontrada.',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ..._agruparPorData(_gastosFiltrados).entries.map(
                        (entry) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGrupo(entry.key, entry.value, colors),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
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
                  const Icon(Icons.arrow_downward, color: kExpenseRed, size: 14),
                  const SizedBox(width: 4),
                ],
                Text(
                  _filtros[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selecionado ? FontWeight.w600 : FontWeight.w500,
                    color:
                        selecionado ? colors.accent : colors.textSecondary,
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
        ...gastos.map(
          (g) => GastoCard(gasto: g, onDismissed: () => _remover(g)),
        ),
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
              Text(
                _saudacao,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Leonardo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                      color: Colors.white.withValues(alpha: 0.55),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: widget.onProfileTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double valor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatarValor(valor),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
