import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../cart/utils/format_utils.dart';
import '../../checkout/models/order_model.dart';

class OrderPaymentSummaryCard extends StatelessWidget {
  const OrderPaymentSummaryCard({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Icon(Icons.account_balance_wallet_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'Rincian Biaya & Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _row('Metode Pembayaran', order.paymentMethod),
          const SizedBox(height: 10),
          _row('Total Harga Produk', 'Rp ${formatNumber(order.subtotal)}'),
          const SizedBox(height: 10),
          _row('Ongkos Kirim', 'Rp ${formatNumber(order.shippingCost)}'),
          const SizedBox(height: 10),
          _row('PPN (11%)', 'Rp ${formatNumber(order.tax)}'),
          if (order.discount > 0) ...[
            const SizedBox(height: 10),
            _row('Diskon / Promo', '- Rp ${formatNumber(order.discount)}', isDiscount: true),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _row(
            'Total Pembayaran',
            'Rp ${formatNumber(order.grandTotal)}',
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
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            fontSize: isTotal ? 14.5 : 13.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? AppColors.accent
                : (isDiscount ? AppColors.success : AppColors.textPrimary),
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            fontSize: isTotal ? 17 : 13.5,
          ),
        ),
      ],
    );
  }
}
