import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';
import '../../product/models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  // Shipping is a simple flat fee for demo, or 0 if subtotal above threshold
  double get shipping => subtotal > 500000 ? 0 : 20000;

  // Discount from promo (calculated)
  double _discount = 0;
  String? _appliedPromo;

  double get discount => _discount;

  double get tax => (subtotal - discount + shipping) * 0.11;

  double get grandTotal => subtotal - discount + shipping + tax;

  String? get appliedPromo => _appliedPromo;

  // ── [INTEGRASI MODUL PRODUCT] ─────────────────────────────────────────────
  // Method ini ditambahkan untuk mendukung fitur "Add to Cart" dari halaman
  // Product Detail (lib/product/screens/product_detail_screen.dart).
  // Jika produk sudah ada di keranjang, quantity-nya akan bertambah.
  // ─────────────────────────────────────────────────────────────────────────
  void addItem(CartItemModel item) {
    final index = _items.indexWhere((existing) => existing.id == item.id);
    if (index >= 0) {
      // Produk sudah ada → tambah kuantitas
      _items[index].quantity += item.quantity;
    } else {
      // Produk baru → tambahkan ke keranjang
      _items.add(item);
    }
    notifyListeners();
  }

  void increaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _items[index].quantity += 1;
    notifyListeners();
  }

  void decreaseQuantity(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final item = _items[index];
    if (item.quantity <= 1) return;
    item.quantity -= 1;
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void syncWithProducts(List<ProductModel> products) {
    final activeById = {
      for (final product in products.where((product) => product.isActive))
        product.id: product,
    };

    _items.removeWhere((item) => !activeById.containsKey(item.id));
    for (var index = 0; index < _items.length; index++) {
      final product = activeById[_items[index].id];
      if (product == null) continue;
      final quantity = _items[index].quantity > product.stock
          ? product.stock
          : _items[index].quantity;
      if (quantity <= 0) {
        _items.removeAt(index);
        index--;
        continue;
      }
      _items[index] = product.toCartItem(quantity: quantity);
    }

    notifyListeners();
  }

  void refillCart() {
    _items.clear();
    _discount = 0;
    _appliedPromo = null;
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _discount = 0;
    _appliedPromo = null;
    notifyListeners();
  }

  // Dummy promo support: BLUEMART10 => 10% off subtotal, FLAT50 => 50000 off
  bool applyPromo(String code) {
    final c = code.trim().toUpperCase();
    if (c == 'BLUEMART10') {
      _discount = subtotal * 0.10;
      _appliedPromo = c;
      notifyListeners();
      return true;
    }
    if (c == 'FLAT50') {
      _discount = 50000;
      _appliedPromo = c;
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearPromo() {
    _discount = 0;
    _appliedPromo = null;
    notifyListeners();
  }
}
