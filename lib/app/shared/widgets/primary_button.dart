import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.expand = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.onBrand,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.onBrand),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.button),
            ],
          );
    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: child,
    );
    return expand
        ? SizedBox(
            width: double.infinity,
            height: 54,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: button,
            ),
          )
        : button;
  }
}
