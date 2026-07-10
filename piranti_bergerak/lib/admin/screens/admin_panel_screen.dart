import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../cart/providers/cart_provider.dart';
import '../../cart/utils/format_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../../checkout/models/order_detail_model.dart';
import '../../checkout/models/order_model.dart';
import '../../notification/providers/notification_provider.dart';
import '../../product/models/category_model.dart';
import '../../product/models/product_model.dart';
import '../../product/providers/favorite_provider.dart';
import '../../product/providers/product_provider.dart';
import '../../product/widgets/product_image.dart';
import '../providers/admin_provider.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider()..loadAll(),
      child: const _AdminPanelView(),
    );
  }
}

class _AdminPanelView extends StatefulWidget {
  const _AdminPanelView();

  @override
  State<_AdminPanelView> createState() => _AdminPanelViewState();
}

class _AdminPanelViewState extends State<_AdminPanelView> {
  int _selectedIndex = 0;

  void _confirmAdminLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari Admin?'),
          content: const Text(
            'Sesi admin akan dihapus dan kamu akan kembali ke halaman login.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
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

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final pages = [
      _DashboardSection(
        onSelectMenu: (index) => setState(() => _selectedIndex = index),
      ),
      const _ProductManagementSection(),
      const _CategoryManagementSection(),
      const _OrderManagementSection(),
      const _SalesStatsSection(),
      const _SalesReportSection(),
      const _PromoManagementSection(),
      const _VoucherManagementSection(),
      const _StoreSettingsSection(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: const Text('BlueMart Admin'),
        centerTitle: false,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () => Navigator.of(context).pushNamed('/notifications'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: Color(0xFF1D4ED8),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Logout Admin',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFE53935).withValues(alpha: 0.16),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _confirmAdminLogout(context),
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),
      body: admin.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                if (MediaQuery.sizeOf(context).width >= 900)
                  _AdminSideNav(
                    selectedIndex: _selectedIndex,
                    onChanged: (index) =>
                        setState(() => _selectedIndex = index),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: admin.loadAll,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_selectedIndex == 0) ...[
                                const SizedBox(height: 6),
                                _AdminHeroCard(admin: admin),
                                const SizedBox(height: 16),
                              ],
                              pages[_selectedIndex],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width >= 900
          ? null
          : NavigationBar(
              selectedIndex: _mobileSelectedIndex,
              onDestinationSelected: (index) {
                if (index == 4) {
                  _showMoreMenu(context);
                  return;
                }
                final targetIndex = switch (index) {
                  0 => 0,
                  1 => 1,
                  2 => 3,
                  3 => 4,
                  _ => 0,
                };
                setState(() => _selectedIndex = targetIndex);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  label: 'Produk',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  label: 'Pesanan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  label: 'Statistik',
                ),
                NavigationDestination(
                  icon: Icon(Icons.apps_outlined),
                  label: 'Lainnya',
                ),
              ],
            ),
    );
  }

