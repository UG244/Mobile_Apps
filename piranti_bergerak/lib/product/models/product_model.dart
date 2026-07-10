import '../../cart/models/cart_item_model.dart';

/// Model utama untuk sebuah Produk.
///
/// Field `id` (String) digunakan sebagai `productId` di [CartItemModel] milik Fiji,
/// sehingga data produk bisa dilacak di history Order.
class ProductModel {
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stock = 0,
    this.weight = 0,
    this.isActive = true,
  });

  /// ID unik produk, dipakai sebagai foreign key ke CartItemModel dan OrderDetailModel
  final String id;

  final String name;
  final String description;

  /// Harga jual saat ini (bisa sudah diskon)
  final double price;

  /// Harga asli sebelum diskon (untuk tampilan coret)
  final double originalPrice;

  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final double rating;
  final int reviewCount;
  final int stock;
  final double weight;
  final bool isActive;

  /// Apakah produk sedang dalam kondisi diskon
  bool get isOnSale => originalPrice > price;

  /// Persentase diskon (0 jika tidak ada diskon)
  int get discountPercent {
    if (!isOnSale) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// INTEGRASI FIJI: Konversi ke CartItemModel milik Fiji.
  ///
  /// Panggil method ini saat tombol "Add to Cart" ditekan:
  ///   final cartItem = product.toCartItem();
  ///   `Provider.of<CartProvider>(context, listen: false).addItem(cartItem);`
  ///                                                     ^^^^^^^^^^^^^^^^^^^
  ///   [KOORDINASI FIJI] Fiji perlu menambahkan method addItem(CartItemModel)
  ///   ke CartProvider (lib/cart/providers/cart_provider.dart).
  /// ─────────────────────────────────────────────────────────────────────────
  CartItemModel toCartItem({int quantity = 1}) {
    return CartItemModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity,
      category: categoryName,
      stock: stock,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'weight': weight,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> m) {
    return ProductModel(
      id: m['id'] as String,
      name: m['name'] as String,
      description: m['description'] as String,
      price: (m['price'] as num).toDouble(),
      originalPrice: (m['originalPrice'] as num).toDouble(),
      imageUrl: m['imageUrl'] as String,
      categoryId: m['categoryId'] as String,
      categoryName: m['categoryName'] as String,
      rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: m['reviewCount'] as int? ?? 0,
      stock: m['stock'] as int? ?? 0,
      weight: (m['weight'] as num?)?.toDouble() ?? 0,
      isActive: (m['isActive'] as int? ?? 1) == 1,
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? categoryId,
    String? categoryName,
    double? rating,
    int? reviewCount,
    int? stock,
    double? weight,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      weight: weight ?? this.weight,
      isActive: isActive ?? this.isActive,
    );
  }
}
