import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tarefas_202310213.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            descricao TEXT,
            prioridade INTEGER,
            criadoEm TEXT,
            etapaFluxo TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertTarefa(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('tarefas', row);
  }

  Future<List<Map<String, dynamic>>> getTarefas() async {
    Database db = await database;
    return await db.query('tarefas', orderBy: 'id DESC');
  }

  Future<int> updateTarefa(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('tarefas', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTarefa(int id) async {
    Database db = await database;
    return await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }
}
