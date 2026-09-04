import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';

enum PillTone { info, ok, warn, critical, neutral }

/// Small pill-shaped status/label chip — mirrors the prototype's
/// `.badge`/`.chip` CSS classes (order status, coupon codes, tags…).
class PillBadge extends StatelessWidget {
  final String label;
  final PillTone tone;
  final IconData? icon;

  const PillBadge({
    super.key,
    required this.label,
    this.tone = PillTone.neutral,
    this.icon,
  });

  ({Color bg, Color fg}) get _colors {
    switch (tone) {
      case PillTone.info:
        return (bg: AppColors.infoBg, fg: AppColors.infoInk);
      case PillTone.ok:
        return (bg: AppColors.okBg, fg: AppColors.okInk);
      case PillTone.warn:
        return (bg: AppColors.warnBg, fg: AppColors.warnInk);
      case PillTone.critical:
        return (bg: AppColors.critBg, fg: AppColors.critInk);
      case PillTone.neutral:
        return (bg: AppColors.surface2, fg: AppColors.ink2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: c.fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.tiny.copyWith(
              color: c.fg,
              fontSize: 9.5,
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
