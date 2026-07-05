import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../cart/providers/cart_provider.dart';
import '../../notification/providers/notification_provider.dart';
import '../models/checkout_address_model.dart';
import 'address_book_screen.dart';
import 'promo_selection_screen.dart';
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
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              title: const Text('Checkout'),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1565C0),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
                      (item) => CheckoutProductCard(item: item),
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(trailing, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, CheckoutProvider prov) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 14,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () => _handleCheckout(context, prov),
            child: const Text(
              'Konfirmasi Pesanan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: Color(0xFF1565C0),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keranjang Kosong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan produk terlebih dahulu sebelum checkout.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kembali'),
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
    if (!formValid || !prov.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih alamat pengiriman terlebih dahulu.'),
        ),
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Konfirmasi Pesanan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Apakah Anda yakin ingin membuat pesanan?'),
                    const SizedBox(height: 14),
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
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Konfirmasi'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !context.mounted) return;

    try {
      final id = await prov.placeOrder();
      if (!context.mounted) return;

      if (id > 0) {
        await context.read<NotificationProvider>().loadNotifications();
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat.')),
        );
        Navigator.of(
          context,
        ).pushReplacementNamed('/order-success', arguments: id);
      } else {
        await prov.addCheckoutNotification(
          title: 'Pesanan Gagal',
          message: 'Pesanan gagal dibuat. Silakan coba lagi.',
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan gagal dibuat. Silakan coba lagi.'),
          ),
        );
      }
    } catch (_) {
      await prov.addCheckoutNotification(
        title: 'Pesanan Gagal',
        message: 'Terjadi kesalahan saat membuat pesanan.',
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Alamat pengiriman dipilih.')));
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
      ).showSnackBar(const SnackBar(content: Text('Kupon dihapus.')));
      return;
    }

    final ok = prov.applyPromo(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Kupon berhasil digunakan.' : 'Kupon tidak tersedia.',
        ),
      ),
    );
  }
}
