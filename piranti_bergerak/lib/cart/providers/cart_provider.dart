import 'package:flutter/foundation.dart';

import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  CartProvider() {
    _items = _createDummyItems();
  }

  late final List<CartItemModel> _items;

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

  void refillCart() {
    _items.clear();
    _items.addAll(_createDummyItems());
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

  static List<CartItemModel> _createDummyItems() {
    return [
      CartItemModel(
        id: 'p1',
        name: 'Headphone Wireless',
        category: 'Elektronik',
        imageUrl: 'https://via.placeholder.com/120x120.png?text=Headphone',
        price: 185000,
        quantity: 1,
      ),
      CartItemModel(
        id: 'p2',
        name: 'Smartphone Case',
        category: 'Aksesoris',
        imageUrl: 'https://via.placeholder.com/120x120.png?text=Case',
        price: 75000,
        quantity: 2,
      ),
      CartItemModel(
        id: 'p3',
        name: 'Power Bank 20K',
        category: 'Elektronik',
        imageUrl: 'https://via.placeholder.com/120x120.png?text=Power+Bank',
        price: 225000,
        quantity: 1,
      ),
      CartItemModel(
        id: 'p4',
        name: 'Wireless Mouse',
        category: 'Aksesoris',
        imageUrl: 'https://via.placeholder.com/120x120.png?text=Mouse',
        price: 98000,
        quantity: 1,
      ),
      CartItemModel(
        id: 'p5',
        name: 'Bluetooth Speaker',
        category: 'Elektronik',
        imageUrl: 'https://via.placeholder.com/120x120.png?text=Speaker',
        price: 320000,
        quantity: 1,
      ),
    ];
  }
}