  int get _mobileSelectedIndex {
    return switch (_selectedIndex) {
      0 => 0,
      1 => 1,
      3 => 2,
      4 => 3,
      _ => 4,
    };
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Semua Menu Admin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.05,
                  children: List.generate(_adminMenuItems.length, (index) {
                    final item = _adminMenuItems[index];
                    return _AdminMenuCard(
                      title: item.$1,
                      icon: item.$2,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        setState(() => _selectedIndex = index);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _adminMenuItems = [
  ('Dashboard', Icons.dashboard_outlined),
  ('Produk', Icons.inventory_2_outlined),
  ('Kategori', Icons.category_outlined),
  ('Pesanan', Icons.receipt_long_outlined),
  ('Statistik', Icons.bar_chart_outlined),
  ('Laporan', Icons.description_outlined),
  ('Promo', Icons.local_offer_outlined),
  ('Voucher', Icons.confirmation_number_outlined),
  ('Toko', Icons.storefront_outlined),
];

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.onSelectMenu});

  final ValueChanged<int> onSelectMenu;

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Ringkasan Statistik'),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980
                ? 3
                : constraints.maxWidth >= 640
                ? 2
                : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              childAspectRatio: columns == 1 ? 3.4 : 2.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _StatisticCard(
                  title: 'Total Produk',
                  value: '${admin.totalProducts}',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFF1565C0),
                ),
                _StatisticCard(
                  title: 'Total Pesanan',
                  value: '${admin.totalOrders}',
                  icon: Icons.shopping_cart_outlined,
                  color: const Color(0xFF00897B),
                ),
                _StatisticCard(
                  title: 'Total Pendapatan',
                  value: 'Rp ${formatNumber(admin.totalRevenue)}',
                  icon: Icons.payments_outlined,
                  color: const Color(0xFF2E7D32),
                ),
                _StatisticCard(
                  title: 'Produk Terlaris',
                  value: admin.bestSellingProduct,
                  icon: Icons.star_outline_rounded,
                  color: const Color(0xFFF9A825),
                ),
                _StatisticCard(
                  title: 'Penjualan Hari Ini',
                  value: 'Rp ${formatNumber(admin.todaySales)}',
                  icon: Icons.trending_up_outlined,
                  color: const Color(0xFFEF6C00),
                ),
                _StatisticCard(
                  title: 'Total Pelanggan',
                  value: '${admin.totalCustomers}',
                  icon: Icons.people_alt_outlined,
                  color: const Color(0xFF6A1B9A),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        const _SectionTitle(title: 'Menu Admin'),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 980
                ? 4
                : constraints.maxWidth >= 640
                ? 3
                : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: [
                _AdminMenuCard(
                  title: 'Kelola Produk',
                  icon: Icons.inventory_2_outlined,
                  onTap: () => onSelectMenu(1),
                ),
                _AdminMenuCard(
                  title: 'Kelola Kategori',
                  icon: Icons.category_outlined,
                  onTap: () => onSelectMenu(2),
                ),
                _AdminMenuCard(
                  title: 'Kelola Pesanan',
                  icon: Icons.receipt_long_outlined,
                  onTap: () => onSelectMenu(3),
                ),
                _AdminMenuCard(
                  title: 'Statistik Penjualan',
                  icon: Icons.bar_chart_outlined,
                  onTap: () => onSelectMenu(4),
                ),
                _AdminMenuCard(
                  title: 'Laporan Penjualan',
                  icon: Icons.description_outlined,
                  onTap: () => onSelectMenu(5),
                ),
                _AdminMenuCard(
                  title: 'Kelola Promo',
                  icon: Icons.local_offer_outlined,
                  onTap: () => onSelectMenu(6),
                ),
                _AdminMenuCard(
                  title: 'Kelola Voucher',
                  icon: Icons.confirmation_number_outlined,
                  onTap: () => onSelectMenu(7),
                ),
                _AdminMenuCard(
                  title: 'Pengaturan Toko',
                  icon: Icons.storefront_outlined,
                  onTap: () => onSelectMenu(8),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProductManagementSection extends StatelessWidget {
  const _ProductManagementSection();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Kelola Produk',
          actionLabel: 'Tambah',
          onAction: () => _showProductForm(context),
        ),
        const SizedBox(height: 12),
        if (admin.products.isEmpty)
          _EmptyAdminState(
            icon: Icons.inventory_2_outlined,
            title: 'Belum ada produk',
            subtitle:
                'Tambahkan produk baru atau pulihkan data contoh agar katalog user terisi kembali.',
            actionLabel: 'Pulihkan Produk Contoh',
            onAction: () => _restoreSeedCatalog(context),
          ),
        ...admin.products.map(
          (product) => _ProductAdminCard(
            product: product,
            onEdit: () => _showProductForm(context, product: product),
            onDelete: () => _confirmDeleteProduct(context, product),
          ),
        ),
      ],
    );
  }

  void _showProductForm(BuildContext context, {ProductModel? product}) {
    final admin = context.read<AdminProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: admin,
        child: _ProductForm(product: product),
      ),
    );
  }

  Future<void> _confirmDeleteProduct(
    BuildContext context,
    ProductModel product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await context.read<AdminProvider>().deleteProduct(
      product.id,
      productProvider: context.read<ProductProvider>(),
      cartProvider: context.read<CartProvider>(),
      favoriteProvider: context.read<FavoriteProvider>(),
    );
  }

  Future<void> _restoreSeedCatalog(BuildContext context) async {
    await context.read<AdminProvider>().restoreSeedCatalog(
      productProvider: context.read<ProductProvider>(),
      cartProvider: context.read<CartProvider>(),
      favoriteProvider: context.read<FavoriteProvider>(),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk contoh berhasil dipulihkan.')),
    );
  }
}

class _ProductForm extends StatefulWidget {
  const _ProductForm({this.product});

