import 'package:flutter/foundation.dart';

import '../db/product_db.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Provider untuk semua data produk dan kategori.
///
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
  List<ProductModel> get allActiveProducts =>
      List.unmodifiable(_activeProducts);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Produk Home: produk yang baru ditambahkan admin tampil lebih dulu,
  /// lalu produk seed tetap diurutkan dengan rating terbaik.
  List<ProductModel> get featuredProducts {
    final sorted = _activeProducts
      ..sort((a, b) {
        final recencyCompare = _productRecencyScore(
          b,
        ).compareTo(_productRecencyScore(a));
        if (recencyCompare != 0) return recencyCompare;
        return b.rating.compareTo(a.rating);
      });
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

  /// [FITUR SENSOR: SHAKE TO REFRESH]
  /// Mengacak urutan produk dan memperbarui tampilan saat perangkat diguncang.
  void refreshRandom() {
    _allProducts.shuffle();
    _applyFilter();
  }

  /// [FITUR SENSOR: BARCODE SCANNER]
  /// Mencari produk berdasarkan ID, nama, atau deskripsi yang cocok dengan hasil scan barcode/QR.
  ProductModel? findByBarcode(String barcode) {
    final query = barcode.trim().toLowerCase();
    if (query.isEmpty) return null;

    // 1. Cari exact match pada ID
    try {
      return _activeProducts.firstWhere((p) => p.id.toLowerCase() == query);
    } catch (_) {}

    // 2. Cari contains pada nama atau deskripsi atau ID
    try {
      return _activeProducts.firstWhere(
        (p) =>
            p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.id.toLowerCase().contains(query),
      );
    } catch (_) {
      return null;
    }
  }

  ProductModel? findActiveById(String id) {
    try {
      return _activeProducts.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  int _productRecencyScore(ProductModel product) {
    final parts = product.id.split('_');
    if (parts.length < 2) return 0;
    return int.tryParse(parts.last) ?? 0;
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
