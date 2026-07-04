import 'package:flutter/material.dart';

import '../../cart/utils/format_utils.dart';

class ShippingSelector extends StatelessWidget {
  const ShippingSelector({
    super.key,
    required this.method,
    required this.shippingCost,
    required this.estimate,
    required this.onChanged,
  });

  final String method;
  final double shippingCost;
  final String estimate;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: Color(0xFF1565C0),
                ),
                const SizedBox(width: 8),
                Text(
                  'Metode Pengiriman',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: method,
              items: const [
                DropdownMenuItem(
                  value: 'Reguler',
                  child: Text('Reguler - 2-4 Hari'),
                ),
                DropdownMenuItem(
                  value: 'Express',
                  child: Text('Express - 1-2 Hari'),
                ),
                DropdownMenuItem(
                  value: 'Same Day',
                  child: Text('Same Day - Hari Ini'),
                ),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
            const SizedBox(height: 10),
            Text(
              '$estimate - Rp ${formatNumber(shippingCost)}',
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
