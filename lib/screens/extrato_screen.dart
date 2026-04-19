import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/gasto_card.dart';

class ExtratoScreen extends StatelessWidget {
  const ExtratoScreen({super.key});

  static final _hoje = DateTime.now();
  static final _ontem = DateTime.now().subtract(const Duration(days: 1));

  static final List<Gasto> _gastos = [
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.gradientStart, colors.gradientEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Extrato',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMesAno(_hoje),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      itemCount: _gastos.length,
                      itemBuilder: (context, index) =>
                          GastoCard(gasto: _gastos[index]),
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
}
