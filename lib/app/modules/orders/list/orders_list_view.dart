import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/auth/notifications_badge_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../../../data/models/request_item.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_icons.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/order_status_pill.dart';
import '../../../shared/widgets/prototype_image.dart';
import 'orders_list_controller.dart';

class OrdersListView extends GetView<OrdersListController> {
  const OrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OrdersListController>()) {
      Get.put(OrdersListController());
    }
    final auth = Get.find<AuthService>();
    const filters = [
      ('all', 'All'),
      ('open', 'On the way'),
      ('completed', 'Delivered'),
      ('cancelled', 'Cancelled & returned'),
    ];
    final openedAsRoute = Get.currentRoute == AppRoutes.orders;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Obx(
          () => CfoAppBar(
            title: 'My orders',
            subtitle:
                '${controller.orders.length} order${controller.orders.length == 1 ? '' : 's'}',
            showBack: openedAsRoute,
            actions: [
              CfoAppBarAction(
                icon: AppSvgIcons.bell,
                tooltip: 'Notifications',
                badgeCount: () =>
                    Get.find<NotificationsBadgeService>().unreadCount.value,
                onTap: () => Get.toNamed(AppRoutes.notifications),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (!auth.isLoggedIn.value) {
          return EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Sign in to see your orders',
            actionLabel: 'Sign in',
            onAction: () => Get.toNamed(AppRoutes.login),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 4),
                children: [
                  for (final f in filters)
                    Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: ChoiceChip(
                        label: Text(f.$2),
                        selected: controller.filter.value == f.$1,
                        onSelected: (_) => controller.setFilter(f.$1),
                        labelStyle: AppTextStyles.tiny.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: controller.filter.value == f.$1
                              ? AppColors.brand
                              : AppColors.ink3,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        labelPadding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                          color: controller.filter.value == f.$1
                              ? AppColors.brand
                              : AppColors.line,
                        ),
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.brandSoft,
                        showCheckmark: false,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: controller.loading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.orders.isEmpty && controller.requests.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders yet',
                      message: 'Orders you place will show up here.',
                    )
                  : RefreshIndicator(
                      onRefresh: controller.load,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          8,
                          10,
                          AppSpace.lg,
                        ),
                        children: [
                          if (controller.requests.isNotEmpty) ...[
                            Text(
                              'Cancellations & returns',
                              style: AppTextStyles.title,
                            ),
                            const SizedBox(height: AppSpace.xs),
                            _RequestsCard(requests: controller.requests),
                            const SizedBox(height: AppSpace.md),
                          ],
                          Text('Orders', style: AppTextStyles.title),
                          const SizedBox(height: AppSpace.xs),
                          for (final order in controller.orders)
                            _OrderCard(
                              order: order,
                              reordering:
                                  controller.reorderingNumber.value ==
                                  order.number,
                              onBuyAgain: () =>
                                  controller.buyAgain(order.number),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _RequestsCard extends StatelessWidget {
  final List<RequestItem> requests;
  const _RequestsCard({required this.requests});

  @override
  Widget build(BuildContext context) {
    return _Card(
      flat: true,
      child: Column(
        children: [
          for (final r in requests.take(3))
            InkWell(
              onTap: () => Get.toNamed(
                AppRoutes.requestDetail,
                arguments: {'number': r.number},
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    PrototypeImage(
                      source: r.isCancellation ? '×' : '↩',
                      size: 44,
                      fontSize: 24,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  r.number,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 13.5,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OrderStatusPill(
                                status: r.status,
                                label: _titleCase(r.status),
                              ),
                            ],
                          ),
                          Text(
                            '${r.items.isEmpty ? 'Request' : r.items.first.name ?? 'Item'} · order ${r.orderNumber ?? '#${r.orderId}'}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.ink3),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool reordering;
  final VoidCallback onBuyAgain;

  const _OrderCard({
    required this.order,
    required this.reordering,
    required this.onBuyAgain,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      flat: true,
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Column(
        children: [
          InkWell(
            onTap: () => Get.toNamed(
              AppRoutes.orderDetail,
              arguments: {'number': order.number},
            ),
            child: Container(
              color: AppColors.surface2,
              padding: const EdgeInsets.all(AppSpace.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Order ${order.number}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13.5,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OrderStatusPill(
                              status: order.status,
                              label: order.statusLabel,
                            ),
                          ],
                        ),
                        Text(
                          '${formatDate(order.placedAt)} · ${formatInr(order.totals.grandTotal)} · ${order.paymentMethod}',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.ink3),
                ],
              ),
            ),
          ),
          for (final item in order.items.take(3))
            InkWell(
              onTap: () => Get.toNamed(
                AppRoutes.orderDetail,
                arguments: {'number': order.number},
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.sm),
                child: Row(
                  children: [
                    PrototypeImage(
                      source: item.image,
                      width: 68,
                      height: 78,
                      fontSize: 30,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.5,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Qty ${item.quantity} · ${_optionText(item)}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _orderEta(order),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.ink2,
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.ink3),
                  ],
                ),
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.lineSoft)),
            ),
            child: Row(
              children: [
                if (order.status == 'shipped' ||
                    order.trackingNumber != null) ...[
                  _GhostButton(
                    label: 'Track',
                    onPressed: () => Get.toNamed(
                      AppRoutes.orderTrack,
                      arguments: {'number': order.number},
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (order.canCancel) ...[
                  _GhostButton(
                    label: 'Cancel',
                    onPressed: () => Get.toNamed(
                      AppRoutes.cancelForm,
                      arguments: {'order': order},
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                _GhostButton(
                  label: reordering ? 'Adding...' : 'Buy again',
                  onPressed: reordering ? null : onBuyAgain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _optionText(OrderItem item) {
    if (item.options == null || item.options!.isEmpty) {
      return _sellerName(order, item.vendorId);
    }
    return item.options!.values.map((e) => e.toString()).join(' · ');
  }

  String _sellerName(Order order, int vendorId) {
    for (final seller in order.sellers) {
      if (seller.id == vendorId) return seller.name;
    }
    return 'Seller';
  }

  String _orderEta(Order order) {
    if (order.deliveredAt != null) {
      return 'Delivered ${formatDate(order.deliveredAt)}';
    }
    if (order.cancelledAt != null) {
      return 'Cancelled ${formatDate(order.cancelledAt)}';
    }
    return order.statusLabel;
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GhostButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.action,
          disabledForegroundColor: AppColors.ink3,
          textStyle: AppTextStyles.body.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.02,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(0, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool flat;
  final EdgeInsetsGeometry? margin;

  const _Card({required this.child, this.flat = false, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: flat ? Clip.antiAlias : Clip.none,
      child: child,
    );
  }
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
