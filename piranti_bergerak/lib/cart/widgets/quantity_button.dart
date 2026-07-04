import 'package:flutter/material.dart';

class QuantityButton extends StatelessWidget {
  const QuantityButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.disabled = false,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool disabled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: BorderSide(color: Theme.of(context).colorScheme.outline.withAlpha((0.6 * 255).round())),
          padding: EdgeInsets.zero,
          backgroundColor: color ?? Colors.transparent,
        ),
        child: Icon(icon, size: 18, color: disabled ? Colors.grey.shade400 : null),
      ),
    );
  }
}
