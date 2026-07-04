import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';

/// Provider untuk semua data produk dan kategori.
///
/// Saat ini menggunakan dummy data statis.
/// [TODO-DB] Nanti ganti pemanggilan dummy data dengan query dari ProductDb
/// ketika layer database sudah siap.
class ProductProvider extends ChangeNotifier {
  ProductProvider() {
    _loadDummyData();
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
    final sorted = [..._allProducts]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  }

  /// Produk baru (4 produk pertama) untuk seksi "Baru Tiba" di Home
  List<ProductModel> get newArrivals => _allProducts.take(4).toList();

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

  /// [TODO-DB] Nanti ganti dengan: await ProductDb.instance.getAll()
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500)); // simulasi async
    _loadDummyData();
    _isLoading = false;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _applyFilter() {
    var result = [..._allProducts];

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

  /// [TODO-DB] Ganti metode ini dengan query dari ProductDb dan CategoryDb:
  ///   _categories = await ProductDb.instance.getCategories();
  ///   _allProducts = await ProductDb.instance.getProducts();
  void _loadDummyData() {
    _categories = _buildCategories();
    _allProducts = _buildProducts();
    _filteredProducts = [..._allProducts];
  }

  static List<CategoryModel> _buildCategories() {
    return [
      CategoryModel(
        id: 'cat_laptop',
        name: 'Laptop',
        iconName: 'laptop_mac',
        color: 0xFF1565C0,
      ),
      CategoryModel(
        id: 'cat_phone',
        name: 'Smartphone',
        iconName: 'smartphone',
        color: 0xFF6A1B9A,
      ),
      CategoryModel(
        id: 'cat_audio',
        name: 'Audio',
        iconName: 'headphones',
        color: 0xFF00838F,
      ),
      CategoryModel(
        id: 'cat_gaming',
        name: 'Gaming',
        iconName: 'sports_esports',
        color: 0xFFE65100,
      ),
      CategoryModel(
        id: 'cat_aksesoris',
        name: 'Aksesoris',
        iconName: 'cable',
        color: 0xFF2E7D32,
      ),
      CategoryModel(
        id: 'cat_storage',
        name: 'Storage',
        iconName: 'storage',
        color: 0xFFC62828,
      ),
    ];
  }

  static List<ProductModel> _buildProducts() {
    return [
      // ── Laptop ──────────────────────────────────────────────────────────
      ProductModel(
        id: 'prod_001',
        name: 'ASUS VivoBook 15 OLED',
        description:
            'Laptop tipis dengan layar OLED 15,6 inci yang memukau. Ditenagai prosesor AMD Ryzen 5 7530U dengan RAM 16GB DDR4 dan SSD 512GB NVMe. Ideal untuk pelajar, profesional kreatif, dan multitasking sehari-hari.',
        price: 8_999_000,
        originalPrice: 10_499_000,
        imageUrl:
            'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400&h=300&fit=crop',
        categoryId: 'cat_laptop',
        categoryName: 'Laptop',
        rating: 4.7,
        reviewCount: 284,
        stock: 12,
      ),
      ProductModel(
        id: 'prod_002',
        name: 'Lenovo IdeaPad Slim 5 Gen 9',
        description:
            'Laptop bisnis ultra-slim dengan Intel Core i7-13700H, RAM 16GB, dan SSD 1TB. Layar IPS 14 inci Full HD dengan anti-glare coating. Baterai tahan hingga 12 jam pemakaian normal.',
        price: 11_499_000,
        originalPrice: 11_499_000,
        imageUrl:
            'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400&h=300&fit=crop',
        categoryId: 'cat_laptop',
        categoryName: 'Laptop',
        rating: 4.5,
        reviewCount: 196,
        stock: 8,
      ),
      ProductModel(
        id: 'prod_003',
        name: 'MacBook Air M2 13"',
        description:
            'MacBook Air dengan chip Apple M2, layar Liquid Retina 13,6 inci, RAM 8GB Unified Memory, dan SSD 256GB. Desain tanpa kipas — senyap total. Baterai hingga 18 jam.',
        price: 16_999_000,
        originalPrice: 18_500_000,
        imageUrl:
            'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=400&h=300&fit=crop',
        categoryId: 'cat_laptop',
        categoryName: 'Laptop',
        rating: 4.9,
        reviewCount: 512,
        stock: 5,
      ),

      // ── Smartphone ──────────────────────────────────────────────────────
      ProductModel(
        id: 'prod_004',
        name: 'Samsung Galaxy S24 FE',
        description:
            'Smartphone flagship dengan layar Dynamic AMOLED 6,7 inci 120Hz, kamera utama 50MP OIS, dan baterai 4.700 mAh. Didukung AI Galaxy fitur generatif terbaru.',
        price: 7_499_000,
        originalPrice: 8_999_000,
        imageUrl:
            'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=400&h=300&fit=crop',
        categoryId: 'cat_phone',
        categoryName: 'Smartphone',
        rating: 4.6,
        reviewCount: 341,
        stock: 20,
      ),
      ProductModel(
        id: 'prod_005',
        name: 'Xiaomi 14T Pro',
        description:
            'Ponsel dengan kamera Leica triple 50MP, layar AMOLED 6,67 inci 144Hz, dan pengisian cepat HyperCharge 120W. Chipset MediaTek Dimensity 9300+ performa kelas flagship.',
        price: 9_299_000,
        originalPrice: 9_299_000,
        imageUrl:
            'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&h=300&fit=crop',
        categoryId: 'cat_phone',
        categoryName: 'Smartphone',
        rating: 4.4,
        reviewCount: 178,
        stock: 15,
      ),

      // ── Audio ────────────────────────────────────────────────────────────
      ProductModel(
        id: 'prod_006',
        name: 'Sony WH-1000XM5',
        description:
            'Headphone over-ear nirkabel dengan Active Noise Cancelling terdepan di industri. Didukung 8 mikrofon, dua prosesor audio, dan baterai 30 jam. Kualitas suara Hi-Res Audio certified.',
        price: 3_999_000,
        originalPrice: 5_200_000,
        imageUrl:
            'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400&h=300&fit=crop',
        categoryId: 'cat_audio',
        categoryName: 'Audio',
        rating: 4.8,
        reviewCount: 763,
        stock: 30,
      ),
      ProductModel(
        id: 'prod_007',
        name: 'JBL Charge 5 Speaker',
        description:
            'Speaker Bluetooth portabel tahan air IP67 dengan suara bass yang kuat. Kapasitas baterai 7.500 mAh bisa mengisi perangkat lain. Terhubung hingga 3 speaker sekaligus.',
        price: 1_899_000,
        originalPrice: 2_299_000,
        imageUrl:
            'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=300&fit=crop',
        categoryId: 'cat_audio',
        categoryName: 'Audio',
        rating: 4.5,
        reviewCount: 432,
        stock: 25,
      ),

      // ── Gaming ───────────────────────────────────────────────────────────
      ProductModel(
        id: 'prod_008',
        name: 'Logitech G502 X Plus',
        description:
            'Mouse gaming nirkabel dengan sensor HERO 25K, 13 tombol yang dapat diprogram, dan lampu RGB LIGHTFORCE. Klik mekanis optik untuk respons ultra-cepat tanpa lag.',
        price: 1_299_000,
        originalPrice: 1_599_000,
        imageUrl:
            'https://images.unsplash.com/photo-1527814050087-3793815479db?w=400&h=300&fit=crop',
        categoryId: 'cat_gaming',
        categoryName: 'Gaming',
        rating: 4.7,
        reviewCount: 289,
        stock: 40,
      ),
      ProductModel(
        id: 'prod_009',
        name: 'Razer BlackWidow V4',
        description:
            'Keyboard gaming mekanikal dengan switch Razer Green tactile & clicky. Dilengkapi wrist rest magnetik, lampu Chroma RGB per-key, dan anti-ghosting penuh 6KRO.',
        price: 1_799_000,
        originalPrice: 1_799_000,
        imageUrl:
            'https://images.unsplash.com/photo-1541140532154-b024d705b90a?w=400&h=300&fit=crop',
        categoryId: 'cat_gaming',
        categoryName: 'Gaming',
        rating: 4.6,
        reviewCount: 157,
        stock: 18,
      ),

      // ── Aksesoris ────────────────────────────────────────────────────────
      ProductModel(
        id: 'prod_010',
        name: 'Anker 735 GaN Charger 65W',
        description:
            'Charger GaN 3-port (2 USB-C + 1 USB-A) dengan daya total 65W. Teknologi PowerIQ 4.0 menyesuaikan pengisian daya otomatis. Ukuran 40% lebih kecil dari charger standar.',
        price: 429_000,
        originalPrice: 599_000,
        imageUrl:
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
        categoryId: 'cat_aksesoris',
        categoryName: 'Aksesoris',
        rating: 4.8,
        reviewCount: 621,
        stock: 60,
      ),

      // ── Storage ──────────────────────────────────────────────────────────
      ProductModel(
        id: 'prod_011',
        name: 'Samsung 870 EVO SSD 1TB',
        description:
            'SSD SATA 2.5 inci dengan kecepatan baca 560 MB/s dan tulis 530 MB/s. Kapasitas 1TB cocok untuk upgrade laptop lama. Garansi 5 tahun resmi Samsung Indonesia.',
        price: 1_099_000,
        originalPrice: 1_399_000,
        imageUrl:
            'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=400&h=300&fit=crop',
        categoryId: 'cat_storage',
        categoryName: 'Storage',
        rating: 4.9,
        reviewCount: 1023,
        stock: 35,
      ),
      ProductModel(
        id: 'prod_012',
        name: 'WD My Passport 2TB',
        description:
            'Hard drive eksternal portabel dengan kapasitas 2TB dan enkripsi hardware AES 256-bit. Antarmuka USB-C 3.2 Gen 1 dengan kecepatan transfer hingga 400 MB/s. Tersedia dalam 5 warna.',
        price: 699_000,
        originalPrice: 849_000,
        imageUrl:
            'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=400&h=300&fit=crop',
        categoryId: 'cat_storage',
        categoryName: 'Storage',
        rating: 4.4,
        reviewCount: 387,
        stock: 22,
      ),
    ];
  }
}
