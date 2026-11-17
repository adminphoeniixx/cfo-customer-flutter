import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
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

  final IconData icon;
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
/// design's header: a 64px off-white bar, no shadow, with either a plain title (+ optional subtitle), a right-aligned
/// row of icon buttons with badge dots, an embedded rounded search-field
/// pill (browsing tabs), or a back-chevron + trailing "Save" text button
/// (edit forms).
class CfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Plain title(+subtitle) with a back button and optional trailing icons.
  const CfoAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack,
    this.actions = const [],
    this.onBack,
    this.bottom,
  }) : searchPlaceholder = null,
       onSearchTap = null,
       onFilterTap = null,
       saveLabel = null,
       onSave = null,
       saving = false;

  /// Title replaced by a tappable search-field pill (Home/Categories/Results).
  const CfoAppBar.search({
    super.key,
    required this.searchPlaceholder,
    required this.onSearchTap,
    this.onFilterTap,
    this.showBack,
    this.actions = const [],
    this.onBack,
    this.bottom,
  }) : title = '',
       subtitle = null,
       saveLabel = null,
       onSave = null,
       saving = false;

  /// Back arrow + title, with a trailing "Save" text action (edit forms).
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
       onSearchTap = null,
       onFilterTap = null;

  final String title;
  final String? subtitle;
  /// Null (the default) shows the back button whenever there is a screen
  /// to go back to, so pushed routes always get one and bottom-nav tabs
  /// don't. Pass true/false only to override that.
  final bool? showBack;
  final List<CfoAppBarAction> actions;
  final VoidCallback? onBack;

  final String? searchPlaceholder;
  final VoidCallback? onSearchTap;

  /// Shows the square olive filter button beside the search field.
  final VoidCallback? onFilterTap;

  final String? saveLabel;
  final VoidCallback? onSave;
  final bool saving;

  /// Optional TabBar (or similar) rendered under the header row.
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(barHeight + (bottom?.preferredSize.height ?? 0));

  /// Header row height, excluding the status bar and [bottom].
  static const barHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showBack = this.showBack ?? canPop;
    return Material(
      color: AppColors.chrome,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: barHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    if (showBack)
                      _BackButton(
                        onTap: onBack ?? () => _routeAwareBack(canPop),
                      ),
                    if (showBack) const SizedBox(width: 10),
                    if (searchPlaceholder != null) ...[
                      Expanded(
                        child: _SearchPill(
                          placeholder: searchPlaceholder!,
                          onTap: onSearchTap,
                        ),
                      ),
                      if (onFilterTap != null) ...[
                        const SizedBox(width: 10),
                        FilterSquareButton(onTap: onFilterTap!),
                      ],
                      if (actions.isNotEmpty) const SizedBox(width: 2),
                    ] else
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.zero,
                          child: SizedBox(
                            height: 38,
                            child: subtitle == null
                                ? Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.h3.copyWith(
                                        height: 1,
                                        color: AppColors.chromeInk,
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
                                            style: AppTextStyles.h3.copyWith(
                                              fontSize: 16,
                                              height: 1,
                                              color: AppColors.chromeInk,
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
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.brand,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      )
                    else
                      for (var i = 0; i < actions.length; i++) ...[
                        if (i > 0 || searchPlaceholder == null)
                          const SizedBox(width: 8),
                        _IconBtn(action: actions[i]),
                      ],
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
    return CircleIconButton(icon: AppIcons.back, onTap: onTap, tooltip: 'Back');
  }
}

/// White circular icon button — the round header buttons of the design
/// (support / notifications / back).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 44,
    this.iconSize = 20,
    this.background = AppColors.surface,
    this.foreground = AppColors.chromeInk,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: AppIcon(icon, size: iconSize, color: foreground),
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// The square olive "filter" button that sits beside search fields.
class FilterSquareButton extends StatelessWidget {
  const FilterSquareButton({super.key, required this.onTap, this.size = 48});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand,
      borderRadius: BorderRadius.circular(AppRadius.button),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: const Center(
            child: AppIcon(AppIcons.filter, size: 20, color: AppColors.onBrand),
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
      right: 0,
      top: 0,
      child: Container(
        height: 17,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        constraints: const BoxConstraints(minWidth: 17),
        decoration: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: AppColors.surface, width: 1.5),
        ),
        child: Center(
          child: Text(
            count > 9 ? '9+' : '$count',
            textAlign: TextAlign.center,
            style: AppTextStyles.tag.copyWith(
              color: AppColors.onBrand,
              fontSize: 9,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleIconButton(
          icon: action.icon,
          onTap: action.onTap,
          tooltip: action.tooltip,
        ),
        if (action.badgeCount != null)
          Obx(() => _dot(action.badgeCount!()))
        else
          _dot(action.badge),
      ],
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
    return SearchFieldButton(
      placeholder: placeholder,
      onTap: onTap ?? () => Get.toNamed(AppRoutes.search),
    );
  }
}

/// White rounded, borderless search field look-alike that opens search.
class SearchFieldButton extends StatelessWidget {
  const SearchFieldButton({
    super.key,
    required this.placeholder,
    required this.onTap,
    this.height = 48,
  });

  final String placeholder;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.input),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const AppIcon(AppIcons.search, size: 20, color: AppColors.ink2),
              const SizedBox(width: 10),
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
      ),
    );
  }
}
