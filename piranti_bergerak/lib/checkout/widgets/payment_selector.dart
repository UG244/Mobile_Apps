import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PaymentSelector extends StatelessWidget {
  const PaymentSelector({
    super.key,
    required this.method,
    required this.onChanged,
  });

  final String method;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.qr_code_rounded, color: AppColors.accent, size: 22),
              SizedBox(width: 8),
              Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            label: 'QRIS (Scan & Pay Instan)',
            subtitle: 'BCA, Mandiri, GoPay, OVO, Dana, ShopeePay',
            icon: Icons.qr_code_2_rounded,
            badge: 'REKOMENDASI',
            selected: method == 'QRIS' || method == 'QRIS (Scan & Pay Instan)',
            onTap: () => onChanged('QRIS'),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _PaymentOption(
            label: 'Transfer Bank (Virtual Account)',
            subtitle: 'BCA, Mandiri, BNI, BRI, BSI',
            icon: Icons.account_balance_rounded,
            selected: method == 'Transfer Bank',
            onTap: () => onChanged('Transfer Bank'),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _PaymentOption(
            label: 'E-Wallet',
            subtitle: 'GoPay, OVO, Dana, LinkAja',
            icon: Icons.account_balance_wallet_rounded,
            selected: method == 'E-Wallet',
            onTap: () => onChanged('E-Wallet'),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _PaymentOption(
            label: 'Bayar di Tempat (COD)',
            subtitle: 'Bayar tunai kepada kurir saat barang tiba',
            icon: Icons.local_shipping_rounded,
            selected: method == 'COD',
            onTap: () => onChanged('COD'),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? AppColors.accent.withOpacity(0.12) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.accent : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.5,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.accent : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
