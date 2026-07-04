import 'package:flutter/material.dart';

import '../../cart/utils/format_utils.dart';
import '../../checkout/models/order_model.dart';
import 'order_status_chip.dart';

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({
    super.key,
    required this.order,
    required this.totalItems,
    required this.formattedDate,
    required this.statusColor,
    required this.onTap,
  });

  final OrderModel order;
  final int totalItems;
  final String formattedDate;
  final Color statusColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      order.invoice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  OrderStatusChip(status: order.status, color: statusColor),
                ],
              ),
              const SizedBox(height: 12),
              _InfoLine(label: 'Tanggal', value: formattedDate),
              const SizedBox(height: 6),
              _InfoLine(label: 'Jumlah Barang', value: '$totalItems item'),
              const SizedBox(height: 6),
              _InfoLine(label: 'Pembayaran', value: order.paymentMethod),
              const Divider(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Rp ${formatNumber(order.grandTotal)}',
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    return Row(
      children: [
        SizedBox(
          width: 112,
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
    );
  }
}
