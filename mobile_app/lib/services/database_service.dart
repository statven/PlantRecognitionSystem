import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/scan_result.dart';
import 'dart:io'; // Добавьте эту строку в начало файла

class DatabaseService {
  static const _dbName = 'plant_scans.db';
  static const _dbVersion = 1;
  static const tableName = 'scans';
  
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL,
        diseaseName TEXT NOT NULL,
        confidence REAL NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertScan(ScanResult scan) async {
    Database db = await database;
    return await db.insert(tableName, scan.toMap());
  }

  Future<List<ScanResult>> getScans() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => ScanResult.fromMap(maps[i]));
  }
}