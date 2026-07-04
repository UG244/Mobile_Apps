import 'package:flutter/material.dart';

import '../../cart/utils/format_utils.dart';
import '../../checkout/models/order_model.dart';

class OrderPaymentSummaryCard extends StatelessWidget {
  const OrderPaymentSummaryCard({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.payments_outlined, color: Color(0xFF1565C0)),
                SizedBox(width: 8),
                Text(
                  'Informasi Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row('Metode Pembayaran', order.paymentMethod),
            const SizedBox(height: 8),
            _row('Subtotal', 'Rp ${formatNumber(order.subtotal)}'),
            const SizedBox(height: 8),
            _row('Ongkir', 'Rp ${formatNumber(order.shippingCost)}'),
            const SizedBox(height: 8),
            _row('PPN 11%', 'Rp ${formatNumber(order.tax)}'),
            if (order.discount > 0) ...[
              const SizedBox(height: 8),
              _row('Diskon', '- Rp ${formatNumber(order.discount)}'),
            ],
            const Divider(height: 22),
            _row(
              'Grand Total',
              'Rp ${formatNumber(order.grandTotal)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.black54,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? const Color(0xFF1565C0) : Colors.black,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
