import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'history_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('leaf_sense.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE diagnosis_history (
        id $idType,
        imagePath $textType,
        diseaseName $textType,
        category $textType,
        confidence $doubleType,
        recommendation $textType,
        colorValue $intType,
        timestamp $textType
      )
    ''');

    debugPrint("✅ Database table 'diagnosis_history' created successfully");
  }

  // CREATE - Simpan riwayat baru
  Future<int> insertHistory(DiagnosisHistory history) async {
    final db = await database;
    final id = await db.insert('diagnosis_history', history.toMap());
    debugPrint("✅ History saved with ID: $id");
    return id;
  }

  // READ - Ambil semua riwayat (sorted by newest)
  Future<List<DiagnosisHistory>> getAllHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'diagnosis_history',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return DiagnosisHistory.fromMap(maps[i]);
    });
  }

  // READ - Ambil 1 riwayat by ID
  Future<DiagnosisHistory?> getHistoryById(int id) async {
    final db = await database;
    final maps = await db.query(
      'diagnosis_history',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DiagnosisHistory.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE - Update riwayat (jarang dipakai)
  Future<int> updateHistory(DiagnosisHistory history) async {
    final db = await database;
    return db.update(
      'diagnosis_history',
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  // DELETE - Hapus 1 riwayat
  Future<int> deleteHistory(int id) async {
    final db = await database;
    final result = await db.delete(
      'diagnosis_history',
      where: 'id = ?',
      whereArgs: [id],
    );
    debugPrint("🗑️ History deleted: ID $id");
    return result;
  }

  // DELETE - Hapus semua riwayat
  Future<int> deleteAllHistory() async {
    final db = await database;
    final result = await db.delete('diagnosis_history');
    debugPrint("🗑️ All history deleted: $result rows");
    return result;
  }

  // COUNT - Hitung jumlah riwayat
  Future<int> getHistoryCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM diagnosis_history');
    int? count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }

  // CLOSE - Tutup database
  Future close() async {
    final db = await database;
    db.close();
  }
}