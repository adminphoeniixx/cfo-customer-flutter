import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/account_badge_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_icons.dart';
import '../account/account_view.dart';
import '../cart/cart_controller.dart';
import '../cart/cart_view.dart';
import '../categories/categories_view.dart';
import '../home/home_view.dart';
import '../orders/list/orders_list_view.dart';
import 'nav_controller.dart';

class NavView extends GetView<NavController> {
  const NavView({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = const [
      HomeView(),
      CategoriesView(),
      OrdersListView(),
      CartView(),
      AccountView(),
    ];
    final cart = Get.find<CartController>();
    final accountBadge = Get.isRegistered<AccountBadgeService>()
        ? Get.find<AccountBadgeService>()
        : null;
    return Obx(() {
      final cartCount = cart.cart.value?.totals.itemsCount ?? 0;
      final accountCount = accountBadge?.pendingReviewsCount.value ?? 0;
      // System back on another tab returns to Home; on Home it leaves the app.
      return PopScope(
        canPop: controller.tabIndex.value == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.changeTab(0);
        },
        child: Scaffold(
          body: IndexedStack(
            index: controller.tabIndex.value,
            children: pages,
          ),
          bottomNavigationBar: _TabBar(
            currentIndex: controller.tabIndex.value,
            cartCount: cartCount,
            accountCount: accountCount,
            onTap: controller.changeTab,
          ),
        ),
      );
    });
  }
}

class _TabBar extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final int accountCount;
  final ValueChanged<int> onTap;

  const _TabBar({
    required this.currentIndex,
    required this.cartCount,
    required this.accountCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final tabs = [
      (AppIcons.navHome, AppIcons.navHomeActive, 'Home', 0),
      (AppIcons.navCategories, AppIcons.navCategoriesActive, 'Categories', 0),
      (AppIcons.navOrders, AppIcons.navOrdersActive, 'Orders', 0),
      (AppIcons.navCart, AppIcons.navCartActive, 'Cart', cartCount),
      (AppIcons.navAccount, AppIcons.navAccountActive, 'Account', accountCount),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(4, 10, 4, 8 + bottom),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: _TabButton(
                icon: tabs[i].$1,
                activeIcon: tabs[i].$2,
                label: tabs[i].$3,
                badge: tabs[i].$4,
                selected: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brand : AppColors.ink3;
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppIcon(selected ? activeIcon : icon, size: 24, color: color),
              if (badge > 0)
                Positioned(
                  top: -5,
                  right: -8,
                  child: Container(
                    height: 17,
                    constraints: const BoxConstraints(minWidth: 17),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: AppTextStyles.tag.copyWith(
                          color: AppColors.onBrand,
                          fontSize: 9,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppTextStyles.tiny.copyWith(
              fontSize: 11.5,
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
