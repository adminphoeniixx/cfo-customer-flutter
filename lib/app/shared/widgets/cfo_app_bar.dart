import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_routes.dart';
import 'app_icons.dart';

/// One small icon button used on the right side of [CfoAppBar], with an
/// optional numeric badge — mirrors the prototype's `.iconbtn` + badge dot.
class CfoAppBarAction {
  const CfoAppBarAction({
    required this.icon,
    required this.onTap,
    this.badge = 0,
    this.badgeCount,
    this.tooltip,
  });

  final String icon;
  final VoidCallback onTap;

  /// Static badge count, for a value known up front.
  final int badge;

  /// Reactive badge count — e.g. `() => Get.find<WishlistService>().ids.length`.
  /// Read inside an [Obx] so it updates live without the whole app bar
  /// needing to rebuild. Takes precedence over [badge] when non-null.
  final int Function()? badgeCount;

  final String? tooltip;
}

/// The single reusable header used everywhere in the app, matching the
/// prototype's `.appbar` component exactly: a ~52px blush/chrome bar, no
/// shadow, with either a plain title (+ optional subtitle), a right-aligned
/// row of icon buttons with badge dots, an embedded rounded search-field
/// pill (browsing tabs), or a back-chevron + trailing "Save" text button
/// (edit forms).
class CfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Plain title(+subtitle) with a back button and optional trailing icons.
  const CfoAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions = const [],
    this.onBack,
    this.bottom,
  }) : searchPlaceholder = null,
       onSearchTap = null,
       saveLabel = null,
       onSave = null,
       saving = false;

  /// Title replaced by a tappable search-field pill (Home/Categories/Results).
  const CfoAppBar.search({
    super.key,
    required this.searchPlaceholder,
    required this.onSearchTap,
    this.showBack = false,
    this.actions = const [],
    this.onBack,
    this.bottom,
  }) : title = '',
       subtitle = null,
       saveLabel = null,
       onSave = null,
       saving = false;

  /// Back chevron + title, with a trailing "Save" text action (edit forms).
  const CfoAppBar.editForm({
    super.key,
    required this.title,
    this.saveLabel = 'Save',
    required this.onSave,
    this.saving = false,
    this.onBack,
    this.bottom,
  }) : subtitle = null,
       showBack = true,
       actions = const [],
       searchPlaceholder = null,
       onSearchTap = null;

  final String title;
  final String? subtitle;
  final bool showBack;
  final List<CfoAppBarAction> actions;
  final VoidCallback? onBack;

  final String? searchPlaceholder;
  final VoidCallback? onSearchTap;

  final String? saveLabel;
  final VoidCallback? onSave;
  final bool saving;

  /// Optional TabBar (or similar) rendered under the header row.
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(52 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Material(
      color: AppColors.chrome,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
                child: Row(
                  children: [
                    if (showBack)
                      _BackButton(
                        onTap: onBack ?? () => _routeAwareBack(canPop),
                      ),
                    if (searchPlaceholder != null)
                      Expanded(
                        child: _SearchPill(
                          placeholder: searchPlaceholder!,
                          onTap: onSearchTap,
                        ),
                      )
                    else
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: SizedBox(
                            height: 36,
                            child: subtitle == null
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 16.5,
                                        height: 1,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.chromeInk,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.body.copyWith(
                                              fontSize: 16,
                                              height: 1,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.chromeInk,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            subtitle!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.tiny.copyWith(
                                              color: AppColors.ink3,
                                              fontSize: 11,
                                              height: 1.05,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    if (onSave != null)
                      TextButton(
                        onPressed: saving ? null : onSave,
                        child: saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.brand,
                                ),
                              )
                            : Text(
                                saveLabel ?? 'Save',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.brand,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      )
                    else
                      for (final a in actions) _IconBtn(action: a),
                  ],
                ),
              ),
            ),
            ?bottom,
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            '‹',
            style: TextStyle(
              fontSize: 26,
              color: AppColors.chromeInk,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.action});
  final CfoAppBarAction action;

  Widget _dot(int count) {
    if (count <= 0) return const SizedBox.shrink();
    return Positioned(
      right: -2,
      top: -3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        constraints: const BoxConstraints(minWidth: 15),
        decoration: const BoxDecoration(
          color: AppColors.brand,
          shape: BoxShape.circle,
        ),
        child: Text(
          count > 9 ? '9+' : '$count',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.onBrand,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: action.tooltip ?? '',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: action.onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: AppIcon(
                  action.icon,
                  size: 20,
                  color: AppColors.chromeInk,
                ),
              ),
              if (action.badgeCount != null)
                Obx(() => _dot(action.badgeCount!()))
              else
                _dot(action.badge),
            ],
          ),
        ),
      ),
    );
  }
}

void _routeAwareBack(bool canPop) {
  if (canPop) {
    Get.back();
    return;
  }

  final route = Get.currentRoute;
  switch (route) {
    case AppRoutes.checkoutPayment:
      Get.offNamed(AppRoutes.checkoutDelivery);
      return;
    case AppRoutes.checkoutDelivery:
      Get.offNamed(AppRoutes.checkoutAddress);
      return;
    case AppRoutes.checkoutAddress:
      Get.offNamed(AppRoutes.cart);
      return;
    case AppRoutes.productDetail:
    case AppRoutes.results:
    case AppRoutes.seller:
    case AppRoutes.reviews:
      Get.offAllNamed(AppRoutes.nav);
      return;
    case AppRoutes.orders:
    case AppRoutes.orderDetail:
    case AppRoutes.orderTrack:
      Get.offAllNamed(AppRoutes.nav, arguments: {'tab': 2});
      return;
    case AppRoutes.requests:
    case AppRoutes.requestDetail:
    case AppRoutes.cancelForm:
    case AppRoutes.returnForm:
      Get.offAllNamed(AppRoutes.nav, arguments: {'tab': 2});
      return;
    case AppRoutes.profile:
    case AppRoutes.addresses:
    case AppRoutes.addressForm:
    case AppRoutes.paymentsInfo:
    case AppRoutes.coupons:
    case AppRoutes.notificationSettings:
    case AppRoutes.devices:
    case AppRoutes.changePassword:
    case AppRoutes.help:
    case AppRoutes.about:
    case AppRoutes.wishlist:
    case AppRoutes.myReviews:
      Get.offAllNamed(AppRoutes.nav, arguments: {'tab': 4});
      return;
    case AppRoutes.emailLogin:
    case AppRoutes.forgotPassword:
    case AppRoutes.otp:
      Get.offNamed(AppRoutes.login);
      return;
    default:
      Get.offAllNamed(AppRoutes.nav);
  }
}

class _SearchPill extends StatelessWidget {
  const _SearchPill({required this.placeholder, this.onTap});
  final String placeholder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap ?? () => Get.toNamed(AppRoutes.search),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.ink.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            AppIcon(AppSvgIcons.search, size: 17, color: AppColors.ink3),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                placeholder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.ink3,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
