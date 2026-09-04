import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Teal rating chip: "4.5 ★" as seen on cards and the product page.
class RatingPill extends StatelessWidget {
  final double rating;
  final int? count;
  final double fontSize;

  const RatingPill({
    super.key,
    required this.rating,
    this.count,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    if (rating <= 0) return const SizedBox.shrink();
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.tiny.copyWith(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.star_rounded, size: fontSize + 2, color: Colors.white),
        ],
      ),
    );
    if (count == null || count! <= 0) return chip;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip,
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${NumberFormat.decimalPattern('en_IN').format(count)} ratings',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              height: 1,
              color: AppColors.ink3,
            ),
          ),
        ),
      ],
    );
  }
}
