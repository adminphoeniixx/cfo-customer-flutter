import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: AppColors.brandSoft, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: AppColors.brand),
            ),
            const SizedBox(height: AppSpace.lg),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpace.xs),
              Text(message!, style: AppTextStyles.body.copyWith(color: AppColors.ink3), textAlign: TextAlign.center),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpace.lg),
              PrimaryButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}
