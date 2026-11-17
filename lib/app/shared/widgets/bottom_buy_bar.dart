import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

/// The fixed bottom action bar on product detail / cart / checkout screens.
///
/// Product detail matches the prototype's two-button `.buybar`: a hollow
/// "ADD TO CART" beside a filled "BUY NOW" — pass [secondaryLabel] /
/// [onSecondaryAction] to get that layout; omit them for the single-button
/// bar used on cart/checkout.
class BottomBuyBar extends StatelessWidget {
  final Widget? leading;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool loading;
  final bool enabled;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryAction;

  const BottomBuyBar({
    super.key,
    this.leading,
    required this.actionLabel,
    this.onAction,
    this.loading = false,
    this.enabled = true,
    this.secondaryLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              if (leading != null)
                SizedBox(
                  width: 148,
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: leading!,
                    ),
                  ),
                ),
              if (secondaryLabel != null)
                Expanded(
                  child: _BarButton(
                    label: secondaryLabel!,
                    onPressed: enabled ? onSecondaryAction : null,
                    filled: false,
                    loading: false,
                  ),
                ),
              if (secondaryLabel != null) const SizedBox(width: 10),
              Expanded(
                child: _BarButton(
                  label: actionLabel,
                  onPressed: enabled ? onAction : null,
                  filled: true,
                  loading: loading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final bool loading;

  const _BarButton({
    required this.label,
    required this.onPressed,
    required this.filled,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !loading;
    return Material(
      color: filled
          ? AppColors.brand.withValues(alpha: disabled ? 0.35 : 1)
          : AppColors.brandSoft,
      borderRadius: BorderRadius.circular(AppRadius.button),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: loading ? null : onPressed,
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onBrand,
                  ),
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.button.copyWith(
                    color: filled ? AppColors.onBrand : AppColors.brand,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}
