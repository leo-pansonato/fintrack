class Gasto {
  final int? id;
  final String titulo;
  final double valor;
  final String categoria;
  final DateTime data;

  const Gasto({
    this.id,
    required this.titulo,
    required this.valor,
    required this.categoria,
    required this.data,
  });
}
