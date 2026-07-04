import 'package:flutter/material.dart';
import '../../cart/utils/format_utils.dart';

class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.tax,
    required this.grandTotal,
  });

  final double subtotal;
  final double shipping;
  final double discount;
  final double tax;
  final double grandTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ringkasan Pembayaran',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _row('Subtotal', 'Rp ${formatNumber(subtotal)}'),
            const SizedBox(height: 8),
            _row('Ongkir', 'Rp ${formatNumber(shipping)}'),
            const SizedBox(height: 8),
            _row('Diskon', '- Rp ${formatNumber(discount)}'),
            const SizedBox(height: 8),
            _row('PPN 11%', 'Rp ${formatNumber(tax)}'),
            const Divider(height: 20),
            _row(
              'Grand Total',
              'Rp ${formatNumber(grandTotal)}',
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
        Text(
          label,
          style: isTotal ? const TextStyle(fontWeight: FontWeight.w700) : null,
        ),
        Text(
          value,
          style: isTotal ? const TextStyle(fontWeight: FontWeight.w700) : null,
        ),
      ],
    );
  }
}
