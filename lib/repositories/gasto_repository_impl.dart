import '../database/db_helper.dart';
import '../models/gasto.dart';
import 'gasto_repository.dart';

class GastoRepositoryImpl implements GastoRepository {
  final _db = DbHelper();

  @override
  Future<List<Gasto>> getAll(String userId) async => await _db.getAllGastos(userId);

  @override
  Future<void> add(Gasto gasto, String userId) async => await _db.insertGasto(gasto, userId);

  @override
  Future<void> update(Gasto gasto, String userId) async => await _db.updateGasto(gasto, userId);

  @override
  Future<void> remove(String id) async => await _db.deleteGasto(id);
}
