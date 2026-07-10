import 'package:flutter/material.dart';

import '../../cart/utils/format_utils.dart';

class CheckoutPromoCard extends StatelessWidget {
  const CheckoutPromoCard({
    super.key,
    required this.appliedPromoCode,
    required this.appliedPromoName,
    required this.discount,
    required this.freeShipping,
    required this.onOpenPromo,
  });

  final String? appliedPromoCode;
  final String? appliedPromoName;
  final double discount;
  final bool freeShipping;
  final VoidCallback onOpenPromo;

  @override
  Widget build(BuildContext context) {
    final hasPromo = appliedPromoCode != null;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpenPromo,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Kupon / Promo',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hasPromo
                          ? _promoSummary
                          : 'Pilih kupon untuk hemat belanja',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasPromo
                            ? const Color(0xFF2E7D32)
                            : Colors.black54,
                        fontWeight: hasPromo
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF1565C0)),
            ],
          ),
        ),
      ),
    );
  }

  String get _promoSummary {
    if (freeShipping) return '$appliedPromoName aktif';
    return '$appliedPromoName aktif - hemat Rp ${formatNumber(discount)}';
  }
}
