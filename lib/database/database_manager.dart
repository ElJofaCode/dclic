import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modele/redacteur.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  factory DatabaseManager() => _instance;
  DatabaseManager._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'redacteurs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE redacteurs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertRedacteur(Redacteur r) async {
    final db = await database;
    return await db.insert('redacteurs', r.toMap());
  }

  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;
    final res = await db.query('redacteurs');
    return res.map((map) => Redacteur.fromMap(map)).toList();
  }

  Future<int> updateRedacteur(Redacteur r) async {
    final db = await database;
    return await db.update('redacteurs', r.toMap(), where: 'id = ?', whereArgs: [r.id]);
  }

  Future<int> deleteRedacteur(int id) async {
    final db = await database;
    return await db.delete('redacteurs', where: 'id = ?', whereArgs: [id]);
  }
}
