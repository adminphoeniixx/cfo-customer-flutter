import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/wishlist_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/address.dart';
import '../../data/models/cart.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/bottom_buy_bar.dart';
import '../../shared/widgets/cart_line_tile.dart';
import '../../shared/widgets/cfo_app_bar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/prototype_image.dart';
import 'cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CartController>()) Get.put(CartController());
    final auth = Get.find<AuthService>();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Obx(() {
          final cart = controller.cart.value;
          final count = cart?.totals.itemsCount ?? 0;
          return CfoAppBar(
            title: 'Cart',
            subtitle: count > 0 ? '$count item${count == 1 ? '' : 's'}' : null,
            showBack: false,
            actions: [
              CfoAppBarAction(
                icon: AppSvgIcons.heart,
                tooltip: 'Wishlist',
                badgeCount: () => Get.find<WishlistService>().ids.length,
                onTap: () => Get.toNamed(AppRoutes.wishlist),
              ),
            ],
          );
        }),
      ),
      body: Obx(() {
        if (!auth.isLoggedIn.value) {
          return EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Sign in to see your cart',
            message: 'Your bag is saved to your account.',
            actionLabel: 'Sign in',
            onAction: () => Get.toNamed(AppRoutes.login),
          );
        }
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final cart = controller.cart.value;
        if (cart == null || cart.lineCount == 0) {
          return EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Your cart is empty',
            message: 'Add something you like to get started.',
            actionLabel: 'Start shopping',
            onAction: () => Get.offAllNamed(AppRoutes.nav),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.md,
              AppSpace.md,
              AppSpace.md,
              88,
            ),
            children: [
              _DeliverToCard(address: controller.deliveryAddress.value),
              const SizedBox(height: AppSpace.sm),
              for (final group in cart.groups)
                _VendorGroup(group: group, controller: controller),
              const SizedBox(height: AppSpace.sm),
              _CouponBox(cart: cart, controller: controller),
              const SizedBox(height: AppSpace.md),
              _TotalsCard(cart: cart),
              if (cart.savedForLater.isNotEmpty) ...[
                const SizedBox(height: AppSpace.lg),
                Text('Saved for later', style: AppTextStyles.h3),
                const Divider(),
                for (final item in cart.savedForLater)
                  CartLineTile(
                    item: item,
                    isSaved: true,
                    onMoveToCart: () => controller.moveToCart(item.id),
                    onRemove: () => controller.removeItem(item.id),
                  ),
              ],
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final cart = controller.cart.value;
        if (!auth.isLoggedIn.value || cart == null || cart.lineCount == 0) {
          return const SizedBox.shrink();
        }
        return BottomBuyBar(
          leading: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(formatInr(cart.totals.grandTotal), style: AppTextStyles.h3),
              Text(
                '${cart.totals.itemsCount} items · view details',
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actionLabel: 'Place order'.toUpperCase(),
          onAction: controller.goToCheckout,
        );
      }),
    );
  }
}

class _DeliverToCard extends StatelessWidget {
  final Address? address;
  const _DeliverToCard({required this.address});

  @override
  Widget build(BuildContext context) {
    final cityLine = address == null
        ? 'Select delivery address'
        : 'Deliver to ${address!.postcode}, ${address!.city}';
    final meta = address == null
        ? 'Add your address before checkout'
        : [
            if ((address!.label ?? '').isNotEmpty) address!.label,
            if (address!.firstName.isNotEmpty) address!.firstName,
          ].whereType<String>().join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.brandSoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          PrototypeImage(
            source: '📍',
            width: 36,
            height: 36,
            fontSize: 18,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cityLine,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta.isNotEmpty)
                  Text(
                    meta,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.checkoutAddress),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _VendorGroup extends StatelessWidget {
  final CartGroup group;
  final CartController controller;
  const _VendorGroup({required this.group, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.surface2,
            child: Row(
              children: [
                const Text('🏬', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.vendorName,
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.ink,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${group.items.length} item${group.items.length == 1 ? '' : 's'}',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.ink3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          for (final item in group.items)
            CartLineTile(
              item: item,
              onQuantityChanged: (q) => controller.updateQuantity(item.id, q),
              onRemove: () => controller.removeItem(item.id),
              onSaveForLater: () => controller.saveForLater(item.id),
            ),
        ],
      ),
    );
  }
}

class _CouponBox extends StatelessWidget {
  final CartResponse cart;
  final CartController controller;
  const _CouponBox({required this.cart, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCoupons(context, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            PrototypeImage(
              source: '🏷️',
              width: 44,
              height: 44,
              fontSize: 20,
              borderRadius: BorderRadius.circular(9),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cart.coupon == null
                        ? 'Apply a coupon'
                        : '${cart.coupon!.code} applied',
                    style: AppTextStyles.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    cart.coupon == null
                        ? '3 offers available'
                        : '-${formatInr(cart.coupon!.discount)} on this order',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Text(
              '›',
              style: TextStyle(fontSize: 24, color: AppColors.ink3, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  void _showCoupons(BuildContext context, CartController controller) {
    Get.bottomSheet(
      FutureBuilder<List<AvailableCoupon>>(
        future: controller.availableCoupons(),
        builder: (context, snap) {
          return Container(
            constraints: BoxConstraints(maxHeight: Get.height * 0.6),
            padding: const EdgeInsets.all(AppSpace.md),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheet),
              ),
            ),
            child: !snap.hasData
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    shrinkWrap: true,
                    children: [
                      Text('Available coupons', style: AppTextStyles.h3),
                      const SizedBox(height: AppSpace.sm),
                      for (final c in snap.data!)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.local_offer_outlined,
                            color: c.usable ? AppColors.deal : AppColors.ink3,
                          ),
                          title: Text(
                            c.code,
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            c.usable
                                ? (c.description ?? '')
                                : (c.reason ?? c.description ?? ''),
                          ),
                          trailing: c.usable
                              ? TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.applyCoupon(c.code);
                                  },
                                  child: const Text('Apply'),
                                )
                              : null,
                        ),
                    ],
                  ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final CartResponse cart;
  const _TotalsCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    final t = cart.totals;
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _row('MRP total', formatInr(t.mrpTotal)),
          _row(
            'Discount on MRP',
            '-${formatInr(t.savedOnMrp)}',
            color: AppColors.deal,
          ),
          if (t.discountTotal > 0)
            _row(
              'Coupon discount',
              '-${formatInr(t.discountTotal)}',
              color: AppColors.deal,
            ),
          _row(
            'Shipping',
            t.shippingTotal == 0 ? 'FREE' : formatInr(t.shippingTotal),
            color: t.shippingTotal == 0 ? AppColors.deal : null,
          ),
          _row('Tax', formatInr(t.taxTotal)),
          const Divider(),
          _row('Grand total', formatInr(t.grandTotal), bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? color, bool bold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: bold ? AppTextStyles.title : AppTextStyles.body),
            Text(
              value,
              style: (bold ? AppTextStyles.title : AppTextStyles.bodyMedium)
                  .copyWith(color: color),
            ),
          ],
        ),
      );
}
