import 'package:flutter/material.dart';
import '../../cart/providers/cart_provider.dart';
import '../models/checkout_address_model.dart';
import '../models/order_model.dart';
import '../models/order_detail_model.dart';
import '../db/order_db.dart';
import '../../notification/services/notification_service.dart';
import '../../product/db/product_db.dart';
import '../../product/providers/product_provider.dart';

class CheckoutStockException implements Exception {
  const CheckoutStockException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider(this.cart) {
    Future.microtask(loadAddresses);
  }

  final CartProvider cart;

  // Shipping methods
  String shippingMethod = 'Reguler';
  double shippingCost = 20000;

  // Payment
  String paymentMethod = 'QRIS';

  // Promo
  String? appliedPromoCode;
  String? appliedPromoName;
  bool freeShipping = false;
  double promoDiscount = 0;

  // Address fields
  String customerName = '';
  String phone = '';
  String address = '';
  String note = '';
  int? selectedAddressId;
  bool isLoadingAddresses = false;
  List<CheckoutAddressModel> addresses = [];

  CheckoutAddressModel? get selectedAddress {
    if (selectedAddressId == null) return null;
    final index = addresses.indexWhere((item) => item.id == selectedAddressId);
    if (index < 0) return null;
    return addresses[index];
  }

  String get shippingEstimate {
    if (shippingMethod == 'Express') return 'Estimasi tiba 1-2 hari';
    if (shippingMethod == 'Same Day') return 'Estimasi tiba hari ini';
    return 'Estimasi tiba 2-4 hari';
  }

  void setShipping(String method) {
    shippingMethod = method;
    if (method == 'Reguler') shippingCost = 20000;
    if (method == 'Express') shippingCost = 35000;
    if (method == 'Same Day') shippingCost = 50000;
    notifyListeners();
  }

