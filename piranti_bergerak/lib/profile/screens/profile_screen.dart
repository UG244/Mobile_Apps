import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../checkout/screens/address_book_screen.dart';
import '../../core/providers/app_settings_provider.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
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
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0B1220), Color(0xFF111827)]
                : const [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 220,
              backgroundColor: isDark ? const Color(0xFF111827) : AppColors.primary,
              foregroundColor: Colors.white,
              title: const Text('Akun Saya'),
              actions: [
                IconButton(
                  tooltip: 'Pengaturan',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _showSettingsSheet(context),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    tooltip: 'Logout',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.16),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () => _confirmLogout(context),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 88, 20, 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          child: Icon(
                            Icons.person_rounded,
                            size: 38,
                            color: Colors.white.withValues(alpha: 0.96),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                emailOrUsername,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _Badge(label: auth.isAdmin ? 'ADMIN' : 'USER', icon: Icons.verified_rounded),
                                  _Badge(label: settings.notificationsEnabled ? 'NOTIF ON' : 'NOTIF OFF', icon: Icons.notifications_active_outlined),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatsRow(cart: cart),
                    const SizedBox(height: 18),
                    _SectionCard(
                      title: 'Edit Profil',
                      subtitle: 'Atur identitas akun yang terlihat di aplikasi',
                      child: Form(
                        key: _profileFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama tampilan',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nama tampilan harus diisi.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Nomor HP',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _profileBusy ? null : _saveProfile,
                                child: _profileBusy
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('Simpan Profil'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Keamanan',
                      subtitle: 'Ubah password akun secara langsung',
                      child: Form(
                        key: _passwordFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _currentPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password lama',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan password lama.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password baru',
                                prefixIcon: Icon(Icons.password_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return 'Password baru minimal 4 karakter.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _passwordBusy ? null : _changePassword,
                                child: _passwordBusy
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Ganti Password'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Pengaturan',
                      subtitle: 'Preferensi yang benar-benar tersimpan',
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: settings.notificationsEnabled,
                            onChanged: (value) => context.read<AppSettingsProvider>().setNotificationsEnabled(value),
                            title: const Text('Notifikasi'),
                            subtitle: const Text('Aktifkan / nonaktifkan pemberitahuan aplikasi'),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: settings.themeMode == ThemeMode.dark,
                            onChanged: (value) => context.read<AppSettingsProvider>().setThemeMode(
                                  value ? ThemeMode.dark : ThemeMode.light,
                                ),
                            title: const Text('Mode gelap'),
                            subtitle: const Text('Terapkan tema gelap ke seluruh aplikasi'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Akses Cepat',
                      subtitle: 'Lanjutkan aktivitas tanpa pindah jauh',
                      child: Column(
                        children: [
                          _QuickTile(
                            icon: Icons.location_on_outlined,
                            title: 'Buku Alamat',
                            subtitle: 'Kelola alamat pengiriman',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddressBookScreen()),
                            ),
                          ),
                          const Divider(height: 1),
                          _QuickTile(
                            icon: Icons.receipt_long_outlined,
                            title: 'Riwayat Pesanan',
                            subtitle: 'Lihat pesanan terbaru',
                            onTap: () => Navigator.of(context).pushNamed('/orders'),
                          ),
                          if (auth.isAdmin) ...[
                            const Divider(height: 1),
                            _QuickTile(
                              icon: Icons.admin_panel_settings_outlined,
                              title: 'Admin Panel',
                              subtitle: 'Masuk ke dashboard admin',
                              onTap: () => Navigator.of(context).pushNamed('/admin'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text('Kamu akan kembali ke halaman login.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) {
        return Consumer<AppSettingsProvider>(
          builder: (context, liveSettings, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Notifikasi'),
                    subtitle: const Text('Atur preferensi notifikasi aplikasi'),
                    trailing: Switch(
                      value: liveSettings.notificationsEnabled,
                      onChanged: (value) => context.read<AppSettingsProvider>().setNotificationsEnabled(value),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Mode gelap'),
                    subtitle: const Text('Tema aplikasi lebih nyaman di malam hari'),
                    trailing: Switch(
                      value: liveSettings.themeMode == ThemeMode.dark,
                      onChanged: (value) => context.read<AppSettingsProvider>().setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.cart});

  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            icon: Icons.shopping_bag_outlined,
            title: 'Item Keranjang',
            value: '${cart.totalItems}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStat(
            icon: Icons.favorite_border_rounded,
            title: 'Favorit',
            value: 'Lihat',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStat(
            icon: Icons.verified_user_outlined,
            title: 'Status',
            value: 'Aktif',
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedText = theme.textTheme.bodySmall?.color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: theme.brightness == Brightness.dark ? const <BoxShadow>[] : AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 2),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: mutedText)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: theme.brightness == Brightness.dark ? const <BoxShadow>[] : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
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
      leading: CircleAvatar(
        backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
