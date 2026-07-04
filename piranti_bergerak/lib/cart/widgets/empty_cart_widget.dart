import 'package:flutter/material.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key, required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 96, color: color.withAlpha((0.9 * 255).round())),
            const SizedBox(height: 20),
            Text('Keranjang masih kosong', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Tambahkan produk favoritmu ke keranjang dan nikmati penawaran terbaik dari BlueMart Retail.', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onShop, child: const Text('Mulai Belanja')),
          ],
        ),
      ),
    );
  }
}
