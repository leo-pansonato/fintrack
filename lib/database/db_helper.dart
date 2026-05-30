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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gastos (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        titulo TEXT NOT NULL,
        valor REAL NOT NULL,
        categoria TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE gastos ADD COLUMN user_id TEXT NOT NULL DEFAULT ''");
    }
  }

  Future<int> insertGasto(Gasto gasto, String userId) async {
    final db = await database;
    final map = gasto.toMap()..['user_id'] = userId;
    return await db.insert('gastos', map, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<Gasto>> getAllGastos(String userId) async {
    final db = await database;
    final maps = await db.query(
      'gastos',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'data DESC',
    );
    return maps.map((m) => Gasto.fromMap(m)).toList();
  }

  Future<int> updateGasto(Gasto gasto, String userId) async {
    final db = await database;
    final map = gasto.toMap()..['user_id'] = userId;
    return await db.update(
      'gastos',
      map,
      where: 'id = ? AND user_id = ?',
      whereArgs: [gasto.id, userId],
    );
  }

  Future<int> deleteGasto(String id) async {
    final db = await database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }
}
