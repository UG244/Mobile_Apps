import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../cart/utils/format_utils.dart';
import '../../checkout/models/order_detail_model.dart';
import '../../product/widgets/product_image.dart';

class OrderDetailProductItem extends StatelessWidget {
  const OrderDetailProductItem({super.key, required this.detail});

  final OrderDetailModel detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: ProductImage(
                imageUrl: detail.imageUrl,
                placeholderSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${detail.quantity} x Rp ${formatNumber(detail.price)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rp ${formatNumber(detail.total)}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14.5,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
