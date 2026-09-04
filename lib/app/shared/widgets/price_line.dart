import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';

/// Price + strikethrough MRP + discount percent, as seen on every product
/// card and cart line in the prototype.
class PriceLine extends StatelessWidget {
  final double price;
  final double? mrp;
  final int? discountPercent;
  final double priceSize;

  /// Card grids give this widget a fixed-height cell — wrapping to a second
  /// line there overflows it. Set true to force one line (MRP dropped first,
  /// then the whole line ellipsized) instead of wrapping.
  final bool singleLine;

  const PriceLine({
    super.key,
    required this.price,
    this.mrp,
    this.discountPercent,
    this.priceSize = 16,
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = mrp != null && mrp! > price;
    final children = [
      Text(
        formatInr(price),
        style: AppTextStyles.price.copyWith(fontSize: priceSize),
      ),
      if (hasDiscount) Text(formatInr(mrp!), style: AppTextStyles.priceStrike),
      if (hasDiscount && (discountPercent ?? 0) > 0)
        Text(
          '$discountPercent% off',
          style: AppTextStyles.tiny.copyWith(
            color: AppColors.deal,
            fontWeight: FontWeight.w700,
          ),
        ),
    ];

    if (!singleLine) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final tight =
              constraints.maxWidth.isFinite && constraints.maxWidth < 116;
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: tight ? 4 : 6,
            runSpacing: 1,
            children: tight
                ? [
                    Text(
                      formatInr(price),
                      style: AppTextStyles.price.copyWith(
                        fontSize: priceSize - 1,
                      ),
                    ),
                    if (hasDiscount && (discountPercent ?? 0) > 0)
                      Text(
                        '$discountPercent% off',
                        style: AppTextStyles.tiny.copyWith(
                          color: AppColors.deal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ]
                : children,
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final showMrp =
            hasDiscount &&
            (!constraints.maxWidth.isFinite || constraints.maxWidth >= 96);
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 3,
              child: Text(
                formatInr(price),
                style: AppTextStyles.price.copyWith(fontSize: priceSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (showMrp) ...[
              const SizedBox(width: 5),
              Flexible(
                flex: 2,
                child: Text(
                  formatInr(mrp!),
                  style: AppTextStyles.priceStrike,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
