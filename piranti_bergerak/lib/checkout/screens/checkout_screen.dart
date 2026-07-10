import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../cart/providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notification/providers/notification_provider.dart';
import '../../product/providers/product_provider.dart';
import '../models/checkout_address_model.dart';
import 'address_book_screen.dart';
import 'promo_selection_screen.dart';
import 'qr_payment_screen.dart';
import '../providers/checkout_provider.dart';
import '../widgets/address_card.dart';
import '../widgets/shipping_selector.dart';
import '../widgets/payment_selector.dart';
import '../widgets/payment_instruction_card.dart';
import '../widgets/checkout_promo_card.dart';
import '../widgets/checkout_summary_card.dart';
import '../widgets/checkout_product_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return ChangeNotifierProvider(
      create: (_) => CheckoutProvider(cart),
      child: Consumer<CheckoutProvider>(
        builder: (context, prov, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Konfirmasi Pesanan'),
              centerTitle: true,
              elevation: 0,
              backgroundColor: AppColors.surface,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: cart.isEmpty
                ? _buildEmptyCart(context)
                : _buildCheckoutBody(context, cart, prov),
            bottomNavigationBar: cart.isEmpty
                ? null
                : _buildBottomButton(context, prov),
          );
        },
      ),
    );
  }

  Widget _buildCheckoutBody(
    BuildContext context,
    CartProvider cart,
    CheckoutProvider prov,
  ) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth >= 720
              ? 680.0
              : double.infinity;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 12, bottom: 104),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionHeader(
                      context,
                      'Produk yang Dibeli',
                      '${cart.totalItems} item',
                    ),
                    ...cart.items.map(
                      (item) => CheckoutProductCard(
                        item: item,
                        onIncrement: () => cart.increaseQuantity(item.id),
                        onDecrement: () => cart.decreaseQuantity(item.id),
                      ),
                    ),
                    AddressCard(
                      selectedAddress: prov.selectedAddress,
                      isLoading: prov.isLoadingAddresses,
                      onManageAddress: () => _openAddressBook(context, prov),
                    ),
                    ShippingSelector(
                      method: prov.shippingMethod,
                      shippingCost: prov.shippingCost,
                      estimate: prov.shippingEstimate,
                      onChanged: prov.setShipping,
                    ),
                    PaymentSelector(
                      method: prov.paymentMethod,
                      onChanged: prov.setPayment,
                    ),
                    CheckoutPromoCard(
                      appliedPromoCode: prov.appliedPromoCode,
                      appliedPromoName: prov.appliedPromoName,
                      discount: prov.discount,
                      freeShipping: prov.freeShipping,
                      onOpenPromo: () => _openPromoSelection(context, prov),
                    ),
                    CheckoutSummaryCard(
                      subtotal: prov.subtotal,
                      shipping: prov.finalShippingCost,
                      discount: prov.discount,
                      tax: prov.tax,
                      grandTotal: prov.grandTotal,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String trailing) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            trailing,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, CheckoutProvider prov) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.verified_user_rounded, size: 20),
            label: Text(
              prov.paymentMethod == 'QRIS' ||
                      prov.paymentMethod.contains('QRIS')
                  ? 'Bayar Sekarang via QRIS'
                  : 'Konfirmasi Pesanan',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            onPressed: () => _handleCheckout(context, prov),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keranjang Kosong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan produk terlebih dahulu sebelum melakukan pembayaran.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali Belanja'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout(
    BuildContext context,
    CheckoutProvider prov,
  ) async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (!formValid || !prov.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Pilih alamat pengiriman terlebih dahulu.'),
        ),
      );
      return;
    }

    // ── [QRIS INTEGRATION] Jika metode QRIS, buka QrPaymentScreen ─────────
    if (prov.paymentMethod == 'QRIS' || prov.paymentMethod.contains('QRIS')) {
      final invoice = 'INV-${DateTime.now().millisecondsSinceEpoch}';
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QrPaymentScreen(
            amount: prov.grandTotal,
            invoiceNumber: invoice,
            onPaymentSuccess: () async {
              Navigator.of(context).pop(); // Tutup QrPaymentScreen
              try {
                final id = await prov.placeOrder(
                  productProvider: context.read<ProductProvider>(),
                  userId: userId,
                );
                if (!context.mounted) return;

                if (id > 0) {
                  await context
                      .read<NotificationProvider>()
                      .loadNotifications();
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                  ).pushReplacementNamed('/order-success', arguments: id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pesanan gagal dibuat. Silakan coba lagi.'),
                    ),
                  );
                }
              } on CheckoutStockException catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.error,
                    content: Text(error.message),
                  ),
                );
              } catch (_) {
                if (!context.mounted) return;
                Navigator.of(
                  context,
                ).pushReplacementNamed('/order-success', arguments: id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pesanan gagal dibuat. Silakan coba lagi.'),
                  ),
                );
              }
            },
          ),
        ),
      );
      return;
    }

    // ── Metode Pembayaran Lain (Transfer Bank / E-Wallet / COD) ───────────
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Konfirmasi Pesanan',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Apakah Anda yakin ingin menyelesaikan pesanan ini?',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Detail Pembayaran',
                      style: Theme.of(dialogContext).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    PaymentInstructionCard(
                      method: prov.paymentMethod,
                      grandTotal: prov.grandTotal,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Konfirmasi & Buat Pesanan'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    try {
      final id = await prov.placeOrder(
        productProvider: context.read<ProductProvider>(),
        userId: userId,
      );
      if (!context.mounted) return;

      if (id > 0) {
        await context.read<NotificationProvider>().loadNotifications();
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!')),
        );
        Navigator.of(
          context,
        ).pushReplacementNamed('/order-success', arguments: id);
      } else {
        await prov.addCheckoutNotification(
          title: 'Pesanan Gagal',
          message: 'Pesanan gagal dibuat. Silakan coba lagi.',
          userId: userId,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan gagal dibuat. Silakan coba lagi.'),
          ),
        );
      }
    } on CheckoutStockException catch (error) {
      await prov.addCheckoutNotification(
        title: 'Stok Berubah',
        message: error.message,
        userId: userId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(error.message),
        ),
      );
    } catch (_) {
      await prov.addCheckoutNotification(
        title: 'Pesanan Gagal',
        message: 'Terjadi kesalahan saat membuat pesanan.',
        userId: userId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan gagal dibuat. Periksa data lalu coba lagi.'),
        ),
      );
    }
  }

  Future<void> _openAddressBook(
    BuildContext context,
    CheckoutProvider prov,
  ) async {
    final result = await Navigator.of(context).push<CheckoutAddressModel>(
      MaterialPageRoute(
        builder: (_) =>
            AddressBookScreen(selectedAddressId: prov.selectedAddressId),
      ),
    );

    if (result == null || !context.mounted) return;

    prov.selectAddress(result);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alamat pengiriman diperbarui.')),
    );
  }

  Future<void> _openPromoSelection(
    BuildContext context,
    CheckoutProvider prov,
  ) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            PromoSelectionScreen(selectedPromoCode: prov.appliedPromoCode),
      ),
    );

    if (result == null || !context.mounted) return;

    if (result.isEmpty) {
      prov.clearPromo();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kupon promo dihapus.')));
      return;
    }

    final ok = prov.applyPromo(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Kupon promo berhasil digunakan!'
              : 'Kupon promo tidak valid atau kadaluarsa.',
        ),
      ),
    );
  }
}
