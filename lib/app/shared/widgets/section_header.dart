import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h3),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                children: [
                  Text(actionLabel!, style: AppTextStyles.label.copyWith(color: AppColors.action, fontWeight: FontWeight.w700)),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.action),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