  void setPayment(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  bool applyPromo(String code) {
    final promoCode = code.trim().toUpperCase();
    if (promoCode == 'ONGKIR0') {
      appliedPromoCode = promoCode;
      appliedPromoName = 'Gratis Ongkir';
      freeShipping = true;
      promoDiscount = 0;
      notifyListeners();
      return true;
    }
    if (promoCode == 'BLUEMART10') {
      appliedPromoCode = promoCode;
      appliedPromoName = 'Potongan 10%';
      freeShipping = false;
      promoDiscount = subtotal * 0.10;
      notifyListeners();
      return true;
    }
    if (promoCode == 'HEMAT50') {
      appliedPromoCode = promoCode;
      appliedPromoName = 'Potongan Rp 50.000';
      freeShipping = false;
      promoDiscount = subtotal < 50000 ? subtotal : 50000;
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearPromo() {
    appliedPromoCode = null;
    appliedPromoName = null;
    freeShipping = false;
    promoDiscount = 0;
    notifyListeners();
  }

  Future<void> loadAddresses() async {
    isLoadingAddresses = true;
    notifyListeners();

    try {
      addresses = await OrderDb.instance.getCheckoutAddresses();
    } catch (_) {
      addresses = [];
    }

    isLoadingAddresses = false;
    notifyListeners();
  }

  void selectAddress(CheckoutAddressModel item) {
    final index = addresses.indexWhere((address) => address.id == item.id);
    if (index < 0) {
      addresses = [item, ...addresses];
    } else {
      addresses[index] = item;
    }
    selectedAddressId = item.id;
    customerName = item.recipientName;
    phone = item.phone;
    address = item.address;
    note = item.note;
    notifyListeners();
  }

  Future<CheckoutAddressModel> saveAddress({
    required String recipientName,
    required String phone,
    required String address,
    required String note,
  }) async {
    final item = CheckoutAddressModel(
      recipientName: recipientName.trim(),
      phone: phone.trim(),
      address: address.trim(),
      note: note.trim(),
      createdAt: DateTime.now(),
    );
    final id = await OrderDb.instance.insertCheckoutAddress(item);
    item.id = id;
    addresses = [item, ...addresses];
    selectAddress(item);
    return item;
  }

  Future<void> addCheckoutNotification({
    required String title,
    required String message,
    String type = 'Pesanan',
    int? userId,
    String targetRole = 'user',
  }) async {
    try {
      await OrderDb.instance.insertNotification(
        title: title,
        message: message,
        type: type,
        date: DateTime.now(),
        userId: userId,
        targetRole: targetRole,
      );
      await NotificationService.instance.showInstantNotification(
        title: title,
        body: message,
      );
    } catch (_) {
      // Notification storage should not block the checkout UI.
    }
  }

  double get subtotal => cart.subtotal;

  double get discount {
    if (appliedPromoCode == 'BLUEMART10') return subtotal * 0.10;
    if (appliedPromoCode == 'HEMAT50') {
      return subtotal < 50000 ? subtotal : 50000;
    }
    return promoDiscount;
  }

  double get finalShippingCost => freeShipping ? 0 : shippingCost;

  double get tax => ((subtotal - discount + finalShippingCost) * 0.11);

  double get grandTotal => subtotal - discount + finalShippingCost + tax;

  bool validate() {
    return cart.items.isNotEmpty &&
        customerName.trim().isNotEmpty &&
        phone.trim().isNotEmpty &&
        address.trim().isNotEmpty;
  }

  Future<int> placeOrder({
    ProductProvider? productProvider,
    int? userId,
  }) async {
    await _syncCartWithLatestStock();
    if (cart.items.isEmpty) {
      throw const CheckoutStockException(
        'Produk di keranjang sudah tidak tersedia.',
      );
    }

    final invoice = 'INV-${DateTime.now().millisecondsSinceEpoch}';
    final orderDate = DateTime.now();
    final order = OrderModel(
      userId: userId,
      invoice: invoice,
      customerName: customerName,
      phone: phone,
      address: address,
      note: note,
      paymentMethod: paymentMethod,
      shippingMethod: shippingMethod,
      subtotal: subtotal,
      shippingCost: finalShippingCost,
      discount: discount,
      tax: tax,
      grandTotal: grandTotal,
      date: orderDate,
    );

    final details = cart.items
        .map(
          (c) => OrderDetailModel(
            orderId: 0,
            productId: c.id,
            name: c.name,
            price: c.price,
            quantity: c.quantity,
            total: c.subtotal,
            imageUrl: c.imageUrl,
          ),
        )
        .toList();

    await ProductDb.instance.reduceStock({
      for (final item in cart.items) item.id: item.quantity,
    });

    final id = await OrderDb.instance.insertOrder(order, details);
    final itemCount = cart.totalItems;
    final shortAddress = address.length > 48
        ? '${address.substring(0, 48)}...'
        : address;
    final message =
        '$invoice berhasil dibuat. Status: Diproses. '
        '$itemCount item sedang kami siapkan untuk dikirim via $shippingMethod '
        '($shippingEstimate) ke $shortAddress. '
        'Cek Riwayat Pesanan untuk melihat posisi pesanan terbaru.';

    try {
      await OrderDb.instance.insertNotification(
        title: 'Pesanan $invoice Diproses',
        message: message,
        type: 'Pesanan',
        date: orderDate,
        userId: userId,
        targetRole: 'user',
      );
      await OrderDb.instance.insertNotification(
        title: 'Pesanan Baru $invoice',
        message:
            '${customerName.trim()} membuat pesanan $itemCount item senilai Rp ${grandTotal.toStringAsFixed(0)}.',
        type: 'Pesanan',
        date: orderDate,
        targetRole: 'admin',
      );
      await NotificationService.instance.showInstantNotification(
        title: 'Pesanan $invoice Diproses',
        body:
            'Pesanan sedang diproses dan akan dikirim via $shippingMethod. $shippingEstimate.',
      );
    } catch (_) {
      // Pesanan dan stok tetap valid walau notifikasi lokal gagal dibuat.
    }

    cart.clearCart();
    await productProvider?.refresh();

    return id;
  }

  Future<void> _syncCartWithLatestStock() async {
    final requestedQuantities = {
      for (final item in cart.items) item.id: item.quantity,
    };
    final productsById = await ProductDb.instance.getActiveProductsByIds(
      cart.items.map((item) => item.id),
    );
    cart.syncWithProducts(productsById.values.toList());

    for (final entry in requestedQuantities.entries) {
      final product = productsById[entry.key];
      if (product == null || product.stock <= 0) {
        throw const CheckoutStockException(
          'Sebagian produk sudah tidak tersedia.',
        );
      }
      if (entry.value > product.stock) {
        throw CheckoutStockException(
          'Stok ${product.name} tersisa ${product.stock}. Jumlah di keranjang sudah disesuaikan.',
        );
      }
    }
  }
}
