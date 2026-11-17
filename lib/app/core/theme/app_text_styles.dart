import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Inter-based type scale with slightly tightened tracking on headings,
/// bundled in assets/fonts so it renders the same offline and on first run.
class AppTextStyles {
  AppTextStyles._();

  static const family = 'Inter';

  static const h1 = TextStyle(
    fontFamily: family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );
  static const h2 = TextStyle(
    fontFamily: family,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );
  static const h3 = TextStyle(
    fontFamily: family,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );
  static const title = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.ink,
  );
  static const body = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: AppColors.ink,
  );
  static const bodyMedium = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: AppColors.ink,
  );
  static const label = TextStyle(
    fontFamily: family,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: AppColors.ink2,
  );
  static const caption = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.ink3,
  );
  static const tiny = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.ink3,
  );

  /// Small uppercase tag text, e.g. "LIMITED SLOTS" / "CATERER" badges.
  static const tag = TextStyle(
    fontFamily: family,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.ink2,
  );
  static const price = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );
  static const priceStrike = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.ink3,
    decoration: TextDecoration.lineThrough,
  );
  static const button = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.onBrand,
  );
}
