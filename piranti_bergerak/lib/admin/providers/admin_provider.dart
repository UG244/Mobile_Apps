import 'package:flutter/material.dart';

import '../../cart/providers/cart_provider.dart';
import '../../checkout/db/order_db.dart';
import '../../checkout/models/order_detail_model.dart';
import '../../checkout/models/order_model.dart';
import '../../notification/providers/notification_provider.dart';
import '../../product/db/product_db.dart';
import '../../product/models/category_model.dart';
import '../../product/models/product_model.dart';
import '../../product/providers/favorite_provider.dart';
import '../../product/providers/product_provider.dart';

class AdminProvider extends ChangeNotifier {
  List<ProductModel> products = [];
  List<CategoryModel> categories = [];
  List<OrderModel> orders = [];
  bool isLoading = false;

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();

    products = await ProductDb.instance.getProducts(includeInactive: true);
    categories = await ProductDb.instance.getCategories();
    orders = await OrderDb.instance.getOrders();

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    products = await ProductDb.instance.getProducts(includeInactive: true);
    notifyListeners();
  }

  Future<void> addProduct(
    ProductModel product, {
    ProductProvider? productProvider,
    CartProvider? cartProvider,
    FavoriteProvider? favoriteProvider,
  }) async {
    await ProductDb.instance.addProduct(product);
    await _refreshCatalog(
      productProvider: productProvider,
      cartProvider: cartProvider,
      favoriteProvider: favoriteProvider,
    );
  }

  Future<void> updateProduct(
    ProductModel product, {
    ProductProvider? productProvider,
    CartProvider? cartProvider,
    FavoriteProvider? favoriteProvider,
  }) async {
    await ProductDb.instance.updateProduct(product);
    await _refreshCatalog(
      productProvider: productProvider,
      cartProvider: cartProvider,
      favoriteProvider: favoriteProvider,
    );
  }

  Future<void> deleteProduct(
    String id, {
    ProductProvider? productProvider,
    CartProvider? cartProvider,
    FavoriteProvider? favoriteProvider,
  }) async {
    await ProductDb.instance.deleteProduct(id);
    await _refreshCatalog(
      productProvider: productProvider,
      cartProvider: cartProvider,
      favoriteProvider: favoriteProvider,
    );
  }

  Future<void> restoreSeedCatalog({
    ProductProvider? productProvider,
    CartProvider? cartProvider,
    FavoriteProvider? favoriteProvider,
  }) async {
    await ProductDb.instance.restoreSeedCatalog();
    await _refreshCatalog(
      productProvider: productProvider,
      cartProvider: cartProvider,
      favoriteProvider: favoriteProvider,
    );
  }

  Future<void> loadCategories() async {
    categories = await ProductDb.instance.getCategories();
    notifyListeners();
  }

  Future<void> addCategory(
    CategoryModel category, {
    ProductProvider? productProvider,
  }) async {
    await ProductDb.instance.addCategory(category);
    await _refreshCatalog(productProvider: productProvider);
  }

  Future<void> updateCategory(
    CategoryModel category, {
    ProductProvider? productProvider,
  }) async {
    await ProductDb.instance.updateCategory(category);
    await _refreshCatalog(productProvider: productProvider);
  }

  Future<void> deleteCategory(
    String id, {
    ProductProvider? productProvider,
    CartProvider? cartProvider,
    FavoriteProvider? favoriteProvider,
  }) async {
    await ProductDb.instance.deleteCategory(id);
    await _refreshCatalog(
      productProvider: productProvider,
      cartProvider: cartProvider,
      favoriteProvider: favoriteProvider,
    );
  }

  Future<void> loadOrders() async {
    orders = await OrderDb.instance.getOrders();
    notifyListeners();
  }

  Future<List<OrderDetailModel>> getOrderDetails(int orderId) {
    return OrderDb.instance.getOrderDetails(orderId);
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
    NotificationProvider? notificationProvider,
  }) async {
    await OrderDb.instance.updateOrderStatus(orderId, status);
    final order = await OrderDb.instance.getOrderById(orderId);
    if (order != null) {
      await notificationProvider?.addNotification(
        title: 'Status ${order.invoice}: $status',
        description: _statusMessage(order, status),
        type: 'Pesanan',
        userId: order.userId,
        targetRole: 'user',
      );
    }
    await loadOrders();
  }

  int get totalProducts => products.where((item) => item.isActive).length;
  int get totalOrders => orders.length;
  double get totalRevenue =>
      orders.fold(0, (sum, order) => sum + order.grandTotal);
  double get todaySales {
    final now = DateTime.now();
    return orders
        .where(
          (order) =>
              order.date.year == now.year &&
              order.date.month == now.month &&
              order.date.day == now.day,
        )
        .fold(0, (sum, order) => sum + order.grandTotal);
  }

  int get totalCustomers => orders.map((order) => order.phone).toSet().length;

  String get bestSellingProduct {
    if (products.isEmpty) return '-';
    final sorted = [...products]..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.first.name;
  }

  List<double> get weeklySalesData {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final day = DateTime(now.year, now.month, now.day - (6 - index));
      return orders
          .where(
            (order) =>
                order.date.year == day.year &&
                order.date.month == day.month &&
                order.date.day == day.day,
          )
          .fold(0, (sum, order) => sum + order.grandTotal);
    });
  }

  Future<void> _refreshCatalog({
    ProductProvider? productProvider,
    CartProvider? cartProvider,
    FavoriteProvider? favoriteProvider,
  }) async {
    products = await ProductDb.instance.getProducts(includeInactive: true);
    categories = await ProductDb.instance.getCategories();
    await productProvider?.refresh();
    final activeProducts = await ProductDb.instance.getProducts();
    cartProvider?.syncWithProducts(activeProducts);
    favoriteProvider?.syncWithProducts(activeProducts);
    notifyListeners();
  }

  String _statusMessage(OrderModel order, String status) {
    if (status == 'Selesai') {
      return 'Pesanan ${order.invoice} sudah selesai. Terima kasih sudah berbelanja di BlueMart.';
    }
    if (status == 'Dikirim') {
      return 'Pesanan ${order.invoice} sedang dikirim ke alamat tujuan.';
    }
    if (status == 'Dikemas') {
      return 'Pesanan ${order.invoice} sedang dikemas oleh tim BlueMart.';
    }
    return 'Pesanan ${order.invoice} sedang diproses.';
  }
}
