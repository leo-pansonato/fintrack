import '../models/gasto.dart';

abstract class GastoRepository {
  Future<List<Gasto>> getAll(String userId);
  Future<void> add(Gasto gasto, String userId);
  Future<void> update(Gasto gasto, String userId);
  Future<void> remove(String id);
}
