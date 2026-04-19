import '../models/gasto.dart';

abstract class GastoRepository {
  Future<List<Gasto>> getAll();
  Future<void> add(Gasto gasto);
  Future<void> remove(String id);
}
