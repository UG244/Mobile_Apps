import 'package:flutter/material.dart';

class EmptyOrderWidget extends StatelessWidget {
  const EmptyOrderWidget({super.key, required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: Color(0xFF1565C0),
            ),
            const SizedBox(height: 14),
            const Text(
              'Belum ada pesanan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pesanan yang sudah dibuat akan tampil di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onShop,
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Mulai Belanja'),
            ),
          ],
        ),
      ),
    );
  }
}
