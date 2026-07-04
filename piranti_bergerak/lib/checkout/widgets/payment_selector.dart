import 'package:flutter/material.dart';

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
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFF1565C0),
                ),
                const SizedBox(width: 8),
                Text(
                  'Metode Pembayaran',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _PaymentOption(
              label: 'Transfer Bank',
              icon: Icons.account_balance_outlined,
              selected: method == 'Transfer Bank',
              onTap: () => onChanged('Transfer Bank'),
            ),
            _PaymentOption(
              label: 'E-Wallet',
              icon: Icons.wallet_outlined,
              selected: method == 'E-Wallet',
              onTap: () => onChanged('E-Wallet'),
            ),
            _PaymentOption(
              label: 'COD',
              icon: Icons.payments_outlined,
              selected: method == 'COD',
              onTap: () => onChanged('COD'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1565C0) : Colors.black54;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
