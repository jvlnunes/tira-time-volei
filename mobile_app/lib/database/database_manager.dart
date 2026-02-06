import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/player_model.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._init();
  static Database? _database;

  DatabaseManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        position TEXT NOT NULL,
        secondPosition TEXT,
        rating REAL NOT NULL
      )
  ''');
  }

  Future<void> createPlayer(Player player) async {
    final db = await instance.database;
    await db.insert('players', player.toMap(), conflictAlgorithm: .replace);
  }

  Future<List<Player>> getPlayers() async {
    final db = await instance.database;
    final result = await db.query('players', orderBy: 'name ASC');
    return result.map((json) => Player.fromMap(json)).toList();
  }

  Future<int> updatePlayer(Player player) async {
    final db = await instance.database;
    return await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );
  }

  Future<int> deletePlayer(String id) async {
    final db = await instance.database;
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }
}
