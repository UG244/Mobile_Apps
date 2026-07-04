import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class PromoCard extends StatefulWidget {
  const PromoCard({super.key});

  @override
  State<PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<PromoCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kode Promo', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan Kode Promo',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final code = _controller.text;
                    final ok = provider.applyPromo(code);
                    if (ok) {
                      _controller.clear();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✔ Promo berhasil digunakan')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kode promo tidak valid')));
                    }
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            ),
            if (provider.appliedPromo != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('Promo ${provider.appliedPromo} diterapkan', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(onPressed: () => provider.clearPromo(), child: const Text('Hapus')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
