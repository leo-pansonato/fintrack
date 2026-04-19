import 'package:uuid/uuid.dart';

class Gasto {
  final String id;
  final String titulo;
  final double valor;
  final String categoria;
  final DateTime data;

  Gasto({
    String? id,
    required this.titulo,
    required this.valor,
    required this.categoria,
    required this.data,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'valor': valor,
      'categoria': categoria,
      'data': data.toIso8601String(),
    };
  }

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      valor: (map['valor'] as num).toDouble(),
      categoria: map['categoria'] as String,
      data: DateTime.parse(map['data'] as String),
    );
  }
}
