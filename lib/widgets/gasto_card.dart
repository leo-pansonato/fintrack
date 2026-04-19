import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class GastoCard extends StatelessWidget {
  final Gasto gasto;

  const GastoCard({super.key, required this.gasto});

  IconData _getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'alimentação':
        return Icons.restaurant_rounded;
      case 'transporte':
        return Icons.directions_car_rounded;
      case 'lazer':
        return Icons.sports_esports_rounded;
      case 'pagamento':
        return Icons.payments_rounded;
      default:
        return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final icon = _getCategoryIcon(gasto.categoria);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colors.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gasto.titulo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  capitalize(gasto.categoria),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatBRLSigned(gasto.valor),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: gasto.valor >= 0 ? kIncomeGreen : kExpenseRed,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatDataCurta(gasto.data),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
