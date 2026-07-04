import 'package:flutter/material.dart';

import '../../checkout/db/order_db.dart';
import '../../checkout/models/order_detail_model.dart';
import '../../checkout/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> orders = [];
  Map<int, int> totalItemsByOrderId = {};
  OrderModel? selectedOrder;
  List<OrderDetailModel> selectedDetails = [];
  bool isLoading = false;
  bool isLoadingDetail = false;

  Future<void> loadOrders() async {
    isLoading = true;
    notifyListeners();

    orders = await OrderDb.instance.getOrders();
    totalItemsByOrderId = {};
    for (final order in orders) {
      final id = order.id;
      if (id == null) continue;
      totalItemsByOrderId[id] = await OrderDb.instance.getOrderTotalItems(id);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshOrders() => loadOrders();

  Future<void> loadOrderDetail(int orderId) async {
    isLoadingDetail = true;
    notifyListeners();

    selectedOrder = await OrderDb.instance.getOrderById(orderId);
    selectedDetails = await getOrderDetails(orderId);

    isLoadingDetail = false;
    notifyListeners();
  }

  Future<List<OrderDetailModel>> getOrderDetails(int orderId) {
    return OrderDb.instance.getOrderDetails(orderId);
  }

  int getTotalItems(int orderId) {
    return totalItemsByOrderId[orderId] ?? 0;
  }

  Color getStatusColor(String status) {
    if (status == 'Dikirim') return const Color(0xFFEF6C00);
    if (status == 'Selesai') return const Color(0xFF2E7D32);
    return const Color(0xFF1565C0);
  }

  String formatDateIndonesia(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = value.day.toString().padLeft(2, '0');
    final month = months[value.month - 1];
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }
}
