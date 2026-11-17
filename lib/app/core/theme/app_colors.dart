import 'package:flutter/material.dart';

/// Single source of truth for every colour role used in the app.
/// Olive / off-white palette: warm off-white ground, white cards, dark
/// olive as the brand colour and a lime accent for hero call-to-actions.
class AppColors {
  AppColors._();

  static const brand = Color(0xFF4A5723);
  static const brandSoft = Color(0xFFE9EDDB);
  static const onBrand = Color(0xFFFFFFFF);

  /// Lime highlight used for hero CTAs and "new / beta" tags.
  static const accent = Color(0xFFD6EC52);
  static const onAccent = Color(0xFF1B1D14);

  static const chrome = Color(0xFFF4F4EF);
  static const chromeInk = Color(0xFF1B1D14);
  static const ground = Color(0xFFF4F4EF);

  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFEFEFE9);
  static const line = Color(0xFFE6E6DF);
  static const lineSoft = Color(0xFFEFEFE9);

  static const ink = Color(0xFF1B1D14);
  static const ink2 = Color(0xFF4B4D44);
  static const ink3 = Color(0xFF8B8C84);

  static const action = Color(0xFF3E4A1C);
  static const deal = Color(0xFF4E7A1F);
  static const dealSoft = Color(0xFFEAF1DA);
  static const sale = Color(0xFFB2611A);
  static const gold = Color(0xFF4A5723);
  static const teal = Color(0xFF4A5723);
  static const critical = Color(0xFFC2402F);

  static const okBg = Color(0xFFEAF1DA);
  static const okInk = Color(0xFF3E5C17);
  static const warnBg = Color(0xFFF8EFD9);
  static const warnInk = Color(0xFF85581A);
  static const infoBg = Color(0xFFEEF0E2);
  static const infoInk = Color(0xFF4A5723);
  static const critBg = Color(0xFFFAE8E4);
  static const critInk = Color(0xFFA2321F);

  /// Scrim behind dark hero banners (text over photos).
  static const heroScrim = Color(0xCC14160E);

  static const page = Color(0xFFE9E9E2);
}
