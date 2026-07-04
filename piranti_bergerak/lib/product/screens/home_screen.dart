import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/favorite_screen.dart';
import '../widgets/product_card.dart';

/// ProductHomeScreen — Shell navigasi utama aplikasi.
///
/// Menggunakan [IndexedStack] agar BottomNavigationBar SELALU terlihat
/// di semua tab (Home, Search, Favorite, Profile).
class ProductHomeScreen extends StatefulWidget {
  const ProductHomeScreen({super.key});

  @override
  State<ProductHomeScreen> createState() => _ProductHomeScreenState();
}

class _ProductHomeScreenState extends State<ProductHomeScreen> {
  final PageController _pageController = PageController();
  int _bannerIndex = 0;
  int _navIndex = 0; // tab aktif
  Timer? _bannerTimer;

  static const _banners = [
    _BannerData(
      title: '🔥 Flash Sale Hari Ini',
      subtitle: 'Diskon hingga 50% untuk produk pilihan',
      colors: [Color(0xFF0A5EB0), Color(0xFF64B5F6)],
    ),
    _BannerData(
      title: '🎧 Audio Week',
      subtitle: 'Headphone & Speaker terbaik',
      colors: [Color(0xFF006064), Color(0xFF4DD0E1)],
    ),
    _BannerData(
      title: '💻 Laptop Sale',
      subtitle: 'Laptop terbaru, harga terjangkau',
      colors: [Color(0xFF4A148C), Color(0xFFBA68C8)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextPage = (_bannerIndex + 1) % _banners.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    // ─────────────────────────────────────────────────────────────────────
    // PERBAIKAN NAVIGASI: Satu Scaffold dengan BottomNav.
    // Body menggunakan IndexedStack → semua tab tersimpan di memory,
    // hanya tab aktif yang terlihat. BottomNav SELALU tampil.
    // ─────────────────────────────────────────────────────────────────────
    return Scaffold(
      // AppBar hanya muncul di tab Home (index 0).
      // Tab lain (Search, Favorite) punya AppBar sendiri di dalam Scaffold mereka.
      appBar: _navIndex == 0
          ? AppBar(
              title: const Text(
                'ShopEase',
                style: TextStyle(
                    color: Color(0xFF0A5EB0), fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {}),
                // [FIJI INTEGRATION] Cart icon + badge → CartScreen Fiji
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/cart'),
                    ),
                    if (cartProvider.totalItems > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '${cartProvider.totalItems}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              backgroundColor: Colors.white,
              elevation: 0,
            )
          : null, // tab lain handle AppBar sendiri

      // ── IndexedStack: render semua tab, tampilkan sesuai _navIndex ────────
      body: IndexedStack(
        index: _navIndex,
        children: [
          // ── Tab 0: Home ───────────────────────────────────────────────
          _HomeTabBody(
            pageController: _pageController,
            bannerIndex: _bannerIndex,
            banners: _banners,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            // Tap kategori → filter + pindah ke tab Search
            onCategoryTap: (catId) {
              context.read<ProductProvider>().filterByCategory(catId);
              setState(() => _navIndex = 1);
            },
          ),

          // ── Tab 1: Search / Product List ─────────────────────────────
          // ProductListScreen adalah Scaffold penuh dengan AppBar sendiri
          const ProductListScreen(),

          // ── Tab 2: Favorite ───────────────────────────────────────────
          // FavoriteScreen adalah Scaffold penuh dengan AppBar sendiri
          const FavoriteScreen(),

          // ── Tab 3: Profile (placeholder) ─────────────────────────────
          const _ProfileTab(),
        ],
      ),

      // ── BottomNavigationBar — sekarang SELALU tampil di semua tab ─────────
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0A5EB0),
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 0 — Konten Home (tanpa Scaffold, AppBar sudah di ProductHomeScreen)
// ─────────────────────────────────────────────────────────────────────────────

class _HomeTabBody extends StatelessWidget {
  const _HomeTabBody({
    required this.pageController,
    required this.bannerIndex,
    required this.banners,
    required this.onPageChanged,
    required this.onCategoryTap,
  });

  final PageController pageController;
  final int bannerIndex;
  final List<_BannerData> banners;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final cartProvider = context.watch<CartProvider>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner Promo ────────────────────────────────────────────────
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: pageController,
              itemCount: banners.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: banner.colors),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(banner.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(banner.subtitle,
                            style: TextStyle(
                                color: Colors.white.withAlpha(210),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Dot indicator banner ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              final isActive = i == bannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF0A5EB0)
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // ── Kategori ───────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: productProvider.categories.map((cat) {
                return _CategoryItem(
                  label: cat.name,
                  icon: _iconFromName(cat.iconName),
                  // Tap kategori → filter produk + pindah ke tab Search
                  onTap: () => onCategoryTap(cat.id),
                );
              }).toList(),
            ),
          ),

          // ── Rekomendasi Produk ─────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Rekomendasi',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          if (productProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: productProvider.featuredProducts.length,
              itemBuilder: (context, index) {
                final product = productProvider.featuredProducts[index];

                return ProductCard(
                  product: product,
                  isFavorite: favoriteProvider.isFavorite(product.id),
                  // [NAVIGASI] Tap card → ProductDetailScreen (push, bisa back)
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailScreen(product: product),
                    ),
                  ),
                  // [FIJI INTEGRATION] Toggle favorit
                  onFavoriteTap: () =>
                      favoriteProvider.toggleFavorite(product),
                  // [FIJI INTEGRATION] Tambah ke CartProvider Fiji
                  onAddToCart: () {
                    cartProvider.addItem(product.toCartItem());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${product.name} ditambahkan ke keranjang'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                );
              },
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Profile (placeholder sederhana)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil',
            style: TextStyle(
                color: Color(0xFF0A5EB0), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.person, size: 48, color: Color(0xFF0A5EB0)),
            ),
            const SizedBox(height: 16),
            const Text('Pengguna ShopEase',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('user@shopease.com',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            // [FIJI INTEGRATION] Shortcut ke Riwayat Pesanan milik Fiji
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined,
                  color: Color(0xFF0A5EB0)),
              title: const Text('Riwayat Pesanan'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed('/orders'),
            ),
            // [FIJI INTEGRATION] Shortcut ke Cart milik Fiji
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined,
                  color: Color(0xFF0A5EB0)),
              title: const Text('Keranjang Saya'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed('/cart'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget _CategoryItem
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _CategoryItem({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[50],
              child: Icon(icon, color: const Color(0xFF0A5EB0)),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data banner
// ─────────────────────────────────────────────────────────────────────────────

class _BannerData {
  const _BannerData(
      {required this.title, required this.subtitle, required this.colors});
  final String title;
  final String subtitle;
  final List<Color> colors;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: String iconName → IconData
// ─────────────────────────────────────────────────────────────────────────────

IconData _iconFromName(String name) {
  const map = <String, IconData>{
    'laptop_mac': Icons.laptop_mac,
    'smartphone': Icons.smartphone,
    'headphones': Icons.headphones,
    'sports_esports': Icons.sports_esports,
    'cable': Icons.cable,
    'storage': Icons.storage,
  };
  return map[name] ?? Icons.category;
}