  final ProductModel? product;

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _description;
  late final TextEditingController _weight;
  late final TextEditingController _discount;
  late final TextEditingController _imageUrl;
  String? _categoryId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product?.name ?? '');
    _price = TextEditingController(
      text: product == null ? '' : product.originalPrice.toStringAsFixed(0),
    );
    _stock = TextEditingController(
      text: product == null ? '' : '${product.stock}',
    );
    _description = TextEditingController(text: product?.description ?? '');
    _weight = TextEditingController(
      text: product == null ? '' : product.weight.toString(),
    );
    _discount = TextEditingController(
      text: product == null ? '0' : '${product.discountPercent}',
    );
    _imageUrl = TextEditingController(text: product?.imageUrl ?? '');
    _categoryId = product?.categoryId;
    _isActive = product?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    _description.dispose();
    _weight.dispose();
    _discount.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AdminProvider>().categories;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return SafeArea(
      top: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product == null
                              ? 'Tambah Produk'
                              : 'Edit Produk',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _TextField(controller: _name, label: 'Nama Produk'),
                  if (categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Kategori belum tersedia. Tarik untuk refresh atau tambah kategori terlebih dahulu.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _categoryId = value),
                    validator: (value) =>
                        value == null ? 'Pilih kategori' : null,
                  ),
                  const SizedBox(height: 12),
                  _TextField(
                    controller: _price,
                    label: 'Harga',
                    keyboardType: TextInputType.number,
                    numberOnly: true,
                  ),
                  _TextField(
                    controller: _stock,
                    label: 'Stok',
                    keyboardType: TextInputType.number,
                    integerOnly: true,
                  ),
                  _TextField(
                    controller: _description,
                    label: 'Deskripsi',
                    maxLines: 3,
                  ),
                  _TextField(
                    controller: _weight,
                    label: 'Berat Produk (kg)',
                    keyboardType: TextInputType.number,
                    numberOnly: true,
                  ),
                  _TextField(
                    controller: _discount,
                    label: 'Diskon (%)',
                    keyboardType: TextInputType.number,
                    numberOnly: true,
                  ),
                  _ProductImagePicker(
                    imageUrl: _imageUrl.text,
                    onGalleryTap: () => _pickProductImage(ImageSource.gallery),
                    onCameraTap: () => _pickProductImage(ImageSource.camera),
                  ),
                  _TextField(
                    controller: _imageUrl,
                    label: 'URL Gambar atau Path File',
                    onChanged: (_) => setState(() {}),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                    title: const Text('Status Produk'),
                    subtitle: Text(_isActive ? 'Aktif' : 'Tidak Aktif'),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _submit(context),
                      child: const Text('Simpan Produk'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false) || _categoryId == null) {
      return;
    }

    final categories = context.read<AdminProvider>().categories;
    CategoryModel? category;
    for (final item in categories) {
      if (item.id == _categoryId) {
        category = item;
        break;
      }
    }
    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori produk terlebih dahulu.')),
      );
      return;
    }
    final originalPrice = double.tryParse(_price.text.trim()) ?? 0;
    final discount = double.tryParse(_discount.text) ?? 0;
    final finalPrice =
        originalPrice - (originalPrice * (discount.clamp(0, 100) / 100));
    final product = ProductModel(
      id: widget.product?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: finalPrice,
      originalPrice: originalPrice,
      imageUrl: _imageUrl.text.trim(),
      categoryId: category.id,
      categoryName: category.name,
      rating: widget.product?.rating ?? 0,
      reviewCount: widget.product?.reviewCount ?? 0,
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      weight: double.tryParse(_weight.text) ?? 0,
      isActive: _isActive,
    );

    final admin = context.read<AdminProvider>();
    if (widget.product == null) {
      await admin.addProduct(
        product,
        productProvider: context.read<ProductProvider>(),
        cartProvider: context.read<CartProvider>(),
        favoriteProvider: context.read<FavoriteProvider>(),
      );
    } else {
      await admin.updateProduct(
        product,
        productProvider: context.read<ProductProvider>(),
        cartProvider: context.read<CartProvider>(),
        favoriteProvider: context.read<FavoriteProvider>(),
      );
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _pickProductImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin kamera diperlukan untuk mengambil foto produk.',
            ),
          ),
        );
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return;
      }
    } else {
      final status = await _requestGalleryPermission();
      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin galeri diperlukan untuk memilih foto produk.',
            ),
          ),
        );
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return;
      }
    }

    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'Kamera belum bisa dibuka di perangkat ini.'
                : 'Galeri belum bisa dibuka di perangkat ini.',
          ),
        ),
      );
      return;
    }
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(p.join(appDir.path, 'product_images'));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final extension = p.extension(picked.path).isEmpty
        ? '.jpg'
        : p.extension(picked.path);
    final fileName =
        'product_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedPath = p.join(imageDir.path, fileName);
    await File(picked.path).copy(savedPath);

    if (!mounted) return;
    setState(() => _imageUrl.text = savedPath);
  }

  Future<PermissionStatus> _requestGalleryPermission() async {
    if (Platform.isIOS) {
      return Permission.photos.request();
    }

    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted || photosStatus.isLimited) {
        return photosStatus;
      }

      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted || storageStatus.isLimited) {
        return storageStatus;
      }

      return storageStatus;
    }

    return PermissionStatus.granted;
  }
}

