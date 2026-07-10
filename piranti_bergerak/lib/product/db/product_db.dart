import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductDb {
  static final ProductDb instance = ProductDb._init();

  static Database? _database;

  ProductDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('bluemart_catalog.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path = filePath;
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      path = join(dir.path, filePath);
    }

    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconName TEXT NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        originalPrice REAL NOT NULL,
        imageUrl TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        rating REAL DEFAULT 0,
        reviewCount INTEGER DEFAULT 0,
        stock INTEGER DEFAULT 0,
        weight REAL DEFAULT 0,
        isActive INTEGER DEFAULT 1
      )
    ''');

    await _seedCatalog(db);
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    var rows = await db.query('categories', orderBy: 'name ASC');
    if (rows.isEmpty) {
      await _seedCategoriesOnly(db);
      rows = await db.query('categories', orderBy: 'name ASC');
    }
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<List<ProductModel>> getProducts({bool includeInactive = false}) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: includeInactive ? null : 'isActive = ?',
      whereArgs: includeInactive ? null : [1],
      orderBy: 'name ASC',
    );
    return rows.map(ProductModel.fromMap).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(ProductModel product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<Map<String, ProductModel>> getActiveProductsByIds(
    Iterable<String> ids,
  ) async {
    final uniqueIds = ids.toSet().toList();
    if (uniqueIds.isEmpty) return {};

    final db = await database;
    final placeholders = List.filled(uniqueIds.length, '?').join(',');
    final rows = await db.query(
      'products',
      where: 'isActive = ? AND id IN ($placeholders)',
      whereArgs: [1, ...uniqueIds],
    );
    return {
      for (final product in rows.map(ProductModel.fromMap)) product.id: product,
    };
  }

  Future<void> reduceStock(Map<String, int> quantitiesByProductId) async {
    if (quantitiesByProductId.isEmpty) return;

    final db = await database;
    await db.transaction((txn) async {
      for (final entry in quantitiesByProductId.entries) {
        final rows = await txn.query(
          'products',
          columns: ['stock', 'isActive'],
          where: 'id = ?',
          whereArgs: [entry.key],
          limit: 1,
        );
        if (rows.isEmpty || rows.first['isActive'] != 1) {
          throw StateError('Produk tidak tersedia.');
        }

        final stock = (rows.first['stock'] as num?)?.toInt() ?? 0;
        if (stock < entry.value) {
          throw StateError('Stok produk tidak cukup.');
        }

        await txn.update(
          'products',
          {'stock': stock - entry.value},
          where: 'id = ?',
          whereArgs: [entry.key],
        );
      }
    });
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addCategory(CategoryModel category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'categories',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
      await txn.update(
        'products',
        {'categoryName': category.name},
        where: 'categoryId = ?',
        whereArgs: [category.id],
      );
    });
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    await db.update(
      'products',
      {'isActive': 0},
      where: 'categoryId = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreSeedCatalog() async {
    final db = await database;
    await db.transaction((txn) async {
      for (final category in _seedCategories) {
        await txn.insert(
          'categories',
          category.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (final product in _seedProducts) {
        await txn.insert(
          'products',
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> _seedCatalog(Database db) async {
    await _seedCategoriesOnly(db);
    for (final product in _seedProducts) {
      await db.insert('products', product.toMap());
    }
  }

  Future<void> _seedCategoriesOnly(Database db) async {
    for (final category in _seedCategories) {
      await db.insert(
        'categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static List<CategoryModel> get seedCategories =>
      List.unmodifiable(_seedCategories);

  static List<ProductModel> get seedProducts =>
      List.unmodifiable(_seedProducts);

  static final List<CategoryModel> _seedCategories = [
    CategoryModel(
      id: 'cat_laptop',
      name: 'Laptop',
      iconName: 'laptop_mac',
      color: 0xFF1565C0,
    ),
    CategoryModel(
      id: 'cat_phone',
      name: 'Smartphone',
      iconName: 'smartphone',
      color: 0xFF6A1B9A,
    ),
    CategoryModel(
      id: 'cat_audio',
      name: 'Audio',
      iconName: 'headphones',
      color: 0xFF00838F,
    ),
    CategoryModel(
      id: 'cat_gaming',
      name: 'Gaming',
      iconName: 'sports_esports',
      color: 0xFFE65100,
    ),
    CategoryModel(
      id: 'cat_aksesoris',
      name: 'Aksesoris',
      iconName: 'cable',
      color: 0xFF2E7D32,
    ),
    CategoryModel(
      id: 'cat_storage',
      name: 'Storage',
      iconName: 'storage',
      color: 0xFFC62828,
    ),
  ];

  static final List<ProductModel> _seedProducts = [
    ProductModel(
      id: 'prod_001',
      name: 'ASUS VivoBook 15 OLED',
      description:
          'Laptop tipis dengan layar OLED 15,6 inci, AMD Ryzen 5, RAM 16GB, dan SSD 512GB.',
      price: 8999000,
      originalPrice: 10499000,
      imageUrl:
          'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400&h=300&fit=crop',
      categoryId: 'cat_laptop',
      categoryName: 'Laptop',
      rating: 4.7,
      reviewCount: 284,
      stock: 12,
      weight: 1.7,
    ),
    ProductModel(
      id: 'prod_002',
      name: 'Lenovo IdeaPad Slim 5 Gen 9',
      description:
          'Laptop bisnis ultra-slim dengan Intel Core i7, RAM 16GB, SSD 1TB, dan layar anti-glare.',
      price: 11499000,
      originalPrice: 11499000,
      imageUrl:
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=300&fit=crop',
      categoryId: 'cat_laptop',
      categoryName: 'Laptop',
      rating: 4.5,
      reviewCount: 196,
      stock: 8,
      weight: 1.5,
    ),
    ProductModel(
      id: 'prod_003',
      name: 'Samsung Galaxy S24 FE',
      description:
          'Smartphone flagship dengan layar AMOLED 120Hz, kamera utama 50MP OIS, dan fitur AI.',
      price: 7499000,
      originalPrice: 8999000,
      imageUrl:
          'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400&h=300&fit=crop',
      categoryId: 'cat_phone',
      categoryName: 'Smartphone',
      rating: 4.6,
      reviewCount: 341,
      stock: 20,
      weight: 0.2,
    ),
    ProductModel(
      id: 'prod_004',
      name: 'Sony WH-1000XM5',
      description:
          'Headphone nirkabel dengan Active Noise Cancelling, Hi-Res Audio, dan baterai 30 jam.',
      price: 3999000,
      originalPrice: 5200000,
      imageUrl:
          'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400&h=300&fit=crop',
      categoryId: 'cat_audio',
      categoryName: 'Audio',
      rating: 4.8,
      reviewCount: 763,
      stock: 30,
      weight: 0.25,
    ),
    ProductModel(
      id: 'prod_005',
      name: 'Logitech G502 X Plus',
      description:
          'Mouse gaming nirkabel dengan sensor HERO 25K, 13 tombol, dan lampu RGB.',
      price: 1299000,
      originalPrice: 1599000,
      imageUrl:
          'https://images.unsplash.com/photo-1527814050087-3793815479db?w=400&h=300&fit=crop',
      categoryId: 'cat_gaming',
      categoryName: 'Gaming',
      rating: 4.7,
      reviewCount: 289,
      stock: 40,
      weight: 0.13,
    ),
    ProductModel(
      id: 'prod_006',
      name: 'Anker 735 GaN Charger 65W',
      description:
          'Charger GaN 3-port dengan PowerIQ 4.0 dan ukuran ringkas untuk perangkat modern.',
      price: 429000,
      originalPrice: 599000,
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
      categoryId: 'cat_aksesoris',
      categoryName: 'Aksesoris',
      rating: 4.8,
      reviewCount: 621,
      stock: 60,
      weight: 0.12,
    ),
    ProductModel(
      id: 'prod_007',
      name: 'Samsung 870 EVO SSD 1TB',
      description:
          'SSD SATA 2.5 inci dengan kecepatan baca 560 MB/s dan garansi resmi 5 tahun.',
      price: 1099000,
      originalPrice: 1399000,
      imageUrl:
          'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=400&h=300&fit=crop',
      categoryId: 'cat_storage',
      categoryName: 'Storage',
      rating: 4.9,
      reviewCount: 1023,
      stock: 35,
      weight: 0.08,
    ),
  ];
}
