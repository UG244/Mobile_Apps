import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';

class AuthDb {
  static final AuthDb instance = AuthDb._init();
  static Database? _database;

  AuthDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('bluemart_auth.db');
    await _ensureDefaultAdmin();
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path = filePath;
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      path = join(dir.path, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');
  }

  Future<void> _ensureDefaultAdmin() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users WHERE username = ?', ['admin']),
    );

    if ((count ?? 0) == 0) {
      await db.insert('users', {
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
      });
    }
  }

  Future<UserModel?> getUserByCredentials(String username, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<bool> userExists(String username) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users WHERE username = ?', [username]),
    );
    return (count ?? 0) > 0;
  }

  Future<void> insertUser(String username, String password, {String role = 'user'}) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'username': username,
        'password': password,
        'role': role,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final rows = await db.query('users', orderBy: 'id ASC');
    return rows.map(UserModel.fromMap).toList();
  }
}
