import '../database/db_helper.dart';
import '../models/gasto.dart';
import 'gasto_repository.dart';

class GastoRepositoryImpl implements GastoRepository {
  final _db = DbHelper();

  @override
  Future<List<Gasto>> getAll() async => await _db.getAllGastos();

  @override
  Future<void> add(Gasto gasto) async => await _db.insertGasto(gasto);

  @override
  Future<void> remove(String id) async => await _db.deleteGasto(id);
}
