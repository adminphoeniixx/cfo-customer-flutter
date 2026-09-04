import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Roboto-based type scale, proportioned after the HTML prototype
/// (11/12/13/14/15/18/20/21px body sizes, 700/900 weight headings).
class AppTextStyles {
  AppTextStyles._();

  static const _family = 'Roboto';

  static const h1 = TextStyle(
      fontFamily: _family, fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.ink);
  static const h2 = TextStyle(
      fontFamily: _family, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const h3 = TextStyle(
      fontFamily: _family, fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const title = TextStyle(
      fontFamily: _family, fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const body = TextStyle(
      fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.ink);
  static const bodyMedium = TextStyle(
      fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink);
  static const label = TextStyle(
      fontFamily: _family, fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink2);
  static const caption = TextStyle(
      fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.ink3);
  static const tiny = TextStyle(
      fontFamily: _family, fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.ink3);
  static const price = TextStyle(
      fontFamily: _family, fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink);
  static const priceStrike = TextStyle(
      fontFamily: _family,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.ink3,
      decoration: TextDecoration.lineThrough);
  static const button = TextStyle(
      fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onBrand);
}
