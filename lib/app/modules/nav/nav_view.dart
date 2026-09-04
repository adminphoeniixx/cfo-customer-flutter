import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/account_badge_service.dart';
import '../../core/theme/app_colors.dart';
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
      return Scaffold(
        body: IndexedStack(index: controller.tabIndex.value, children: pages),
        bottomNavigationBar: _TabBar(
          currentIndex: controller.tabIndex.value,
          cartCount: cartCount,
          accountCount: accountCount,
          onTap: controller.changeTab,
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
      (AppSvgIcons.navHome, 'Home', 0),
      (AppSvgIcons.navCategories, 'Categories', 0),
      (AppSvgIcons.navOrders, 'Orders', 0),
      (AppSvgIcons.navCart, 'Cart', cartCount),
      (AppSvgIcons.navAccount, 'Account', accountCount),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(2, 6, 2, 9 + bottom),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: _TabButton(
                icon: tabs[i].$1,
                label: tabs[i].$2,
                badge: tabs[i].$3,
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
  final String icon;
  final String label;
  final int badge;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.brandSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: AppIcon(
                  icon,
                  size: 21,
                  color: selected ? AppColors.action : AppColors.ink3,
                ),
              ),
              if (badge > 0)
                Positioned(
                  top: -5,
                  right: -5,
                  child: Container(
                    height: 17,
                    constraints: const BoxConstraints(minWidth: 17),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          color: AppColors.onBrand,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.tiny.copyWith(
              fontSize: 9.5,
              color: selected ? AppColors.action : AppColors.ink3,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
