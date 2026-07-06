import 'package:flutter/foundation.dart';

import '../db/product_db.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Provider untuk semua data produk dan kategori.
///
/// Saat ini menggunakan dummy data statis.
/// [TODO-DB] Nanti ganti pemanggilan dummy data dengan query dari ProductDb
/// ketika layer database sudah siap.
class ProductProvider extends ChangeNotifier {
  ProductProvider() {
    loadProducts();
  }

  List<ProductModel> _allProducts = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = '';
  String? _selectedCategoryId; // null = tampilkan semua
  bool _isLoading = false;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<ProductModel> get products => List.unmodifiable(_filteredProducts);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Produk unggulan (rating tertinggi) untuk ditampilkan di Home
  List<ProductModel> get featuredProducts {
    final sorted = _activeProducts
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  }

  /// Produk baru (4 produk pertama) untuk seksi "Baru Tiba" di Home
  List<ProductModel> get newArrivals => _activeProducts.take(4).toList();

  List<ProductModel> get _activeProducts =>
      _allProducts.where((product) => product.isActive).toList();

  // ── Actions ───────────────────────────────────────────────────────────────

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilter();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await ProductDb.instance.getCategories();
      _allProducts = await ProductDb.instance.getProducts();
      if (_categories.isEmpty || _allProducts.isEmpty) {
        _categories = ProductDb.seedCategories;
        _allProducts = ProductDb.seedProducts;
      }
    } catch (_) {
      _categories = ProductDb.seedCategories;
      _allProducts = ProductDb.seedProducts;
    }
    _isLoading = false;
    _applyFilter();
  }

  Future<void> refresh() async {
    await loadProducts();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _applyFilter() {
    var result = _activeProducts;

    // Filter berdasarkan kategori
    if (_selectedCategoryId != null) {
      result = result
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }

    // Filter berdasarkan search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.categoryName.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q),
          )
          .toList();
    }

    _filteredProducts = result;
    notifyListeners();
  }
}
