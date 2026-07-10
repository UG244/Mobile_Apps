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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        displayName TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL DEFAULT '',
        phone TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE users ADD COLUMN displayName TEXT NOT NULL DEFAULT ''");
      await db.execute("ALTER TABLE users ADD COLUMN email TEXT NOT NULL DEFAULT ''");
      await db.execute("ALTER TABLE users ADD COLUMN phone TEXT NOT NULL DEFAULT ''");
      await db.update(
        'users',
        {'displayName': 'admin'},
        where: 'username = ?',
        whereArgs: ['admin'],
      );
    }
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
        'displayName': 'Administrator',
        'email': 'admin@bluemart.id',
        'phone': '',
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
        'displayName': username,
        'email': '',
        'phone': '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUserProfile({
    required int id,
    required String displayName,
    required String email,
    required String phone,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {
        'displayName': displayName,
        'email': email,
        'phone': phone,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateUserPassword({
    required int id,
    required String password,
  }) async {
    final db = await database;
    await db.update(
      'users',
      {'password': password},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final rows = await db.query('users', orderBy: 'id ASC');
    return rows.map(UserModel.fromMap).toList();
  }
}
