import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../sensor/screens/barcode_scanner_screen.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/cart_notification_overlay.dart';
import '../widgets/product_card.dart';

/// ProductListScreen — Halaman Katalog & Pencarian Modern.
///
/// Dilengkapi dengan bar pencarian realtime, tombol scan barcode kamera,
/// dan filter chips horisontal yang langsung dapat digeser di bagian atas.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final cartProvider = context.watch<CartProvider>();

    final products = productProvider.products;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 16,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (query) => productProvider.search(query),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari barang di BlueMart...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        productProvider.clearSearch();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
        ),
        actions: [
          // Tombol Scan Barcode Kamera
          Container(
            margin: const EdgeInsets.only(right: 12, left: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.accent,
                size: 22,
              ),
              tooltip: 'Scan Barcode / QR',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BarcodeScannerScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Horizontal Filter Chips ─────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Chip Semua Produk
                  _buildFilterChip(
                    label: 'Semua',
                    isSelected: productProvider.selectedCategoryId == null,
                    onTap: () => productProvider.filterByCategory(null),
                  ),
                  // Chip Per Kategori
                  ...productProvider.categories.map((cat) {
                    return _buildFilterChip(
                      label: cat.name,
                      isSelected: productProvider.selectedCategoryId == cat.id,
                      onTap: () => productProvider.filterByCategory(cat.id),
                    );
                  }),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // ── Grid Produk ─────────────────────────────────────────────────
          Expanded(
            child: productProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : products.isEmpty
                ? _buildEmptyState(productProvider)
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 315,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        isFavorite: favoriteProvider.isFavorite(product.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        ),
                        onFavoriteTap: () =>
                            favoriteProvider.toggleFavorite(product),
                        onAddToCart: () {
                          cartProvider.addItem(product.toCartItem());
                          CartNotificationOverlay.show(
                            context,
                            message: '${product.name} ditambahkan ke keranjang',
                            onViewCart: () =>
                                Navigator.of(context).pushNamed('/cart'),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ProductProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 56,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Produk Tidak Ditemukan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba gunakan kata kunci lain atau pilih kategori yang berbeda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset Filter & Pencarian'),
              onPressed: () {
                _searchController.clear();
                provider.clearSearch();
                provider.filterByCategory(null);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
