import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../checkout/screens/address_book_screen.dart';
import '../../notification/providers/notification_provider.dart';

/// ProfileScreen — User Dashboard VIP yang modern, elegan, dan fungsional.
///
/// Menggantikan placeholder lama dengan kartu keanggotaan VIP, statistik belanja,
/// serta akses cepat ke Riwayat Pesanan, Buku Alamat, dan Panel Admin.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  bool _profileBusy = false;
  bool _passwordBusy = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
    setState(() => _profileBusy = true);
    final error = await context.read<AuthProvider>().updateProfile(
          displayName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _profileBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Profil berhasil disimpan.')),
    );
  }

  Future<void> _changePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;
    setState(() => _passwordBusy = true);
    final error = await context.read<AuthProvider>().changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
    if (!mounted) return;
    setState(() => _passwordBusy = false);
    if (error == null) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Password berhasil diperbarui.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final cart = context.watch<CartProvider>();
    final user = auth.currentUser;
    final displayName = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName
        : 'Pengguna BlueMart';
    final emailOrUsername = user?.email.trim().isNotEmpty == true
        ? user!.email
        : user?.username ?? 'Login untuk mulai';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Akun Saya'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              _showProfileSettings(context, auth);
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
                          border: Border.all(
                            color: const Color(0xFFFACC15),
                            width: 2.5,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 34,
                          backgroundColor: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  auth.currentUser != null
                                      ? auth.currentUser!.username
                                      : 'Pengguna BlueMart',
                                  style: const TextStyle(
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
                              auth.currentUser != null
                                  ? 'Role: ${auth.currentUser!.role.toUpperCase()}'
                                  : 'Role: USER',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: auth.isAdmin
                                    ? const Color(
                                        0xFF4ADE80,
                                      ).withValues(alpha: 0.2)
                                    : const Color(
                                        0xFFFACC15,
                                      ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: auth.isAdmin
                                      ? const Color(0xFF4ADE80)
                                      : const Color(0xFFFACC15),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    auth.isAdmin
                                        ? Icons.admin_panel_settings
                                        : Icons.workspace_premium_rounded,
                                    color: auth.isAdmin
                                        ? const Color(0xFF4ADE80)
                                        : const Color(0xFFFACC15),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    auth.isAdmin
                                        ? 'ADMINISTRATOR'
                                        : 'PENGGUNA BIASA',
                                    style: TextStyle(
                                      color: auth.isAdmin
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFFFACC15),
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
                        const SnackBar(
                          content: Text('Kupon dapat dipilih saat Checkout!'),
                        ),
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
                    MaterialPageRoute(
                      builder: (_) => const AddressBookScreen(),
                    ),
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
                      const SnackBar(
                        content: Text(
                          'Pilih metode QRIS langsung di halaman Checkout!',
                        ),
                      ),
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
                if (auth.isAdmin) ...[
                  _MenuItem(
                    icon: Icons.admin_panel_settings_outlined,
                    iconColor: AppColors.primary,
                    title: 'Admin Panel BlueMart',
                    subtitle: 'Kelola katalog produk, harga, dan stok barang',
                    onTap: () => Navigator.of(context).pushNamed('/admin'),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                ],
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.info,
                  title: 'Pusat Bantuan & FAQ',
                  subtitle: 'Hubungi layanan pelanggan 24/7',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Layanan Pelanggan: cs@bluemart.id'),
                      ),
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthProvider>().logout();
                context.read<NotificationProvider>().clearScope();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
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

  void _showProfileSettings(BuildContext context, AuthProvider auth) {
    var pushEnabled = true;
    var orderUpdates = true;
    var promoUpdates = false;
    var biometricLock = false;
    var compactMode = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Pengaturan Akun',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _SettingsAccountCard(auth: auth),
                    const SizedBox(height: 14),
                    _SettingsPanel(
                      title: 'Notifikasi',
                      children: [
                        _SettingsSwitch(
                          icon: Icons.notifications_active_outlined,
                          title: 'Push Notification',
                          subtitle: 'Terima info pesanan dan promo penting',
                          value: pushEnabled,
                          onChanged: (value) =>
                              setSheetState(() => pushEnabled = value),
                        ),
                        _SettingsSwitch(
                          icon: Icons.local_shipping_outlined,
                          title: 'Update Pesanan',
                          subtitle: 'Status dikemas, dikirim, dan selesai',
                          value: orderUpdates,
                          onChanged: (value) =>
                              setSheetState(() => orderUpdates = value),
                        ),
                        _SettingsSwitch(
                          icon: Icons.local_offer_outlined,
                          title: 'Promo & Voucher',
                          subtitle: 'Diskon dan voucher personal',
                          value: promoUpdates,
                          onChanged: (value) =>
                              setSheetState(() => promoUpdates = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SettingsPanel(
                      title: 'Keamanan & Tampilan',
                      children: [
                        _SettingsSwitch(
                          icon: Icons.fingerprint_rounded,
                          title: 'Kunci Biometrik',
                          subtitle: 'Simulasi proteksi akun saat app dibuka',
                          value: biometricLock,
                          onChanged: (value) =>
                              setSheetState(() => biometricLock = value),
                        ),
                        _SettingsSwitch(
                          icon: Icons.view_agenda_outlined,
                          title: 'Mode Ringkas',
                          subtitle: 'Tampilan daftar lebih padat',
                          value: compactMode,
                          onChanged: (value) =>
                              setSheetState(() => compactMode = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _SettingsPanel(
                      title: 'Preferensi',
                      children: const [
                        _SettingsInfoTile(
                          icon: Icons.language_outlined,
                          title: 'Bahasa',
                          value: 'Indonesia',
                        ),
                        _SettingsInfoTile(
                          icon: Icons.payments_outlined,
                          title: 'Mata Uang',
                          value: 'Rupiah (IDR)',
                        ),
                        _SettingsInfoTile(
                          icon: Icons.qr_code_2_outlined,
                          title: 'QRIS Checkout',
                          value: 'Aktif',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengaturan akun disimpan.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Simpan Pengaturan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SettingsAccountCard extends StatelessWidget {
  const _SettingsAccountCard({required this.auth});

  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accent.withValues(alpha: 0.12),
            child: const Icon(Icons.person_rounded, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.username ?? 'Pengguna',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID ${user?.id ?? '-'} • ${user?.role.toUpperCase() ?? 'USER'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: AppColors.success),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppColors.accent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
    );
  }
}

class _SettingsInfoTile extends StatelessWidget {
  const _SettingsInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      trailing: Text(
        value,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
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
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
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
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