class _ProductImagePicker extends StatelessWidget {
  const _ProductImagePicker({
    required this.imageUrl,
    required this.onGalleryTap,
    required this.onCameraTap,
  });

  final String imageUrl;
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD8E0EA)),
            ),
            clipBehavior: Clip.antiAlias,
            child: ProductImage(imageUrl: imageUrl, placeholderSize: 48),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onGalleryTap,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Pilih dari Galeri'),
              ),
              OutlinedButton.icon(
                onPressed: onCameraTap,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Kamera'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryManagementSection extends StatelessWidget {
  const _CategoryManagementSection();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Kelola Kategori',
          actionLabel: 'Tambah',
          onAction: () => _showCategoryForm(context),
        ),
        const SizedBox(height: 12),
        ...admin.categories.map(
          (category) => _CategoryAdminCard(
            category: category,
            onEdit: () => _showCategoryForm(context, category: category),
            onDelete: () => _confirmDeleteCategory(context, category),
          ),
        ),
      ],
    );
  }

  void _showCategoryForm(BuildContext context, {CategoryModel? category}) {
    final admin = context.read<AdminProvider>();
    showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: admin,
        child: _CategoryForm(category: category),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    CategoryModel category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text(
          'Hapus kategori ${category.name}? Produk dalam kategori ini akan dinonaktifkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<AdminProvider>().deleteCategory(
      category.id,
      productProvider: context.read<ProductProvider>(),
      cartProvider: context.read<CartProvider>(),
      favoriteProvider: context.read<FavoriteProvider>(),
    );
  }
}

class _CategoryForm extends StatefulWidget {
  const _CategoryForm({this.category});

  final CategoryModel? category;

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _iconName;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name ?? '');
    _iconName = TextEditingController(
      text: widget.category?.iconName ?? 'category',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _iconName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.category == null ? 'Tambah Kategori' : 'Edit Kategori',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TextField(controller: _name, label: 'Nama Kategori'),
              _CategoryLogoPicker(
                iconName: _iconName.text,
                onGalleryTap: _pickCategoryLogo,
              ),
              _TextField(
                controller: _iconName,
                label: 'Icon Material atau Path Logo',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => _submit(context),
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final category = CategoryModel(
      id: widget.category?.id ?? 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: _name.text.trim(),
      iconName: _iconName.text.trim(),
      color: widget.category?.color ?? 0xFF1565C0,
    );
    final admin = context.read<AdminProvider>();
    if (widget.category == null) {
      await admin.addCategory(
        category,
        productProvider: context.read<ProductProvider>(),
      );
    } else {
      await admin.updateCategory(
        category,
        productProvider: context.read<ProductProvider>(),
      );
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _pickCategoryLogo() async {
    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Galeri belum bisa dibuka di perangkat ini.'),
        ),
      );
      return;
    }
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(p.join(appDir.path, 'category_images'));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final extension = p.extension(picked.path).isEmpty
        ? '.jpg'
        : p.extension(picked.path);
    final fileName =
        'category_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedPath = p.join(imageDir.path, fileName);
    await File(picked.path).copy(savedPath);

    if (!mounted) return;
    setState(() => _iconName.text = savedPath);
  }
}

class _CategoryLogoPicker extends StatelessWidget {
  const _CategoryLogoPicker({
    required this.iconName,
    required this.onGalleryTap,
  });

  final String iconName;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD8E0EA)),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isLocalOrNetworkImage(iconName)
                ? ProductImage(imageUrl: iconName, placeholderSize: 34)
                : Icon(
                    _adminIconFromName(iconName),
                    color: const Color(0xFF1565C0),
                    size: 36,
                  ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onGalleryTap,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Pilih Logo dari Galeri'),
          ),
        ],
      ),
    );
  }
}

class _OrderManagementSection extends StatelessWidget {
  const _OrderManagementSection();

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<AdminProvider>().orders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Kelola Pesanan'),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const _EmptyAdminCard(message: 'Belum ada pesanan.')
        else
          ...orders.map((order) => _OrderAdminCard(order: order)),
      ],
    );
  }
}

