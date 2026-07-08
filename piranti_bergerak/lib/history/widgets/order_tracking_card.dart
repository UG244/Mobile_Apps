import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'Status & Pelacakan Pesanan',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Perkiraan sampai: $estimatedArrival',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: step.isActive
                              ? AppColors.accent
                              : (step.isDone ? AppColors.accent.withValues(alpha: 0.15) : AppColors.surfaceVariant),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step.icon,
                          size: 16,
                          color: step.isActive ? Colors.white : (step.isDone ? AppColors.accent : AppColors.textHint),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: step.isDone ? AppColors.accent : AppColors.border,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.title,
                            style: TextStyle(
                              color: step.isDone ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: step.isActive || step.isDone ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            step.description,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
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
    );
  }
}
