import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/gasto_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // Fundo azul na parte de cima
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryDark, kPrimaryBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: kBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          // Título e "Ver tudo"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Transações Recentes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: kTextDark,
                                ),
                              ),
                              Text(
                                'Ver tudo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryDark.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Filtros
                          Row(
                            children: List.generate(_filtros.length, (index) {
                              final selecionado = _filtroSelecionado == index;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _filtroSelecionado = index),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selecionado
                                        ? kPrimaryDark.withValues(alpha: 0.05)
                                        : kCardWhite,
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
                                        const Icon(
                                          Icons.arrow_upward,
                                          color: kIncomeGreen,
                                          size: 14,
                                        ),
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
                                          fontWeight: selecionado
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: selecionado
                                              ? kPrimaryDark
                                              : kTextGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 24),
                          _buildGrupo('HOJE', _gastosHoje),
                          const SizedBox(height: 20),
                          _buildGrupo('ONTEM', _gastosOntem),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrupo(String label, List<Gasto> gastos) {
    if (gastos.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kTextGrey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...gastos.map((g) => GastoCard(gasto: g)),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatarValor(_disponivel),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _valoresVisiveis = !_valoresVisiveis),
                          child: Icon(
                            _valoresVisiveis ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
              // Foto de perfil
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          // Botões de ação rápidos
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildActionButton(icon: Icons.flag_outlined, label: 'Metas'),
                _buildActionButton(
                  icon: Icons.auto_awesome_mosaic_rounded,
                  label: 'Mais',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({IconData? icon, required String label}) {
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
              if (icon != null) Icon(icon, color: kPrimaryDark, size: 20),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: kPrimaryDark,
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
