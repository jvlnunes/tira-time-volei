import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/player_model.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._init();
  static Database? _database;

  DatabaseManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('racha_volei.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        position TEXT NOT NULL,
        secondPosition TEXT NOT NULL DEFAULT 'Nenhuma',
        rating REAL NOT NULL CHECK(rating >= 0.5 AND rating <= 5.0),
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona a coluna createdAt se não existir
      await db.execute(
        'ALTER TABLE players ADD COLUMN createdAt INTEGER DEFAULT 0',
      );
    }
  }

  Future<void> createPlayer(Player player) async {
    final db = await instance.database;
    await db.insert(
      'players',
      player.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Player>> getPlayers() async {
    final db = await instance.database;
    final result = await db.query('players', orderBy: 'name ASC');
    return result.map((json) => Player.fromMap(json)).toList();
  }

  Future<Player?> getPlayerById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Player.fromMap(result.first);
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

  Future<int> deleteAllPlayers() async {
    final db = await instance.database;
    return await db.delete('players');
  }

  Future<List<Player>> searchPlayers(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'players',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((json) => Player.fromMap(json)).toList();
  }

  Future<bool> playerExistsByName(String name) async {
    final db = await instance.database;
    final result = await db.query(
      'players',
      where: 'LOWER(name) = ?',
      whereArgs: [name.toLowerCase()],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
