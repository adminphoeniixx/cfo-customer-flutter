import 'package:flutter/material.dart';

/// Single source of truth for every colour role used in the app.
/// Mirrors the `:root` CSS variables of the HTML prototype exactly, so a
/// re-brand later is a one-file change.
class AppColors {
  AppColors._();

  static const brand = Color(0xFFDD2F60);
  static const brandSoft = Color(0xFFFFE7ED);
  static const onBrand = Color(0xFFFFFFFF);

  static const chrome = Color(0xFFFEEBE5);
  static const chromeInk = Color(0xFF282C3F);
  static const ground = Color(0xFFFEEBE5);

  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFFDF0E8);
  static const line = Color(0xFFF4E2DA);
  static const lineSoft = Color(0xFFF7ECE6);

  static const ink = Color(0xFF282C3F);
  static const ink2 = Color(0xFF4D4D58);
  static const ink3 = Color(0xFF6E6A72);

  static const action = Color(0xFFCC1A4F);
  static const deal = Color(0xFF016A57);
  static const dealSoft = Color(0xFFE3F7F1);
  static const sale = Color(0xFFC0530F);
  static const gold = Color(0xFFFFA53B);
  static const teal = Color(0xFF0F7D78);
  static const critical = Color(0xFFD0021B);

  static const okBg = Color(0xFFE3F7F1);
  static const okInk = Color(0xFF016450);
  static const warnBg = Color(0xFFFFF3E4);
  static const warnInk = Color(0xFF8A4B12);
  static const infoBg = Color(0xFFFFE7ED);
  static const infoInk = Color(0xFFA01342);
  static const critBg = Color(0xFFFDECED);
  static const critInk = Color(0xFFA3121F);

  static const page = Color(0xFFE8DCD6);
}
