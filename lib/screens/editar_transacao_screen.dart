import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../repositories/gasto_repository_impl.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class EditarTransacaoScreen extends StatefulWidget {
  final Gasto gasto;
  final String userId;

  const EditarTransacaoScreen({
    super.key,
    required this.gasto,
    required this.userId,
  });

  @override
  State<EditarTransacaoScreen> createState() => _EditarTransacaoScreenState();
}

class _EditarTransacaoScreenState extends State<EditarTransacaoScreen> {
  late final TextEditingController _tituloController;
  late final TextEditingController _valorController;
  final _repository = GastoRepositoryImpl();

  late bool _isDespesa;
  late String? _categoriaSelecionada;
  late DateTime _data;
  bool _isLoading = false;

  static const _categorias = [
    'alimentação',
    'transporte',
    'lazer',
    'pagamento',
    'outros',
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.gasto;
    _isDespesa = g.valor < 0;
    _categoriaSelecionada = g.categoria;
    _data = g.data;
    _tituloController = TextEditingController(text: g.titulo);
    _valorController = TextEditingController(
      text: g.valor.abs().toStringAsFixed(2).replaceAll('.', ','),
    );
  }

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
      _showSnack('Informe o título da transação.');
      return;
    }
    final valorParsed = double.tryParse(valorText);
    if (valorParsed == null || valorParsed <= 0) {
      _showSnack('Informe um valor válido maior que zero.');
      return;
    }
    if (_categoriaSelecionada == null) {
      _showSnack('Selecione uma categoria.');
      return;
    }

    setState(() => _isLoading = true);

    final atualizado = Gasto(
      id: widget.gasto.id,
      titulo: titulo,
      valor: _isDespesa ? -valorParsed : valorParsed,
      categoria: _categoriaSelecionada!,
      data: _data,
    );

    try {
      await _repository.update(atualizado, widget.userId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Erro ao salvar. Tente novamente.');
    }
  }

  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colors = Theme.of(ctx).extension<AppColors>()!;
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Excluir transação',
            style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Tem certeza que deseja excluir "${widget.gasto.titulo}"?',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancelar', style: TextStyle(color: colors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir', style: TextStyle(color: kExpenseRed)),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;
    await _repository.remove(widget.gasto.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                      onPressed: _isLoading ? null : _excluir,
                    ),
                  ],
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
                  _isDespesa ? 'Editar Despesa' : 'Editar Receita',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Atualize os dados da transação',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 220 - topPadding + 30,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isDespesa = true),
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _isDespesa ? kExpenseRed : colors.card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isDespesa ? kExpenseRed : colors.divider,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Despesa',
                                    style: TextStyle(
                                      color: _isDespesa ? Colors.white : colors.textSecondary,
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
                                onTap: () => setState(() => _isDespesa = false),
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: !_isDespesa ? kIncomeGreen : colors.card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !_isDespesa ? kIncomeGreen : colors.divider,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Receita',
                                    style: TextStyle(
                                      color: !_isDespesa ? Colors.white : colors.textSecondary,
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                              onTap: () => setState(() => _categoriaSelecionada = cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selecionado
                                      ? colors.accent.withValues(alpha: 0.1)
                                      : colors.card,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selecionado ? colors.accent : colors.divider,
                                  ),
                                ),
                                child: Text(
                                  cat[0].toUpperCase() + cat.substring(1),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
                                    color: selecionado ? colors.accent : colors.textSecondary,
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
                                Icon(Icons.calendar_today_outlined,
                                    color: colors.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  formatDataDDMMYYYY(_data),
                                  style: TextStyle(fontSize: 15, color: colors.textPrimary),
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
                                colors: [colors.gradientStart, colors.gradientEnd],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.gradientStart.withValues(alpha: 0.3),
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
                                    'Salvar alterações',
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
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
