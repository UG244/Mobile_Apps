import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/providers/cart_provider.dart';
import '../../cart/utils/format_utils.dart';
import '../models/product_model.dart';
import '../providers/favorite_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _showFullDesc = false;

  ProductModel get product => widget.product;

  void _increment() {
    if (_quantity < product.stock) {
      setState(() => _quantity++);
    }
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// INTEGRASI FIJI — Fungsi "Add to Cart"
  ///
  /// Fungsi ini mengubah ProductModel menjadi CartItemModel menggunakan
  /// method toCartItem() yang sudah kita definisikan di ProductModel,
  /// lalu mengirimkannya ke CartProvider milik Fiji via addItem().
  ///
  /// [KOORDINASI FIJI] Method addItem() sudah ditambahkan ke:
  ///   lib/cart/providers/cart_provider.dart
  /// ─────────────────────────────────────────────────────────────────────────
  void _addToCart(BuildContext context) {
    // [FIJI INTEGRATION] Mengonversi product ke CartItemModel
    final cartItem = product.toCartItem(quantity: _quantity);

    // [FIJI INTEGRATION] Memanggil CartProvider.addItem() milik Fiji
    context.read<CartProvider>().addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1565C0),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${product.name} ditambahkan ke keranjang',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: const Color(0xFF90CAF9),
          onPressed: () => Navigator.of(context).pushNamed('/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    final isFav = favoriteProvider.isFavorite(product.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── SliverAppBar dengan gambar ────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A1A2E),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
            actions: [
              // Tombol Favorit di AppBar
              GestureDetector(
                onTap: () => favoriteProvider.toggleFavorite(product),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color: isFav
                        ? const Color(0xFFE53935)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              // Tombol keranjang
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/cart'),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Hero(
                  tag: 'product_${product.id}',
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF0F4FF),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF90A4AE),
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Konten detail ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.categoryName,
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Nama produk
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Rating + review + stok
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFA726),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount} ulasan)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 13,
                          color: product.stock > 10
                              ? const Color(0xFF43A047)
                              : const Color(0xFFE53935),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.stock > 0
                              ? 'Stok: ${product.stock}'
                              : 'Habis',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: product.stock > 0
                                ? const Color(0xFF43A047)
                                : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 16),

                    // Harga
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${formatNumber(product.price)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.isOnSale) ...[
                          Text(
                            'Rp ${formatNumber(product.originalPrice)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFBDBDBD),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Hemat ${product.discountPercent}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Pilih Jumlah
                    Row(
                      children: [
                        const Text(
                          'Jumlah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const Spacer(),
                        _QuantitySelector(
                          quantity: _quantity,
                          stock: product.stock,
                          onIncrement: _increment,
                          onDecrement: _decrement,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Total harga real-time
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Harga',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF616161),
                            ),
                          ),
                          Text(
                            'Rp ${formatNumber(product.price * _quantity)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 16),

                    // Deskripsi produk
                    const Text(
                      'Deskripsi Produk',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _showFullDesc
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        product.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF616161),
                          height: 1.6,
                        ),
                      ),
                      secondChild: Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF616161),
                          height: 1.6,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _showFullDesc = !_showFullDesc),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _showFullDesc ? 'Tampilkan lebih sedikit' : 'Selengkapnya',
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tombol Add to Cart
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: product.stock > 0
                            ? () => _addToCart(context)
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                        label: Text(
                          product.stock > 0
                              ? 'Tambah ke Keranjang'
                              : 'Stok Habis',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Beli Langsung
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: product.stock > 0
                            ? () {
                                _addToCart(context);
                                Navigator.of(context).pushNamed('/cart');
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1565C0),
                          side: const BorderSide(
                            color: Color(0xFF1565C0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.flash_on_rounded, size: 20),
                        label: const Text(
                          'Beli Sekarang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quantity Selector
// ─────────────────────────────────────────────────────────────────────────────

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.stock,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final int stock;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            enabled: quantity > 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          _QtyBtn(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            enabled: quantity < stock,
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFF5F7FA)
              : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? const Color(0xFF1565C0)
              : const Color(0xFFBDBDBD),
        ),
      ),
    );
  }
}
