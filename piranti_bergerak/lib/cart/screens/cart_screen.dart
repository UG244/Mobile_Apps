import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/checkout_button.dart';
import '../widgets/empty_cart_widget.dart';
import '../widgets/no_overscroll_behavior.dart';
import '../widgets/slow_down_scroll_physics.dart';
import '../utils/format_utils.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CartScreenContent();
  }
}

class _CartScreenContent extends StatelessWidget {
  const _CartScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: colorScheme.primary,
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/', (route) => false),
        ),
      ),
      body: provider.isEmpty
          ? _buildEmpty(context, provider)
          : _buildContent(context, provider),
      bottomNavigationBar: provider.isEmpty
          ? null
          : CheckoutButton(
              label: 'Checkout • Rp ${formatNumber(provider.grandTotal)}',
              enabled: !provider.isEmpty,
              onPressed: () => Navigator.of(context).pushNamed('/checkout'),
            ),
    );
  }

  Widget _buildContent(BuildContext context, CartProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => Future.value(),
                child: ScrollConfiguration(
                  behavior: const NoOverscrollBehavior(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: SlowDownScrollPhysics(
                        velocityFactor: 0.5,
                        dragFactor: 0.65,
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    itemCount: provider.items.length + 1,
                    itemBuilder: (context, index) {
                      if (index < provider.items.length) {
                        final item = provider.items[index];
                        return CartItemCard(
                          item: item,
                          onIncrement: () => provider.increaseQuantity(item.id),
                          onDecrement: () => provider.decreaseQuantity(item.id),
                          onRemove: () =>
                              _confirmDelete(context, provider, item.id),
                        );
                      }
                      return OrderSummaryCard(
                        subtotal: provider.subtotal,
                        shipping: provider.shipping,
                        discount: 0,
                        tax: provider.tax,
                        grandTotal: provider.grandTotal,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context, CartProvider provider) {
    return EmptyCartWidget(onShop: () => provider.refillCart());
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CartProvider provider,
    String itemId,
  ) async {
    final dialogContext = context;
    final confirmed =
        await showDialog<bool>(
          context: dialogContext,
          builder: (innerContext) {
            return AlertDialog(
              title: const Text('Hapus Produk'),
              content: const Text(
                'Apakah Anda yakin ingin menghapus produk ini dari keranjang?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(innerContext).pop(false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(innerContext).pop(true),
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;
    if (!context.mounted) return;
    provider.removeItem(itemId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dihapus dari keranjang.')),
    );
  }
}
