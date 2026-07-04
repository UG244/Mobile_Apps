import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // [TAMBAH] State Management

// [TAMBAH] Import providers
import '../../cart/providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
// [TAMBAH] Import screen tujuan navigasi
import '../screens/product_detail_screen.dart';
// [TAMBAH] Import widget ProductCard
import '../widgets/cart_notification_overlay.dart';
import '../widgets/product_card.dart';

/// ProductListScreen — desain UI kamu dipertahankan, logika diinjeksi.
///
/// [UBAH] StatelessWidget → StatefulWidget karena:
///   1. TextEditingController untuk search field
///   2. Focus management pada TextField
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // [TAMBAH] Controller untuk mengelola teks pada search field
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    // [LOGIKA] Buang controller saat screen di-dispose agar tidak memory leak
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // [TAMBAH] Ambil data dari providers menggunakan context.watch
    final productProvider = context.watch<ProductProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final cartProvider = context
        .watch<CartProvider>(); // [FIJI] CartProvider Fiji

    // [LOGIKA] Produk yang ditampilkan = hasil filter+search dari provider
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // [TETAP]
        elevation: 0, // [TETAP]
        title: Container(
          height: 45, // [TETAP]
          decoration: BoxDecoration(
            color: Colors.grey[200], // [TETAP]
            borderRadius: BorderRadius.circular(10), // [TETAP]
          ),
          child: TextField(
            controller: _searchController, // [TAMBAH] hubungkan controller
            // [TAMBAH] Event saat teks berubah → panggil search di provider
            onChanged: (query) {
              productProvider.search(query); // [LOGIKA] filter produk realtime
            },
            decoration: InputDecoration(
              hintText: 'Cari produk...', // [TETAP]
              prefixIcon: const Icon(Icons.search), // [TETAP]
              border: InputBorder.none, // [TETAP]
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
              ), // [TETAP]
              // [TAMBAH] Tombol X untuk membersihkan search
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear(); // [LOGIKA] bersihkan field
                        productProvider
                            .clearSearch(); // [LOGIKA] reset filter provider
                        setState(
                          () {},
                        ); // [LOGIKA] rebuild untuk hilangkan icon X
                      },
                    )
                  : null,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black), // [TETAP]
            // [UBAH] onPressed dulu kosong → kini tampilkan bottom sheet filter
            onPressed: () => _showFilterSheet(context, productProvider),
          ),
        ],
      ),
      body: productProvider.isLoading
          // [TAMBAH] Loading indicator saat data dimuat
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
          // [TAMBAH] Tampilan kosong jika tidak ada hasil pencarian
          ? _buildEmptyState(productProvider)
          : GridView.builder(
              padding: const EdgeInsets.all(16), // [TETAP]
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // [TETAP]
                mainAxisExtent: 292,
                mainAxisSpacing: 12, // [TETAP]
                crossAxisSpacing: 12, // [TETAP]
              ),
              // [UBAH] itemCount dari hardcode 6 → jumlah hasil filter
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index]; // [TAMBAH] ambil produk

                return ProductCard(
                  product: product, // [UBAH] dari static String → ProductModel
                  // [LOGIKA] Cek favorit dari FavoriteProvider
                  isFavorite: favoriteProvider.isFavorite(product.id),
                  // [TAMBAH] Navigasi ke ProductDetailScreen saat card di-tap
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  ),
                  // [FIJI INTEGRATION] Toggle favorit via FavoriteProvider
                  onFavoriteTap: () => favoriteProvider.toggleFavorite(product),
                  // [FIJI INTEGRATION] Tambah ke keranjang via CartProvider Fiji
                  onAddToCart: () {
                    // [FIJI] Panggil addItem() milik CartProvider Fiji
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
    );
  }

  // ── [TAMBAH] Tampilan saat tidak ada produk ditemukan ─────────────────────
  Widget _buildEmptyState(ProductProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Produk tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // [LOGIKA] Reset semua filter & search
              _searchController.clear();
              provider.clearSearch();
              provider.filterByCategory(null);
            },
            child: const Text('Reset pencarian'),
          ),
        ],
      ),
    );
  }

  // ── [TAMBAH] Bottom Sheet Filter Kategori ─────────────────────────────────
  void _showFilterSheet(BuildContext context, ProductProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Kategori',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // [LOGIKA] Tombol "Semua" untuk reset filter — ganti ListTile checkmark
              ListTile(
                title: const Text('Semua Produk'),
                trailing: provider.selectedCategoryId == null
                    ? const Icon(Icons.check, color: Color(0xFF0A5EB0))
                    : null,
                onTap: () {
                  provider.filterByCategory(null); // [LOGIKA] reset filter
                  Navigator.pop(context);
                },
              ),
              // [LOGIKA] Tampilkan pilihan per kategori dari ProductProvider
              ...provider.categories.map(
                (cat) => ListTile(
                  title: Text(cat.name),
                  trailing: provider.selectedCategoryId == cat.id
                      ? const Icon(Icons.check, color: Color(0xFF0A5EB0))
                      : null,
                  onTap: () {
                    provider.filterByCategory(cat.id); // [LOGIKA] filter
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
