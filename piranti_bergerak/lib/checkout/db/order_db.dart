import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/checkout_address_model.dart';
import '../models/order_model.dart';
import '../models/order_detail_model.dart';
import '../../notification/models/app_notification_model.dart';

class OrderDb {
  static final OrderDb instance = OrderDb._init();

  static Database? _database;

  OrderDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('bluemart.db');
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
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice TEXT,
      customerName TEXT,
      phone TEXT,
      address TEXT,
      note TEXT,
      paymentMethod TEXT,
      shippingMethod TEXT,
      subtotal REAL,
      shippingCost REAL,
      discount REAL,
      tax REAL,
      grandTotal REAL,
      date TEXT,
      status TEXT DEFAULT 'Diproses'
    )
    ''');

    await db.execute('''
    CREATE TABLE order_details (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderId INTEGER,
      productId TEXT,
      name TEXT,
      price REAL,
      quantity INTEGER,
      total REAL,
      imageUrl TEXT DEFAULT ''
    )
    ''');

    await db.execute('''
    CREATE TABLE notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      message TEXT,
      description TEXT,
      type TEXT DEFAULT 'Pesanan',
      date TEXT,
      createdAt TEXT,
      isRead INTEGER DEFAULT 0
    )
    ''');

    await db.execute('''
    CREATE TABLE checkout_addresses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      recipientName TEXT,
      phone TEXT,
      address TEXT,
      note TEXT,
      createdAt TEXT
    )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        message TEXT,
        date TEXT,
        isRead INTEGER DEFAULT 0
      )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS checkout_addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipientName TEXT,
        phone TEXT,
        address TEXT,
        note TEXT,
        createdAt TEXT
      )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE orders ADD COLUMN status TEXT DEFAULT 'Diproses'",
      );
      await db.execute(
        "ALTER TABLE order_details ADD COLUMN imageUrl TEXT DEFAULT ''",
      );
    }
    if (oldVersion < 5) {
      await db.execute(
        "ALTER TABLE notifications ADD COLUMN description TEXT DEFAULT ''",
      );
      await db.execute(
        "ALTER TABLE notifications ADD COLUMN type TEXT DEFAULT 'Pesanan'",
      );
      await db.execute("ALTER TABLE notifications ADD COLUMN createdAt TEXT");
    }
  }

  Future<int> insertOrder(
    OrderModel order,
    List<OrderDetailModel> details,
  ) async {
    final db = await instance.database;
    final id = await db.insert('orders', order.toMap());
    for (final d in details) {
      final m = d.toMap();
      m['orderId'] = id;
      await db.insert('order_details', m);
    }
    return id;
  }

  Future<OrderModel?> getOrderById(int id) async {
    final db = await instance.database;
    final rows = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return OrderModel.fromMap(rows.first);
  }

  Future<List<OrderModel>> getOrders() async {
    final db = await instance.database;
    final rows = await db.query('orders', orderBy: 'id DESC');
    return rows.map(OrderModel.fromMap).toList();
  }

  Future<void> updateOrderStatus(int id, String status) async {
    final db = await instance.database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<OrderDetailModel>> getOrderDetails(int orderId) async {
    final db = await instance.database;
    final rows = await db.query(
      'order_details',
      where: 'orderId = ?',
      whereArgs: [orderId],
      orderBy: 'id ASC',
    );
    return rows.map(OrderDetailModel.fromMap).toList();
  }

  Future<int> getOrderTotalItems(int orderId) async {
    final db = await instance.database;
    final rows = await db.rawQuery(
      'SELECT SUM(quantity) AS totalItems FROM order_details WHERE orderId = ?',
      [orderId],
    );
    final value = rows.first['totalItems'];
    if (value == null) return 0;
    return (value as num).toInt();
  }

  Future<int> insertNotification({
    required String title,
    required String message,
    required DateTime date,
    String type = 'Pesanan',
  }) async {
    final db = await instance.database;
    return db.insert('notifications', {
      'title': title,
      'message': message,
      'description': message,
      'type': type,
      'date': date.toIso8601String(),
      'createdAt': date.toIso8601String(),
      'isRead': 0,
    });
  }

  Future<int> insertAppNotification(AppNotificationModel notification) async {
    final db = await instance.database;
    final map = notification.toMap();
    map['message'] = notification.description;
    map['date'] = notification.createdAt.toIso8601String();
    return db.insert('notifications', map);
  }

  Future<List<AppNotificationModel>> getNotifications() async {
    final db = await instance.database;
    final rows = await db.query('notifications', orderBy: 'id DESC');
    return rows.map(AppNotificationModel.fromMap).toList();
  }

  Future<void> markNotificationAsRead(int id) async {
    final db = await instance.database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllNotificationsAsRead() async {
    final db = await instance.database;
    await db.update('notifications', {'isRead': 1});
  }

  Future<void> deleteNotification(int id) async {
    final db = await instance.database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllNotifications() async {
    final db = await instance.database;
    await db.delete('notifications');
  }

  Future<List<CheckoutAddressModel>> getCheckoutAddresses() async {
    final db = await instance.database;
    final rows = await db.query('checkout_addresses', orderBy: 'id DESC');
    return rows.map(CheckoutAddressModel.fromMap).toList();
  }

  Future<int> insertCheckoutAddress(CheckoutAddressModel address) async {
    final db = await instance.database;
    return db.insert('checkout_addresses', address.toMap());
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
