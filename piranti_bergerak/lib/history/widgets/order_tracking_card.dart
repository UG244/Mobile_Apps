import 'package:flutter/material.dart';

import '../providers/order_provider.dart';

class OrderTrackingCard extends StatelessWidget {
  const OrderTrackingCard({
    super.key,
    required this.summary,
    required this.estimatedArrival,
    required this.steps,
  });

  final String summary;
  final String estimatedArrival;
  final List<OrderTrackingStep> steps;

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
                Icon(Icons.route_outlined, color: Color(0xFF1565C0)),
                SizedBox(width: 8),
                Text(
                  'Lacak Pesanan',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Perkiraan sampai: $estimatedArrival',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isLast = index == steps.length - 1;
              final color = step.isDone
                  ? const Color(0xFF1565C0)
                  : const Color(0xFFB0BEC5);

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: step.isActive
                                ? color
                                : color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Icon(
                            step.icon,
                            size: 18,
                            color: step.isActive ? Colors.white : color,
                          ),
                        ),
                        if (!isLast)
                          Expanded(child: Container(width: 2, color: color)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                color: step.isDone
                                    ? Colors.black
                                    : Colors.black45,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              step.description,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
