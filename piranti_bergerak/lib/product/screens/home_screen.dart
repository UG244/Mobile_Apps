import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/providers/cart_provider.dart';
import '../models/product_model.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'product_list_screen.dart';
import 'favorite_screen.dart';

class ProductHomeScreen extends StatefulWidget {
  const ProductHomeScreen({super.key});

  @override
  State<ProductHomeScreen> createState() => _ProductHomeScreenState();
}

class _ProductHomeScreenState extends State<ProductHomeScreen> {
  int _navIndex = 0;

  /// Dipanggil oleh child widget (misal: search hint, category grid)
  /// untuk berpindah tab dari luar State ini.
  void _switchTab(int index) => setState(() => _navIndex = index);

  static const _pages = [
    _HomeTab(),
    ProductListScreen(),
    FavoriteScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final totalItems = cartProvider.totalItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: IndexedStack(index: _navIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        cartItemCount: totalItems,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab Home
// ─────────────────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  static final List<BannerItem> _banners = [
    BannerItem(
      tag: '🔥 FLASH SALE',
      title: 'Laptop ASUS\nHarga Spesial',
      subtitle: 'Hemat hingga Rp 1.500.000\nstok terbatas!',
      gradientColors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
      ctaLabel: 'Beli Sekarang',
    ),
    BannerItem(
      tag: '🎧 AUDIO WEEK',
      title: 'Sony WH-1000XM5\nDiskon 23%',
      subtitle: 'ANC terbaik, suara\nyang memukau',
      gradientColors: [Color(0xFF00838F), Color(0xFF26C6DA)],
      ctaLabel: 'Lihat Produk',
    ),
    BannerItem(
      tag: '🎮 GAMING GEAR',
      title: 'Setup Gaming\nLengkap Mulai',
      subtitle: 'Mouse, keyboard & headset\nterbaik untuk menang',
      gradientColors: [Color(0xFFE65100), Color(0xFFFF8A65)],
      ctaLabel: 'Jelajahi',
    ),
    BannerItem(
      tag: '📱 SMARTPHONE',
      title: 'Samsung Galaxy S24\nFE Tiba!',
      subtitle: 'AI Photography &\nDynamic AMOLED 120Hz',
      gradientColors: [Color(0xFF6A1B9A), Color(0xFFBA68C8)],
      ctaLabel: 'Pre-order',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final cartProvider = context.watch<CartProvider>();
    final featured = productProvider.featuredProducts;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HomeAppBar(cartCount: cartProvider.totalItems),
          ),

          // ── Search hint (tap → product list) ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: GestureDetector(
                onTap: () {
                  // Navigasi ke tab Product List (index 1)
                  final homeState = context
                      .findAncestorStateOfType<_ProductHomeScreenState>();
                  if (homeState != null && homeState.mounted) {
                    homeState._switchTab(1);
                  }
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: Color(0xFF90A4AE)),
                      SizedBox(width: 10),
                      Text(
                        'Cari laptop, headphone, aksesoris...',
                        style: TextStyle(
                          color: Color(0xFFBDBDBD),
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Banner ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: BannerCarousel(banners: _banners, height: 180),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Kategori Cepat ────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _CategoryGrid(
              categories: productProvider.categories,
              onCategoryTap: (catId) {
                final homeState = context
                    .findAncestorStateOfType<_ProductHomeScreenState>();
                if (homeState != null && homeState.mounted) {
                  productProvider.filterByCategory(catId);
                  homeState._switchTab(1);
                }
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Produk Unggulan ───────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Produk Unggulan',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = featured[index];
                  return ProductCard(
                    product: product,
                    isFavorite: favoriteProvider.isFavorite(product.id),
                    onTap: () => _openDetail(context, product),
                    onFavoriteTap: () =>
                        favoriteProvider.toggleFavorite(product),
                  );
                },
                childCount: featured.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar Custom
// ─────────────────────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Logo dan salam
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Blue',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      TextSpan(
                        text: 'Mart',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'Elektronik & Komputer Terlengkap',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF90A4AE),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Notifikasi
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1A1A2E),
            ),
            onPressed: () {},
          ),

          // Cart icon dengan badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFF1A1A2E),
                ),
                onPressed: () => Navigator.of(context).pushNamed('/cart'),
              ),
              if (cartCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid Kategori (di Home)
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.onCategoryTap,
  });

  final List categories;
  final ValueChanged<String> onCategoryTap;

  static const _iconMap = <String, IconData>{
    'laptop_mac': Icons.laptop_mac_rounded,
    'smartphone': Icons.smartphone_rounded,
    'headphones': Icons.headphones_rounded,
    'sports_esports': Icons.sports_esports_rounded,
    'cable': Icons.cable_rounded,
    'storage': Icons.storage_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final color = Color(cat.color as int);
          return GestureDetector(
            onTap: () => onCategoryTap(cat.id as String),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 74,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _iconMap[cat.iconName as String] ??
                          Icons.category_rounded,
                      color: color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.cartItemCount,
    required this.onTap,
  });

  final int currentIndex;
  final int cartItemCount;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Produk',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // Tombol Cart di tengah
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/cart'),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565C0).withOpacity(0.40),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                cartItemCount > 9 ? '9+' : '$cartItemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.favorite_rounded,
                label: 'Favorit',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Akun',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF1565C0);
    const inactiveColor = Color(0xFF9E9E9E);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withOpacity(0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
