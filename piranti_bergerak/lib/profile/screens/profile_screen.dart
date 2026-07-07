import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../checkout/screens/address_book_screen.dart';

/// ProfileScreen — User Dashboard VIP yang modern, elegan, dan fungsional.
///
/// Menggantikan placeholder lama dengan kartu keanggotaan VIP, statistik belanja,
/// serta akses cepat ke Riwayat Pesanan, Buku Alamat, dan Panel Admin.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Akun Saya'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pengaturan akun akan segera hadir!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── VIP Membership Card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.floatingShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFACC15), width: 2.5),
                        ),
                        child: const CircleAvatar(
                          radius: 34,
                          backgroundColor: AppColors.surfaceVariant,
                          child: Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Pengguna BlueMart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF60A5FA),
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'user@bluemart.id • +62 812-3456-7890',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFACC15).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFACC15), width: 1),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium_rounded, color: Color(0xFFFACC15), size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'GOLD MEMBER • 1.250 Poin',
                                    style: TextStyle(
                                      color: Color(0xFFFACC15),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Quick Stats Row ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.accent,
                    title: 'Pesanan',
                    value: '12 Aktif',
                    onTap: () => Navigator.of(context).pushNamed('/orders'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.shopping_bag_rounded,
                    color: AppColors.accentOrange,
                    title: 'Keranjang',
                    value: '${cart.totalItems} Item',
                    onTap: () => Navigator.of(context).pushNamed('/cart'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.discount_rounded,
                    color: AppColors.success,
                    title: 'Kupon',
                    value: '3 Tersedia',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kupon dapat dipilih saat Checkout!')),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Menu Section: Aktivitas Belanja ──────────────────────────
            _buildSectionTitle('Aktivitas Belanja'),
            const SizedBox(height: 8),
            _MenuCard(
              children: [
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  iconColor: AppColors.accent,
                  title: 'Riwayat Pesanan',
                  subtitle: 'Pantau pengiriman dan status transaksi Anda',
                  onTap: () => Navigator.of(context).pushNamed('/orders'),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.accentOrange,
                  title: 'Buku Alamat Pengiriman',
                  subtitle: 'Atur alamat utama dan lokasi favorit',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddressBookScreen()),
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _MenuItem(
                  icon: Icons.qr_code_scanner_rounded,
                  iconColor: AppColors.success,
                  title: 'Metode Pembayaran QRIS',
                  subtitle: 'Pembayaran instan scan QR Code saat checkout',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pilih metode QRIS langsung di halaman Checkout!')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Menu Section: Pengelola & Sistem ─────────────────────────
            _buildSectionTitle('Pengelola & Sistem'),
            const SizedBox(height: 8),
            _MenuCard(
              children: [
                _MenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  iconColor: AppColors.primary,
                  title: 'Admin Panel BlueMart',
                  subtitle: 'Kelola katalog produk, harga, dan stok barang',
                  onTap: () => Navigator.of(context).pushNamed('/admin'),
                ),
                const Divider(height: 1, color: AppColors.divider),
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.info,
                  title: 'Pusat Bantuan & FAQ',
                  subtitle: 'Hubungi layanan pelanggan 24/7',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Layanan Pelanggan: cs@bluemart.id')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Logout Button ────────────────────────────────────────────
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Keluar Akun'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anda telah keluar dari sesi demo.')),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<Widget> children;

  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 14, width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}
