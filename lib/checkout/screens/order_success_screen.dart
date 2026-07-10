import 'package:flutter/material.dart';

import '../../cart/utils/format_utils.dart';
import '../db/order_db.dart';
import '../models/order_model.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, this.orderId});

  final int? orderId;

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final id = arg is int ? arg : orderId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pesanan Berhasil'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1565C0),
      ),
      body: FutureBuilder<OrderModel?>(
        future: id == null
            ? Future.value(null)
            : OrderDb.instance.getOrderById(id),
        builder: (context, snapshot) {
          final order = snapshot.data;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32),
                          size: 88,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pesanan Berhasil',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Terima kasih. Pesanan BlueMart Retail Anda sudah dibuat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        _InfoRow(
                          label: 'Nomor Invoice',
                          value: order?.invoice ?? (id == null ? '-' : '#$id'),
                        ),
                        const SizedBox(height: 10),
                        _InfoRow(
                          label: 'Total Pembayaran',
                          value: order == null
                              ? '-'
                              : 'Rp ${formatNumber(order.grandTotal)}',
                          emphasized: true,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.tonal(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/orders');
                          },
                          child: const Text('Lihat Riwayat Pesanan'),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (r) => false),
                          child: const Text('Kembali ke Homepage'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: emphasized ? const Color(0xFF1565C0) : Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
