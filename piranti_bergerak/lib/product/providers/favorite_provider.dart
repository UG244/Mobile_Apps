import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

/// Provider untuk fitur Favorit.
///
/// Saat ini menggunakan `Set<String>` in-memory (tidak persisten antar sesi).
/// [TODO-DB] Nanti hubungkan ke ProductDb.instance.toggleFavorite() dan
/// ProductDb.instance.getFavoriteIds() agar data bertahan setelah app restart.
class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider();

  /// Set berisi ID produk yang difavoritkan
  final Set<String> _favoriteIds = {};

  /// Daftar produk favorit (diisi setelah toggleFavorite dipanggil)
  final List<ProductModel> _favoriteProducts = [];

  // ── Getters ───────────────────────────────────────────────────────────────

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  List<ProductModel> get favoriteProducts =>
      List.unmodifiable(_favoriteProducts);

  bool get isEmpty => _favoriteProducts.isEmpty;

  int get count => _favoriteProducts.length;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Cek apakah produk dengan [productId] sudah difavoritkan
  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  /// Toggle status favorit sebuah produk.
  ///
  /// [TODO-DB] Tambahkan di sini:
  ///   await ProductDb.instance.toggleFavorite(product.id);
  void toggleFavorite(ProductModel product) {
    if (_favoriteIds.contains(product.id)) {
      _favoriteIds.remove(product.id);
      _favoriteProducts.removeWhere((p) => p.id == product.id);
    } else {
      _favoriteIds.add(product.id);
      _favoriteProducts.add(product);
    }
    notifyListeners();
  }

  /// Hapus semua favorit
  void clearAll() {
    _favoriteIds.clear();
    _favoriteProducts.clear();
    notifyListeners();
  }
}
