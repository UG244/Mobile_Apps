import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../utils/format_utils.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'Ringkasan Biaya Belanja',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _row('Total Harga Item', 'Rp ${formatNumber(subtotal)}'),
          const SizedBox(height: 10),
          _row('Ongkos Kirim (Denpasar)', 'Rp ${formatNumber(shipping)}'),
          if (discount > 0) ...[
            const SizedBox(height: 10),
            _row('Diskon / Promo', '- Rp ${formatNumber(discount)}', isDiscount: true),
          ],
          const SizedBox(height: 10),
          _row('PPN (11%)', 'Rp ${formatNumber(tax)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _row(
            'Grand Total',
            'Rp ${formatNumber(grandTotal)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13.5,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: isTotal
                ? AppColors.accent
                : (isDiscount ? AppColors.success : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
