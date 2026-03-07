import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform/database_factory_stub.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    if (kIsWeb) {
      // Use the FFI web factory safely
      final factory = getStubDatabaseFactory();
      if (factory != null) {
        databaseFactory = factory;
      }
      return await openDatabase(
        'smartdrive.db',
        version: 1,
        onCreate: _onCreate,
      );
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smartdrive.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE emergency_contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        phone TEXT
      )
    ''');
  }
}
