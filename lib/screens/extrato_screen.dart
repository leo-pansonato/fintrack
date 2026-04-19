import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../repositories/gasto_repository_impl.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/gasto_card.dart';

class ExtratoScreen extends StatefulWidget {
  final VoidCallback? onTransacaoRemovida;
  const ExtratoScreen({super.key, this.onTransacaoRemovida});

  @override
  State<ExtratoScreen> createState() => _ExtratoScreenState();
}

class _ExtratoScreenState extends State<ExtratoScreen> {
  List<Gasto> _gastos = [];
  bool _isLoading = true;
  final _repository = GastoRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _carregarGastos();
  }

  Future<void> _carregarGastos() async {
    try {
      final lista = await _repository.getAll();
      if (!mounted) return;
      setState(() => _gastos = lista);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _remover(Gasto gasto) async {
    await _repository.remove(gasto.id);
    setState(() => _gastos.removeWhere((g) => g.id == gasto.id));
    widget.onTransacaoRemovida?.call();
  }

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
                        formatMesAno(DateTime.now()),
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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _gastos.isEmpty
                            ? Center(
                                child: Text(
                                  'Nenhuma transação ainda.',
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                                itemCount: _gastos.length,
                                itemBuilder: (context, index) {
                                  final gasto = _gastos[index];
                                  return GastoCard(
                                    gasto: gasto,
                                    onDismissed: () => _remover(gasto),
                                  );
                                },
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
