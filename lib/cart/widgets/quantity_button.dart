import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
      width: 32,
      height: 32,
      child: Material(
        color: disabled ? AppColors.surfaceVariant : (color ?? AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: disabled ? AppColors.border : AppColors.accent,
            width: 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: disabled ? null : onPressed,
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: disabled ? AppColors.textHint : AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}
