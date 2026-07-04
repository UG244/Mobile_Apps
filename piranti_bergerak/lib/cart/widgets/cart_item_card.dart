import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import 'quantity_button.dart';
import '../utils/format_utils.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImage(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(item.category, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 8),
                  Text('Rp ${formatNumber(item.price)}', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      QuantityButton(icon: Icons.remove, onPressed: onDecrement, disabled: item.quantity <= 1),
                      const SizedBox(width: 8),
                      Text('${item.quantity}', style: theme.textTheme.titleMedium),
                      const SizedBox(width: 8),
                      QuantityButton(icon: Icons.add, onPressed: onIncrement),
                      const Spacer(),
                      IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline_rounded), color: theme.colorScheme.error),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('Rp ${formatNumber(item.subtotal)}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        item.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.image_not_supported_rounded, size: 28),
          );
        },
      ),
    );
  }
}