class _SalesStatsSection extends StatelessWidget {
  const _SalesStatsSection();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Statistik Penjualan'),
        const SizedBox(height: 12),
        _SalesChartCard(values: admin.weeklySalesData),
        const SizedBox(height: 12),
        _InfoPanel(
          rows: [
            _InfoRow(
              label: 'Penjualan Harian',
              value: 'Rp ${formatNumber(admin.todaySales)}',
            ),
            _InfoRow(
              label: 'Penjualan Mingguan',
              value:
                  'Rp ${formatNumber(admin.weeklySalesData.fold(0, (a, b) => a + b))}',
            ),
            _InfoRow(label: 'Produk Terlaris', value: admin.bestSellingProduct),
            const _InfoRow(label: 'Kategori Terlaris', value: 'Laptop'),
            _InfoRow(
              label: 'Pendapatan Bulanan',
              value: 'Rp ${formatNumber(admin.totalRevenue)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _SalesReportSection extends StatelessWidget {
  const _SalesReportSection();

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final completedOrders = admin.orders
        .where((order) => order.status == 'Selesai')
        .toList();
    final pendingOrders = admin.orders
        .where((order) => order.status != 'Selesai')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Laporan Penjualan'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 3 : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 3.6 : 2.4,
              children: [
                _StatisticCard(
                  title: 'Pendapatan Kotor',
                  value: 'Rp ${formatNumber(admin.totalRevenue)}',
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFF1565C0),
                ),
                _StatisticCard(
                  title: 'Pesanan Selesai',
                  value: '${completedOrders.length}',
                  icon: Icons.task_alt_outlined,
                  color: const Color(0xFF2E7D32),
                ),
                _StatisticCard(
                  title: 'Pesanan Berjalan',
                  value: '${pendingOrders.length}',
                  icon: Icons.pending_actions_outlined,
                  color: const Color(0xFFEF6C00),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          rows: [
            _InfoRow(
              label: 'Rata-rata Nilai Pesanan',
              value: admin.totalOrders == 0
                  ? 'Rp 0'
                  : 'Rp ${formatNumber(admin.totalRevenue / admin.totalOrders)}',
            ),
            _InfoRow(
              label: 'Konversi Selesai',
              value: admin.totalOrders == 0
                  ? '0%'
                  : '${((completedOrders.length / admin.totalOrders) * 100).toStringAsFixed(0)}%',
            ),
            const _InfoRow(
              label: 'Format Laporan',
              value: 'Harian, Mingguan, Bulanan',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ReportTable(orders: admin.orders.take(6).toList()),
      ],
    );
  }
}

class _PromoManagementSection extends StatefulWidget {
  const _PromoManagementSection();

  @override
  State<_PromoManagementSection> createState() =>
      _PromoManagementSectionState();
}

class _PromoManagementSectionState extends State<_PromoManagementSection> {
  final List<_MarketingRule> _promos = [
    const _MarketingRule(
      title: 'BLUEMART10',
      description: 'Diskon 10% untuk semua kategori.',
      value: '10%',
      active: true,
      icon: Icons.percent_outlined,
    ),
    const _MarketingRule(
      title: 'ONGKIR0',
      description: 'Gratis ongkir untuk checkout pilihan.',
      value: 'Ongkir',
      active: true,
      icon: Icons.local_shipping_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _RuleManagementSection(
      title: 'Kelola Promo',
      actionLabel: 'Tambah Promo',
      emptyMessage: 'Belum ada promo aktif.',
      rules: _promos,
      onAdd: () => _showRuleForm(context),
      onToggle: (index, active) {
        setState(() {
          _promos[index] = _promos[index].copyWith(active: active);
        });
      },
      onDelete: (index) => setState(() => _promos.removeAt(index)),
    );
  }

  void _showRuleForm(BuildContext context) {
    _showMarketingRuleDialog(
      context: context,
      title: 'Tambah Promo',
      codeLabel: 'Kode Promo',
      valueLabel: 'Nilai Promo',
      onSubmit: (rule) => setState(() => _promos.insert(0, rule)),
    );
  }
}

class _VoucherManagementSection extends StatefulWidget {
  const _VoucherManagementSection();

  @override
  State<_VoucherManagementSection> createState() =>
      _VoucherManagementSectionState();
}

class _VoucherManagementSectionState extends State<_VoucherManagementSection> {
  final List<_MarketingRule> _vouchers = [
    const _MarketingRule(
      title: 'HEMAT50',
      description: 'Potongan Rp 50.000 untuk pelanggan loyal.',
      value: 'Rp 50.000',
      active: true,
      icon: Icons.confirmation_number_outlined,
    ),
    const _MarketingRule(
      title: 'NEWUSER25',
      description: 'Voucher pelanggan baru untuk transaksi pertama.',
      value: '25%',
      active: false,
      icon: Icons.card_giftcard_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _RuleManagementSection(
      title: 'Kelola Voucher',
      actionLabel: 'Tambah Voucher',
      emptyMessage: 'Belum ada voucher.',
      rules: _vouchers,
      onAdd: () => _showRuleForm(context),
      onToggle: (index, active) {
        setState(() {
          _vouchers[index] = _vouchers[index].copyWith(active: active);
        });
      },
      onDelete: (index) => setState(() => _vouchers.removeAt(index)),
    );
  }

  void _showRuleForm(BuildContext context) {
    _showMarketingRuleDialog(
      context: context,
      title: 'Tambah Voucher',
      codeLabel: 'Kode Voucher',
      valueLabel: 'Nilai Voucher',
      onSubmit: (rule) => setState(() => _vouchers.insert(0, rule)),
    );
  }
}

class _StoreSettingsSection extends StatefulWidget {
  const _StoreSettingsSection();

  @override
  State<_StoreSettingsSection> createState() => _StoreSettingsSectionState();
}

class _StoreSettingsSectionState extends State<_StoreSettingsSection> {
  final _storeName = TextEditingController(text: 'BlueMart Retail');
  final _storePhone = TextEditingController(text: '0812-3456-7890');
  final _storeAddress = TextEditingController(
    text: 'Jl. Teknologi No. 15, Jakarta',
  );
  final _openHour = TextEditingController(text: '08:00 - 21:00');
  bool _autoAcceptOrder = true;
  bool _lowStockAlert = true;
  bool _storeOpen = true;

  @override
  void dispose() {
    _storeName.dispose();
    _storePhone.dispose();
    _storeAddress.dispose();
    _openHour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Pengaturan Toko'),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _TextField(controller: _storeName, label: 'Nama Toko'),
                _TextField(
                  controller: _storePhone,
                  label: 'Nomor Layanan',
                  keyboardType: TextInputType.phone,
                ),
                _TextField(
                  controller: _storeAddress,
                  label: 'Alamat Toko',
                  maxLines: 2,
                ),
                _TextField(controller: _openHour, label: 'Jam Operasional'),
                _SettingSwitch(
                  title: 'Toko Aktif',
                  subtitle: 'Produk tetap dapat dibeli saat toko aktif.',
                  value: _storeOpen,
                  onChanged: (value) => setState(() => _storeOpen = value),
                ),
                _SettingSwitch(
                  title: 'Terima Pesanan Otomatis',
                  subtitle: 'Pesanan baru langsung masuk status Diproses.',
                  value: _autoAcceptOrder,
                  onChanged: (value) =>
                      setState(() => _autoAcceptOrder = value),
                ),
                _SettingSwitch(
                  title: 'Peringatan Stok Menipis',
                  subtitle: 'Admin diberi tanda saat stok produk rendah.',
                  value: _lowStockAlert,
                  onChanged: (value) => setState(() => _lowStockAlert = value),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengaturan toko disimpan.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Pengaturan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductAdminCard extends StatelessWidget {
  const _ProductAdminCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ProductImage(
                imageUrl: product.imageUrl,
                width: 64,
                height: 64,
                placeholderSize: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.categoryName} • Stok ${product.stock} • ${product.isActive ? 'Aktif' : 'Tidak Aktif'}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${formatNumber(product.price)} • Rating ${product.rating.toStringAsFixed(1)}',
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryAdminCard extends StatelessWidget {
  const _CategoryAdminCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(category.color).withValues(alpha: 0.12),
          child: _isLocalOrNetworkImage(category.iconName)
              ? ClipOval(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: ProductImage(
                      imageUrl: category.iconName,
                      placeholderSize: 22,
                    ),
                  ),
                )
              : Icon(
                  _adminIconFromName(category.iconName),
                  color: Color(category.color),
                ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(category.iconName),
        trailing: Wrap(
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderAdminCard extends StatelessWidget {
  const _OrderAdminCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showOrderDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.invoice,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showOrderDetails(context),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Detail'),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: order.status,
                    items: const ['Diproses', 'Dikemas', 'Dikirim', 'Selesai']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (status) {
                      if (status == null || order.id == null) return;
                      context.read<AdminProvider>().updateOrderStatus(
                        orderId: order.id!,
                        status: status,
                        notificationProvider: context
                            .read<NotificationProvider>(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('${order.customerName} • ${order.phone}'),
              const SizedBox(height: 6),
              Text('Total: Rp ${formatNumber(order.grandTotal)}'),
              const SizedBox(height: 6),
              const Text(
                'Ketuk kartu untuk melihat produk yang dipesan',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context) {
    if (order.id == null) return;
    final admin = context.read<AdminProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: admin,
        child: _OrderDetailSheet(order: order),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final orderId = order.id;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Detail Pesanan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoPanel(
                  rows: [
                    _InfoRow(label: 'Invoice', value: order.invoice),
                    _InfoRow(label: 'Status', value: order.status),
                    _InfoRow(label: 'Nama Pembeli', value: order.customerName),
                    _InfoRow(label: 'No. HP', value: order.phone),
                    _InfoRow(label: 'Alamat', value: order.address),
                    if (order.note.trim().isNotEmpty)
                      _InfoRow(label: 'Catatan', value: order.note),
                    _InfoRow(label: 'Pembayaran', value: order.paymentMethod),
                    _InfoRow(label: 'Pengiriman', value: order.shippingMethod),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Produk yang Dipesan',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (orderId == null)
                  const _EmptyAdminCard(message: 'Detail pesanan tidak valid.')
                else
                  FutureBuilder<List<OrderDetailModel>>(
                    future: context.read<AdminProvider>().getOrderDetails(
                      orderId,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final details = snapshot.data ?? [];
                      if (details.isEmpty) {
                        return const _EmptyAdminCard(
                          message: 'Belum ada item di pesanan ini.',
                        );
                      }
                      return Column(
                        children: details
                            .map((item) => _OrderDetailItem(item: item))
                            .toList(),
                      );
                    },
                  ),
                const SizedBox(height: 14),
                _InfoPanel(
                  rows: [
                    _InfoRow(
                      label: 'Subtotal',
                      value: 'Rp ${formatNumber(order.subtotal)}',
                    ),
                    _InfoRow(
                      label: 'Ongkir',
                      value: 'Rp ${formatNumber(order.shippingCost)}',
                    ),
                    _InfoRow(
                      label: 'Diskon',
                      value: '- Rp ${formatNumber(order.discount)}',
                    ),
                    _InfoRow(
                      label: 'Pajak',
                      value: 'Rp ${formatNumber(order.tax)}',
                    ),
                    _InfoRow(
                      label: 'Grand Total',
                      value: 'Rp ${formatNumber(order.grandTotal)}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailItem extends StatelessWidget {
  const _OrderDetailItem({required this.item});

  final OrderDetailModel item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF5F7FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 54,
            height: 54,
            color: Colors.white,
            child: ProductImage(imageUrl: item.imageUrl, placeholderSize: 24),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text('${item.quantity} x Rp ${formatNumber(item.price)}'),
        trailing: Text(
          'Rp ${formatNumber(item.total)}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ReportTable extends StatelessWidget {
  const _ReportTable({required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaksi Terbaru',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (orders.isEmpty)
              const Text('Belum ada transaksi untuk ditampilkan.')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFEAF3FE),
                  ),
                  columns: const [
                    DataColumn(label: Text('Invoice')),
                    DataColumn(label: Text('Pembeli')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Total')),
                  ],
                  rows: orders
                      .map(
                        (order) => DataRow(
                          cells: [
                            DataCell(Text(order.invoice)),
                            DataCell(Text(order.customerName)),
                            DataCell(Text(order.status)),
                            DataCell(
                              Text('Rp ${formatNumber(order.grandTotal)}'),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RuleManagementSection extends StatelessWidget {
  const _RuleManagementSection({
    required this.title,
    required this.actionLabel,
    required this.emptyMessage,
    required this.rules,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
  });

  final String title;
  final String actionLabel;
  final String emptyMessage;
  final List<_MarketingRule> rules;
  final VoidCallback onAdd;
  final void Function(int index, bool active) onToggle;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    final activeCount = rules.where((rule) => rule.active).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, actionLabel: actionLabel, onAction: onAdd),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 760 ? 2 : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: columns == 1 ? 3.4 : 2.7,
              children: [
                _StatisticCard(
                  title: 'Total Program',
                  value: '${rules.length}',
                  icon: Icons.campaign_outlined,
                  color: const Color(0xFF1565C0),
                ),
                _StatisticCard(
                  title: 'Sedang Aktif',
                  value: '$activeCount',
                  icon: Icons.verified_outlined,
                  color: const Color(0xFF2E7D32),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        if (rules.isEmpty)
          _EmptyAdminCard(message: emptyMessage)
        else
          ...List.generate(
            rules.length,
            (index) => _RuleCard(
              rule: rules[index],
              onToggle: (value) => onToggle(index, value),
              onDelete: () => onDelete(index),
            ),
          ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.rule,
    required this.onToggle,
    required this.onDelete,
  });

  final _MarketingRule rule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(rule.icon, color: const Color(0xFF1565C0)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(rule.description),
                  const SizedBox(height: 4),
                  Text(
                    rule.value,
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: rule.active, onChanged: onToggle),
            IconButton(
              tooltip: 'Hapus',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketingRule {
  const _MarketingRule({
    required this.title,
    required this.description,
    required this.value,
    required this.active,
    required this.icon,
  });

  final String title;
  final String description;
  final String value;
  final bool active;
  final IconData icon;

  _MarketingRule copyWith({bool? active}) {
    return _MarketingRule(
      title: title,
      description: description,
      value: value,
      active: active ?? this.active,
      icon: icon,
    );
  }
}

void _showMarketingRuleDialog({
  required BuildContext context,
  required String title,
  required String codeLabel,
  required String valueLabel,
  required ValueChanged<_MarketingRule> onSubmit,
}) {
  final formKey = GlobalKey<FormState>();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final valueController = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TextField(controller: codeController, label: codeLabel),
              _TextField(
                controller: descriptionController,
                label: 'Deskripsi',
                maxLines: 2,
              ),
              _TextField(controller: valueController, label: valueLabel),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              onSubmit(
                _MarketingRule(
                  title: codeController.text.trim().toUpperCase(),
                  description: descriptionController.text.trim(),
                  value: valueController.text.trim(),
                  active: true,
                  icon: title.contains('Voucher')
                      ? Icons.confirmation_number_outlined
                      : Icons.local_offer_outlined,
                ),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Simpan'),
          ),
        ],
      );
    },
  ).whenComplete(() {
    codeController.dispose();
    descriptionController.dispose();
    valueController.dispose();
  });
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
    );
  }
}

class _AdminHeroCard extends StatelessWidget {
  const _AdminHeroCard({required this.admin});

  final AdminProvider admin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x221E3A8A),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Operasional',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantau produk, pesanan, dan performa toko dalam satu tempat.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _AdminStatPill(label: 'Produk aktif', value: '${admin.totalProducts}'),
              _AdminStatPill(label: 'Pesanan', value: '${admin.totalOrders}'),
              _AdminStatPill(label: 'Revenue', value: 'Rp ${formatNumber(admin.totalRevenue)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminStatPill extends StatelessWidget {
  const _AdminStatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SalesChartCard extends StatelessWidget {
  const _SalesChartCard({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 220,
          child: CustomPaint(
            painter: _BarChartPainter(values),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1565C0);
    final axisPaint = Paint()
      ..color = const Color(0xFFE0E7F1)
      ..strokeWidth = 1;
    final maxValue = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b);
    final barWidth = size.width / (values.length * 2);

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );
    for (var i = 0; i < values.length; i++) {
      final height = maxValue <= 0
          ? 8.0
          : (values[i] / maxValue) * (size.height - 24);
      final left = (i * 2 + 0.5) * barWidth;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  const _AdminMenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFF1565C0),
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 34),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSideNav extends StatelessWidget {
  const _AdminSideNav({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Dashboard', Icons.dashboard_outlined),
      ('Produk', Icons.inventory_2_outlined),
      ('Kategori', Icons.category_outlined),
      ('Pesanan', Icons.receipt_long_outlined),
      ('Statistik', Icons.bar_chart_outlined),
      ('Laporan', Icons.description_outlined),
      ('Promo', Icons.local_offer_outlined),
      ('Voucher', Icons.confirmation_number_outlined),
      ('Toko', Icons.storefront_outlined),
    ];
    return Container(
      width: 240,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            selected: selectedIndex == index,
            selectedTileColor: const Color(0xFFEAF3FE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            leading: Icon(item.$2),
            title: Text(item.$1),
            onTap: () => onChanged(index),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionTitle(title: title)),
        FilledButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.numberOnly = false,
    this.integerOnly = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool numberOnly;
  final bool integerOnly;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';
          if (text.isEmpty) return '$label wajib diisi';
          if (integerOnly && int.tryParse(text) == null) {
            return '$label harus berupa angka bulat';
          }
          if (numberOnly && double.tryParse(text) == null) {
            return '$label harus berupa angka';
          }
          return null;
        },
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: rows),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAdminCard extends StatelessWidget {
  const _EmptyAdminCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(message)),
      ),
    );
  }
}

class _EmptyAdminState extends StatelessWidget {
  const _EmptyAdminState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE3F2FD),
              child: Icon(icon, color: const Color(0xFF1565C0), size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.restore_rounded),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isLocalOrNetworkImage(String value) {
  final source = value.trim();
  final uri = Uri.tryParse(source);
  if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
    return true;
  }
  return File(source).existsSync();
}

IconData _adminIconFromName(String name) {
  switch (name.trim()) {
    case 'laptop_mac':
      return Icons.laptop_mac;
    case 'smartphone':
      return Icons.smartphone;
    case 'headphones':
      return Icons.headphones;
    case 'sports_esports':
      return Icons.sports_esports;
    case 'cable':
      return Icons.cable;
    case 'storage':
      return Icons.storage;
    case 'category':
      return Icons.category_outlined;
    default:
      return Icons.category_outlined;
  }
}
