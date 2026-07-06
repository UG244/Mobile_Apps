import 'package:flutter/material.dart';

import '../../cart/models/cart_item_model.dart';
import '../../cart/utils/format_utils.dart';
import '../../cart/widgets/quantity_button.dart';

class CheckoutProductCard extends StatelessWidget {
  const CheckoutProductCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFE8EEF6),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFF1565C0),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${formatNumber(item.price)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      QuantityButton(
                        icon: Icons.remove,
                        onPressed: onDecrement,
                        disabled: item.quantity <= 1,
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      QuantityButton(icon: Icons.add, onPressed: onIncrement),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Rp ${formatNumber(item.subtotal)}',
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
