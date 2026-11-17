import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// The app's icon set: Iconsax outline icons, with bold (filled) variants
/// for the selected bottom-nav tab. Use these instead of Material [Icons]
/// so every screen shares the same rounded line style.
class AppIcons {
  AppIcons._();

  static const search = IconsaxPlusLinear.search_normal_1;
  static const filter = IconsaxPlusLinear.setting_4;
  static const heart = IconsaxPlusLinear.heart;
  static const heartFilled = IconsaxPlusBold.heart;
  static const bag = IconsaxPlusLinear.bag_2;
  static const bell = IconsaxPlusLinear.notification;
  static const support = IconsaxPlusLinear.headphone;
  static const bookmark = IconsaxPlusLinear.archive_minus;

  static const back = IconsaxPlusLinear.arrow_left;
  static const chevronRight = IconsaxPlusLinear.arrow_right_3;
  static const close = IconsaxPlusLinear.close_circle;
  static const add = IconsaxPlusLinear.add;
  static const minus = IconsaxPlusLinear.minus;
  static const check = IconsaxPlusLinear.tick_circle;
  // Iconsax's stars carry motion lines; the design uses a plain star.
  static const star = Icons.star_rounded;
  static const starOutline = Icons.star_outline_rounded;
  static const location = IconsaxPlusLinear.location;
  static const radioOn = IconsaxPlusBold.record_circle;
  static const radioOff = IconsaxPlusLinear.record;

  static const navHome = IconsaxPlusLinear.home_2;
  static const navHomeActive = IconsaxPlusBold.home_2;
  static const navCategories = IconsaxPlusLinear.category;
  static const navCategoriesActive = IconsaxPlusBold.category;
  static const navOrders = IconsaxPlusLinear.receipt_2;
  static const navOrdersActive = IconsaxPlusBold.receipt_2;
  static const navCart = IconsaxPlusLinear.bag_2;
  static const navCartActive = IconsaxPlusBold.bag_2;
  static const navAccount = IconsaxPlusLinear.profile_circle;
  static const navAccountActive = IconsaxPlusBold.profile_circle;

  static const _glyphs = <String, IconData>{
    '📍': IconsaxPlusLinear.location,
    '🏬': IconsaxPlusLinear.shop,
    '💳': IconsaxPlusLinear.card,
    '💬': IconsaxPlusLinear.message,
    '🏷️': IconsaxPlusLinear.ticket_discount,
    '🏷': IconsaxPlusLinear.ticket_discount,
    '📦': IconsaxPlusLinear.box,
    '📞': IconsaxPlusLinear.call,
    '⚡': IconsaxPlusLinear.flash_1,
    '↩': IconsaxPlusLinear.undo,
    '🧾': IconsaxPlusLinear.receipt_item,
    '🧶': IconsaxPlusLinear.gallery,
    '🔗': IconsaxPlusLinear.link,
    '🔔': IconsaxPlusLinear.notification,
    '🔒': IconsaxPlusLinear.lock,
    '📱': IconsaxPlusLinear.mobile,
    '💵': IconsaxPlusLinear.money,
    '🏦': IconsaxPlusLinear.bank,
    '♥': IconsaxPlusLinear.heart,
    '×': IconsaxPlusLinear.close_circle,
  };

  /// Maps the legacy emoji placeholders (still sent by some API fields and
  /// older screens) to the matching line icon, or null if unknown.
  static IconData? glyph(String s) => _glyphs[s.trim()];
}

/// Renders one of [AppIcons], tinted via [color].
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 20, this.color});

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Icon(icon, size: size, color: color);
}
