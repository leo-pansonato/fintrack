import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class GastoCard extends StatelessWidget {
  final Gasto gasto;

  const GastoCard({super.key, required this.gasto});

  _CategoryIcon _getCategoryIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'alimentação':
        return const _CategoryIcon(icon: Icons.restaurant_rounded);
      case 'transporte':
        return const _CategoryIcon(icon: Icons.directions_car_rounded);
      case 'lazer':
        return const _CategoryIcon(icon: Icons.sports_esports_rounded);
      case 'pagamento':
        return const _CategoryIcon(icon: Icons.payments_rounded);
      default:
        return const _CategoryIcon(icon: Icons.attach_money_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = _getCategoryIcon(gasto.categoria);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardWhite,
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
              color: kBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(cat.icon, color: kAccentTeal, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gasto.titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  capitalize(gasto.categoria),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: kTextGrey,
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: kTextGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon {
  final IconData icon;

  const _CategoryIcon({required this.icon});
}
