import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/gasto.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'fintrack.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gastos (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        valor REAL NOT NULL,
        categoria TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertGasto(Gasto gasto) async {
    final db = await database;
    return await db.insert(
      'gastos',
      gasto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Gasto>> getAllGastos() async {
    final db = await database;
    final maps = await db.query('gastos', orderBy: 'data DESC');
    return maps.map((m) => Gasto.fromMap(m)).toList();
  }

  Future<int> deleteGasto(String id) async {
    final db = await database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }
}
