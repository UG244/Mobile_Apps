import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../checkout/db/order_db.dart';
import '../models/app_notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotificationModel> notifications = [];
  String selectedType = 'Semua';
  bool isLoading = false;
  int? userId;
  String targetRole = 'user';

  List<String> get categories => const [
    'Semua',
    'Pesanan',
    'Promo',
    'Produk',
    'Informasi',
  ];

  List<AppNotificationModel> get filteredNotifications {
    if (selectedType == 'Semua') return notifications;
    return notifications.where((item) => item.type == selectedType).toList();
  }

  int get unreadCount => notifications.where((item) => !item.isRead).length;

  Future<void> configureForUser(int id) async {
    userId = id;
    targetRole = 'user';
    await loadNotifications();
  }

  Future<void> configureForAdmin() async {
    userId = null;
    targetRole = 'admin';
    await loadNotifications();
  }

  void clearScope() {
    userId = null;
    targetRole = 'user';
    notifications = [];
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();

    notifications = await OrderDb.instance.getNotifications(
      userId: userId,
      targetRole: targetRole,
    );

    isLoading = false;
    notifyListeners();
  }

  void setFilter(String type) {
    selectedType = type;
    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String description,
    required String type,
    bool showPush = true,
    int? userId,
    String? targetRole,
  }) async {
    final notification = AppNotificationModel(
      title: title,
      description: description,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
      userId: userId ?? this.userId,
      targetRole: targetRole ?? this.targetRole,
    );

    final id = await OrderDb.instance.insertAppNotification(notification);
    notification.id = id;
    if (_belongsToCurrentScope(notification)) {
      notifications = [notification, ...notifications];
    }

    final prefs = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool('app_notifications_enabled') ?? true;
    if (showPush && pushEnabled) {
      await NotificationService.instance.showInstantNotification(
        title: title,
        body: description,
      );
    }

    notifyListeners();
  }

  Future<void> deleteNotification(int id) async {
    await OrderDb.instance.deleteNotification(id);
    notifications.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    await OrderDb.instance.markNotificationAsRead(id);
    final index = notifications.indexWhere((item) => item.id == id);
    if (index >= 0) {
      notifications[index].isRead = true;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await OrderDb.instance.markAllNotificationsAsRead(
      userId: userId,
      targetRole: targetRole,
    );
    for (final item in notifications) {
      item.isRead = true;
    }
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    await OrderDb.instance.clearAllNotifications(
      userId: userId,
      targetRole: targetRole,
    );
    notifications = [];
    notifyListeners();
  }

  int getUnreadCount() => unreadCount;

  Color getTypeColor(String type) {
    if (type == 'Promo') return const Color(0xFF7B1FA2);
    if (type == 'Produk') return const Color(0xFF00897B);
    if (type == 'Informasi') return const Color(0xFF546E7A);
    return const Color(0xFF1565C0);
  }

  IconData getTypeIcon(String type) {
    if (type == 'Promo') return Icons.card_giftcard_outlined;
    if (type == 'Produk') return Icons.shopping_bag_outlined;
    if (type == 'Informasi') return Icons.campaign_outlined;
    return Icons.receipt_long_outlined;
  }

  Future<void> addDemoNotifications() async {
    await addNotification(
      title: 'Promo Spesial Hari Ini',
      description: 'Diskon hingga 50% untuk semua kategori.',
      type: 'Promo',
    );
    await addNotification(
      title: 'Voucher Baru',
      description: 'Voucher Rp20.000 berhasil ditambahkan.',
      type: 'Promo',
    );
    await addNotification(
      title: 'Flash Sale Dimulai',
      description: 'Jangan lewatkan promo 2 jam lagi.',
      type: 'Promo',
    );
  }

  bool _belongsToCurrentScope(AppNotificationModel notification) {
    if (targetRole == 'admin') {
      return notification.targetRole == 'admin' ||
          notification.targetRole == 'all';
    }
    return notification.userId == userId || notification.targetRole == 'all';
  }
}
