import 'package:flutter/material.dart';
import '../utils/format_utils.dart';

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({
    super.key,
    required this.totalItems,
    required this.subtotal,
    required this.tax,
    required this.grandTotal,
  });

  final int totalItems;
  final double subtotal;
  final double tax;
  final double grandTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ringkasan Pesanan', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _buildRow(context, 'Total Item', '$totalItems'),
            const SizedBox(height: 10),
            _buildRow(context, 'Subtotal', 'Rp ${formatNumber(subtotal)}'),
            const SizedBox(height: 10),
            _buildRow(context, 'PPN 11%', 'Rp ${formatNumber(tax)}'),
            const Divider(height: 26, thickness: 1),
            _buildRow(context, 'Grand Total', 'Rp ${formatNumber(grandTotal)}', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? theme.bodyLarge?.copyWith(fontWeight: FontWeight.w700) : theme.bodyMedium),
        Text(value, style: isTotal ? theme.bodyLarge?.copyWith(fontWeight: FontWeight.w700) : theme.bodyMedium),
      ],
    );
  }
}
