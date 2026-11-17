import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final databasePath = join(await getDatabasesPath(), 'shoppinghub.db');
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            username TEXT PRIMARY KEY COLLATE NOCASE,
            password_hash TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE wishlist (
            username TEXT NOT NULL COLLATE NOCASE,
            product_id INTEGER NOT NULL,
            product_json TEXT NOT NULL,
            PRIMARY KEY (username, product_id)
          )
        ''');
      },
    );
    await _ensureDemoAccount(_database!);
    return _database!;
  }

  Future<void> _ensureDemoAccount(Database db) async {
    final existing = await db.query(
      'users',
      columns: ['username'],
      where: 'username = ?',
      whereArgs: ['demo'],
      limit: 1,
    );
    if (existing.isEmpty) {
      await db.insert('users', {
        'username': 'demo',
        'password_hash': _hashPassword('123456'),
      });
    }
  }

  String _hashPassword(String password) =>
      sha256.convert(password.codeUnits).toString();

  Future<bool> authenticate(String username, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      columns: ['password_hash'],
      where: 'username = ?',
      whereArgs: [username.trim()],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    return rows.single['password_hash'] == _hashPassword(password);
  }

  Future<bool> createAccount(String username, String password) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty || password.isEmpty) return false;
    final db = await database;
    final existing = await db.query(
      'users',
      columns: ['username'],
      where: 'username = ?',
      whereArgs: [normalizedUsername],
      limit: 1,
    );
    if (existing.isNotEmpty) return false;
    await db.insert('users', {
      'username': normalizedUsername,
      'password_hash': _hashPassword(password),
    });
    return true;
  }

  Future<List<Product>> getWishlist(String username) async {
    final db = await database;
    final rows = await db.query(
      'wishlist',
      columns: ['product_json'],
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'product_id DESC',
    );
    return rows
        .map((row) => Product.fromJson(
              jsonDecode(row['product_json']! as String)
                  as Map<String, dynamic>,
            ))
        .toList(growable: false);
  }

  Future<void> addToWishlist(String username, Product product) async {
    final db = await database;
    await db.insert(
      'wishlist',
      {
        'username': username,
        'product_id': product.id,
        'product_json': jsonEncode(product.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromWishlist(String username, int productId) async {
    final db = await database;
    await db.delete(
      'wishlist',
      where: 'username = ? AND product_id = ?',
      whereArgs: [username, productId],
    );
  }
}
