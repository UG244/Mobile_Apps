import 'package:flutter/material.dart';

import '../../checkout/db/order_db.dart';
import '../../checkout/models/order_detail_model.dart';
import '../../checkout/models/order_model.dart';

class OrderTrackingStep {
  const OrderTrackingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.isDone,
    required this.isActive,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isDone;
  final bool isActive;
}

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
    if (status == 'Dikemas') return const Color(0xFF6A1B9A);
    if (status == 'Dikirim') return const Color(0xFFEF6C00);
    if (status == 'Sampai') return const Color(0xFF2E7D32);
    if (status == 'Selesai') return const Color(0xFF2E7D32);
    return const Color(0xFF1565C0);
  }

  String getCurrentStatus(OrderModel order) {
    if (order.status != 'Diproses') return order.status;

    final elapsed = DateTime.now().difference(order.date);
    if (elapsed.inHours >= _arrivalHours(order.shippingMethod)) {
      return 'Sampai';
    }
    if (elapsed.inMinutes >= 10) return 'Dikirim';
    if (elapsed.inMinutes >= 2) return 'Dikemas';
    return 'Diproses';
  }

  String getTrackingSummary(OrderModel order) {
    final status = getCurrentStatus(order);
    if (status == 'Sampai') {
      return 'Pesanan sudah sampai di alamat tujuan.';
    }
    if (status == 'Dikirim') {
      return 'Pesanan sedang dalam perjalanan menuju alamat penerima.';
    }
    if (status == 'Dikemas') {
      return 'Pesanan sedang dikemas dan disiapkan untuk kurir.';
    }
    return 'Pesanan sudah diterima sistem dan sedang diverifikasi.';
  }

  String getEstimatedArrival(OrderModel order) {
    final arrival = order.date.add(
      Duration(hours: _arrivalHours(order.shippingMethod)),
    );
    return formatDateIndonesia(arrival);
  }

  List<OrderTrackingStep> getTrackingSteps(OrderModel order) {
    final currentStatus = getCurrentStatus(order);
    final currentIndex = _trackingStatuses.indexOf(currentStatus);
    final activeIndex = currentIndex < 0 ? 0 : currentIndex;

    return [
      OrderTrackingStep(
        title: 'Diproses',
        description: 'Pesanan diterima dan pembayaran dicatat.',
        icon: Icons.receipt_long_outlined,
        isDone: activeIndex >= 0,
        isActive: activeIndex == 0,
      ),
      OrderTrackingStep(
        title: 'Dikemas',
        description: 'Produk sedang disiapkan sebelum diserahkan ke kurir.',
        icon: Icons.inventory_2_outlined,
        isDone: activeIndex >= 1,
        isActive: activeIndex == 1,
      ),
      OrderTrackingStep(
        title: 'Dikirim',
        description: 'Kurir sedang mengantar pesanan ke alamat tujuan.',
        icon: Icons.local_shipping_outlined,
        isDone: activeIndex >= 2,
        isActive: activeIndex == 2,
      ),
      OrderTrackingStep(
        title: 'Sampai',
        description: 'Pesanan sampai. Silakan cek barang yang diterima.',
        icon: Icons.check_circle_outline,
        isDone: activeIndex >= 3,
        isActive: activeIndex == 3,
      ),
    ];
  }

  int _arrivalHours(String shippingMethod) {
    if (shippingMethod == 'Same Day') return 8;
    if (shippingMethod == 'Express') return 36;
    return 72;
  }

  static const List<String> _trackingStatuses = [
    'Diproses',
    'Dikemas',
    'Dikirim',
    'Sampai',
    'Selesai',
  ];

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
