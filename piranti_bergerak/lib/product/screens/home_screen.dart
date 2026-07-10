import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../notification/providers/notification_provider.dart';
import '../../notification/widgets/notification_badge.dart';
import '../../sensor/services/shake_detector_service.dart';
import '../../sensor/widgets/shake_refresh_toast.dart';
import '../../profile/screens/profile_screen.dart';
import '../providers/favorite_provider.dart';
import '../providers/product_provider.dart';
import '../screens/product_detail_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/favorite_screen.dart';
import '../widgets/cart_notification_overlay.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';

/// ProductHomeScreen — Shell navigasi utama aplikasi BlueMart Retail modern.
///
/// Menggunakan [IndexedStack] agar BottomNavigationBar selalu konsisten
/// dan mempertahankan state di setiap tab (Home, Search, Favorite, Profile).
class ProductHomeScreen extends StatefulWidget {
  const ProductHomeScreen({super.key});

  @override
  State<ProductHomeScreen> createState() => _ProductHomeScreenState();
}

class _ProductHomeScreenState extends State<ProductHomeScreen> {
  final PageController _pageController = PageController();
  int _bannerIndex = 0;
  int _navIndex = 0; // Tab aktif
  Timer? _bannerTimer;
  ShakeDetectorService? _shakeDetector;

  static const _banners = [
    _BannerData(
      title: '🔥 Flash Sale Spesial',
      subtitle: 'Diskon hingga 50% untuk gadget pilihan',
      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
      badge: 'PROMO HARI INI',
    ),
    _BannerData(
      title: '🎧 Audio & Gadget Week',
      subtitle: 'Headphone & Speaker TWS bergaransi resmi',
      colors: [Color(0xFF0F172A), Color(0xFF0EA5E9)],
      badge: 'CASHBACK 20%',
    ),
    _BannerData(
      title: '💻 Laptop & Workstation',
      subtitle: 'Performa tinggi untuk kerja & gaming',
      colors: [Color(0xFF312E81), Color(0xFF8B5CF6)],
      badge: 'GRATIS ONGKIR',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startBannerAutoScroll();
    _initShakeDetector();
  }

  void _initShakeDetector() {
    _shakeDetector = ShakeDetectorService(
      onShake: () {
        if (!mounted) return;
        context.read<ProductProvider>().refreshRandom();
        ShakeRefreshToast.show(context);
      },
    );
    _shakeDetector?.startListening();
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
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
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _navIndex == 0
          ? AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              titleSpacing: 16,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BlueMart Retail',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 11,
                            color: AppColors.accentOrange,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Dikirim ke Denpasar, Bali',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Tombol Scan Barcode Cepat
                IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.textPrimary,
                  ),
                  tooltip: 'Scan Barcode / QR',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/barcode-scanner'),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.map_outlined,
                    color: AppColors.textPrimary,
                  ),
                  tooltip: 'Lokasi Toko',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/store-location'),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.textPrimary,
                  ),
                  tooltip: 'Admin Panel',
                  onPressed: () => Navigator.of(context).pushNamed('/admin'),
                ),
                // Notifikasi
                NotificationBadge(
                  count: notificationProvider.unreadCount,
                  onTap: () async {
                    await Navigator.of(context).pushNamed('/notifications');
                    if (context.mounted) {
                      context.read<NotificationProvider>().loadNotifications();
                    }
                  },
                ),
                // Keranjang
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pushNamed('/cart'),
                    ),
                    if (cartProvider.totalItems > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '${cartProvider.totalItems}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
            )
          : null,
      body: IndexedStack(
        index: _navIndex,
        children: [
          _HomeTabBody(
            pageController: _pageController,
            bannerIndex: _bannerIndex,
            banners: _banners,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            onCategoryTap: (catId) {
              context.read<ProductProvider>().filterByCategory(catId);
              setState(() => _navIndex = 1); // Pindah ke tab Search
            },
          ),
          const ProductListScreen(),
          const FavoriteScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.accent,
              unselectedItemColor: AppColors.textHint,
              currentIndex: _navIndex,
              onTap: (index) => setState(() => _navIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search_rounded),
                  label: 'Katalog',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: 'Favorit',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Akun Saya',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar Hero ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: GestureDetector(
              onTap: () {
                // Pindah ke halaman pencarian/katalog
                context.read<ProductProvider>().clearSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AppColors.textHint,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Cari laptop, smartphone, audio...',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Scan',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Parallax Promo Banner ───────────────────────────────────────
          SizedBox(
            height: 185,
            child: PageView.builder(
              controller: pageController,
              itemCount: banners.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: banner.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: banner.colors.first.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 140,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFACC15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                banner.badge,
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              banner.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Dot Indicator ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              final isActive = i == bannerIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accent : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // ── Kategori Pilihan ────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kategori Pilihan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 95,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: productProvider.categories.map((cat) {
                return _CategoryItem(
                  label: cat.name,
                  iconName: cat.iconName,
                  onTap: () => onCategoryTap(cat.id),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // ── Rekomendasi Spesial ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produk Terbaru & Rekomendasi 🔥',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Produk baru dari admin tampil di sini',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.accent,
                  ),
                  tooltip: 'Acak Produk (Shake)',
                  onPressed: () {
                    context.read<ProductProvider>().refreshRandom();
                    ShakeRefreshToast.show(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (productProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 315,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemCount: productProvider.featuredProducts.length,
              itemBuilder: (context, index) {
                final product = productProvider.featuredProducts[index];
                return ProductCard(
                  product: product,
                  isFavorite: favoriteProvider.isFavorite(product.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  ),
                  onFavoriteTap: () => favoriteProvider.toggleFavorite(product),
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

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final String iconName;
  final VoidCallback? onTap;

  const _CategoryItem({
    required this.label,
    required this.iconName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: _isCategoryImage(iconName)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: ProductImage(
                          imageUrl: iconName,
                          placeholderSize: 22,
                        ),
                      ),
                    )
                  : Icon(
                      _iconFromName(iconName),
                      color: AppColors.accent,
                      size: 24,
                    ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isCategoryImage(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
    return true;
  }
  return File(value).existsSync();
}

class _BannerData {
  const _BannerData({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.badge,
  });
  final String title;
  final String subtitle;
  final List<Color> colors;
  final String badge;
}

IconData _iconFromName(String name) {
  const map = <String, IconData>{
    'laptop_mac': Icons.laptop_mac_rounded,
    'smartphone': Icons.smartphone_rounded,
    'headphones': Icons.headphones_rounded,
    'sports_esports': Icons.sports_esports_rounded,
    'cable': Icons.cable_rounded,
    'storage': Icons.storage_rounded,
  };
  return map[name] ?? Icons.category_rounded;
}
