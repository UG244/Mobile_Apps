import 'package:flutter/material.dart';

import '../../cart/utils/format_utils.dart';
import '../../checkout/models/order_detail_model.dart';

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: detail.imageUrl.isEmpty
                ? _buildFallbackImage()
                : Image.network(
                    detail.imageUrl,
                    width: 66,
                    height: 66,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildFallbackImage(),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '${detail.quantity} x Rp ${formatNumber(detail.price)}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Rp ${formatNumber(detail.total)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 66,
      height: 66,
      color: const Color(0xFFEAF3FE),
      child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF1565C0)),
    );
  }
}
