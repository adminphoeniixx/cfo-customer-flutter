import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icons.dart';

/// Rating as "★ 4.5 (1,323)": olive star, bold score, muted count.
class RatingPill extends StatelessWidget {
  final double rating;
  final int? count;
  final double fontSize;

  const RatingPill({
    super.key,
    required this.rating,
    this.count,
    this.fontSize = 11.5,
  });

  @override
  Widget build(BuildContext context) {
    if (rating <= 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(AppIcons.star, size: fontSize + 2, color: AppColors.brand),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.tiny.copyWith(
            color: AppColors.ink,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        if (count != null && count! > 0) ...[
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              '(${NumberFormat.decimalPattern('en_IN').format(count)})',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: fontSize,
                height: 1,
                color: AppColors.ink3,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
