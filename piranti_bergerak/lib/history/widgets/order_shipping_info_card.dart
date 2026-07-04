import 'package:flutter/material.dart';

import '../../checkout/models/order_model.dart';

class OrderShippingInfoCard extends StatelessWidget {
  const OrderShippingInfoCard({super.key, required this.order});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on_outlined, color: Color(0xFF1565C0)),
                SizedBox(width: 8),
                Text(
                  'Informasi Pengiriman',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoLine(label: 'Penerima', value: order.customerName),
            _InfoLine(label: 'Nomor HP', value: order.phone),
            _InfoLine(label: 'Alamat', value: order.address),
            if (order.note.isNotEmpty)
              _InfoLine(label: 'Catatan', value: order.note),
            _InfoLine(label: 'Pengiriman', value: order.shippingMethod),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
