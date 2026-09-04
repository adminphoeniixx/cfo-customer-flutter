import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/prototype_image.dart';
import '../checkout_controller.dart';

class CheckoutSuccessView extends StatelessWidget {
  const CheckoutSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final order = args is Map ? args['order'] as Order? : null;
    final firstName = order?.shippingAddress?.firstName.isNotEmpty == true
        ? order!.shippingAddress!.firstName
        : null;
    if (Get.isRegistered<CheckoutController>()) {
      Get.delete<CheckoutController>();
    }
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const CfoAppBar(title: 'Order placed', showBack: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 154),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.dealSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.deal,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        firstName == null ? 'Thank you!' : 'Thank you, $firstName',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 19,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 9),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          order == null
                              ? 'Your order has been placed.'
                              : 'Order ${order.number} is with ${order.sellers.length == 1 ? 'the seller' : 'both sellers'}.'
                                    '${order.eta != null ? ' ${order.eta}.' : ''}',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.ink2,
                            fontSize: 13,
                            height: 1.55,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 9),
                      if (order != null) _PaymentPill(order: order),
                      const SizedBox(height: 14),
                      if (order != null) _ItemsCard(order: order),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                label: 'Track this order',
                onPressed: order == null
                    ? null
                    : () => Get.offAllNamed(
                        AppRoutes.orderDetail,
                        arguments: {'number': order.number},
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.nav),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'Keep shopping',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.action,
                    fontSize: 14,
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

class _PaymentPill extends StatelessWidget {
  final Order order;
  const _PaymentPill({required this.order});

  @override
  Widget build(BuildContext context) {
    final paid = order.paymentStatus == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: paid ? AppColors.okBg : AppColors.warnBg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        paid ? 'Paid · ${order.paymentMethod}' : 'Pay on delivery',
        style: AppTextStyles.tiny.copyWith(
          color: paid ? AppColors.okInk : AppColors.warnInk,
          fontSize: 9.5,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final Order order;
  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final sellers = {
      for (final seller in order.sellers) seller.id: seller.name,
    };
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  PrototypeImage(
                    source: item.image,
                    width: 44,
                    height: 44,
                    fontSize: 20,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.ink,
                            fontSize: 13.5,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Qty ${item.quantity} · ${sellers[item.vendorId] ?? 'Seller'}',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 11),
                  Text(
                    formatInr(item.total),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
