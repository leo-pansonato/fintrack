import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../repositories/gasto_repository_impl.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class NovaTransacaoScreen extends StatefulWidget {
  const NovaTransacaoScreen({super.key});

  @override
  State<NovaTransacaoScreen> createState() => _NovaTransacaoScreenState();
}

class _NovaTransacaoScreenState extends State<NovaTransacaoScreen> {
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();
  final _repository = GastoRepositoryImpl();

  bool _isDespesa = true;
  String? _categoriaSelecionada;
  DateTime _data = DateTime.now();
  bool _isLoading = false;

  static const _categorias = [
    'alimentação',
    'transporte',
    'lazer',
    'pagamento',
    'outros',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final titulo = _tituloController.text.trim();
    final valorText = _valorController.text.trim().replaceAll(',', '.');

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o título da transação.')),
      );
      return;
    }

    final valorParsed = double.tryParse(valorText);
    if (valorParsed == null || valorParsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido maior que zero.')),
      );
      return;
    }

    if (_categoriaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma categoria.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final gasto = Gasto(
      titulo: titulo,
      valor: _isDespesa ? -valorParsed : valorParsed,
      categoria: _categoriaSelecionada!,
      data: _data,
    );

    try {
      await _repository.add(gasto);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar. Tente novamente.')),
      );
    }
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _data = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: colors.gradientStart,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 220 + topPadding,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.gradientStart, colors.gradientEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: topPadding + 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _isDespesa
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isDespesa ? 'Nova Despesa' : 'Nova Receita',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registre uma transação',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height - 220 - topPadding + 30,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Toggle Despesa/Receita
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isDespesa = true),
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _isDespesa
                                        ? kExpenseRed
                                        : colors.card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isDespesa
                                          ? kExpenseRed
                                          : colors.divider,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Despesa',
                                    style: TextStyle(
                                      color: _isDespesa
                                          ? Colors.white
                                          : colors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isDespesa = false),
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: !_isDespesa
                                        ? kIncomeGreen
                                        : colors.card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !_isDespesa
                                          ? kIncomeGreen
                                          : colors.divider,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Receita',
                                    style: TextStyle(
                                      color: !_isDespesa
                                          ? Colors.white
                                          : colors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Título', colors),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _tituloController,
                          hint: 'Ex: Supermercado',
                          icon: Icons.description_outlined,
                          colors: colors,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Valor (R\$)', colors),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _valorController,
                          hint: '0,00',
                          icon: Icons.attach_money_rounded,
                          colors: colors,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Categoria', colors),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categorias.map((cat) {
                            final selecionado = _categoriaSelecionada == cat;
                            return GestureDetector(
                              onTap: () => setState(
                                () => _categoriaSelecionada = cat,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selecionado
                                      ? colors.accent.withValues(alpha: 0.1)
                                      : colors.card,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selecionado
                                        ? colors.accent
                                        : colors.divider,
                                  ),
                                ),
                                child: Text(
                                  cat[0].toUpperCase() + cat.substring(1),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selecionado
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selecionado
                                        ? colors.accent
                                        : colors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Data', colors),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selecionarData,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.divider),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: colors.textSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  formatDataDDMMYYYY(_data),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: _isLoading ? null : _salvar,
                          child: Container(
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors.gradientStart,
                                  colors.gradientEnd,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.gradientStart
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Salvar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, AppColors colors) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required AppColors colors,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.divider),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15, color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colors.textSecondary.withValues(alpha: 0.6),
            fontSize: 15,
          ),
          prefixIcon: Icon(icon, color: colors.textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
