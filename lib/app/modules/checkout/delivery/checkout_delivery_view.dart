import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/cart.dart';
import '../../../data/models/checkout.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/bottom_buy_bar.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/prototype_image.dart';
import '../../cart/cart_controller.dart';
import '../checkout_controller.dart';
import '../checkout_step_indicator.dart';

class CheckoutDeliveryView extends StatelessWidget {
  const CheckoutDeliveryView({super.key});

  String _vendorName(int vendorId) {
    if (!Get.isRegistered<CartController>()) return 'Seller';
    final groups = Get.find<CartController>().cart.value?.groups ?? [];
    for (final g in groups) {
      if (g.vendorId == vendorId) return g.vendorName;
    }
    return 'Seller';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckoutController>();
    return Scaffold(
      appBar: CfoAppBar(title: 'Delivery & summary', subtitle: 'Step 2 of 3'),
      body: Obx(() {
        final s = controller.summary.value;
        if (s == null) return const Center(child: CircularProgressIndicator());
        final byVendor = <int, List<CheckoutItem>>{};
        for (final item in s.items) {
          byVendor.putIfAbsent(item.vendorId, () => []).add(item);
        }
        return Column(
          children: [
            const CheckoutStepIndicator(step: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 82),
                children: [
                  const _SectionTitle('How it should reach you'),
                  const SizedBox(height: 8),
                  _Card(
                    flat: true,
                    child: Column(
                      children: [
                        for (final opt in s.shippingOptions)
                          _ShippingOption(
                            option: opt,
                            selected:
                                controller.selectedShippingCode.value ==
                                opt.code,
                            onTap: () => controller.selectedShippingCode.value =
                                opt.code,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionTitle('Your items'),
                  const SizedBox(height: 8),
                  for (final entry in byVendor.entries)
                    _VendorItemsCard(
                      vendorName: _vendorName(entry.key),
                      items: entry.value,
                    ),
                  const SizedBox(height: 16),
                  const _SectionTitle('Price details'),
                  const SizedBox(height: 8),
                  _TotalsCard(summary: s),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: BottomBuyBar(
        actionLabel: 'Continue to payment',
        onAction: () => Get.toNamed(AppRoutes.checkoutPayment),
      ),
    );
  }
}

class _ShippingOption extends StatelessWidget {
  final ShippingOption option;
  final bool selected;
  final VoidCallback onTap;

  const _ShippingOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.action : AppColors.line,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${option.name} · ',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 13.5,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        TextSpan(
                          text: option.rate == 0
                              ? 'FREE'
                              : formatInr(option.rate),
                          style: AppTextStyles.label.copyWith(
                            fontSize: 13.5,
                            height: 1.25,
                            color: option.rate == 0
                                ? AppColors.deal
                                : AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _shippingDetail(option),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      height: 1.35,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shippingDetail(ShippingOption option) {
    final detail = option.etaLabel.isEmpty
        ? 'Delivery date pending'
        : (option.etaLabel.toLowerCase().startsWith('arriv')
              ? option.etaLabel
              : 'Arrives ${option.etaLabel}');
    final note = option.note ?? option.freeBecause;
    return note == null || note.isEmpty ? detail : '$detail · $note';
  }
}

class _VendorItemsCard extends StatelessWidget {
  final String vendorName;
  final List<CheckoutItem> items;

  const _VendorItemsCard({required this.vendorName, required this.items});

  @override
  Widget build(BuildContext context) {
    return _Card(
      flat: true,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.surface2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Text('🏬', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vendorName,
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                Text(
                  'Ships separately',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.ink3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          for (final item in items) _ItemRow(item: item),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CheckoutItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PrototypeImage(
            source: item.image,
            width: 44,
            height: 44,
            fontSize: 22,
            borderRadius: BorderRadius.circular(7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.ink,
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty ${item.quantity}${item.sku == null ? '' : ' · ${item.sku}'}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatInr(item.total),
            style: AppTextStyles.label.copyWith(
              color: AppColors.ink,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final CheckoutSummary summary;
  const _TotalsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final t = summary.totals;
    return _Card(
      padded: true,
      child: Column(
        children: [
          _row('Items', formatInr(t.subtotal)),
          if (summary.coupon != null)
            _row(
              'Coupon ${summary.coupon!.code}',
              '-${formatInr(summary.coupon!.discount)}',
              color: AppColors.deal,
            ),
          _row(
            'Delivery',
            t.shippingTotal == 0 ? 'FREE' : formatInr(t.shippingTotal),
            color: t.shippingTotal == 0 ? AppColors.deal : null,
          ),
          _row('GST', formatInr(t.taxTotal)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(),
          ),
          _row('Total payable', formatInr(t.grandTotal), bold: true),
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
            Text(
              label,
              style: (bold ? AppTextStyles.title : AppTextStyles.body).copyWith(
                fontSize: bold ? 15 : 13,
                height: 1.2,
              ),
            ),
            Text(
              value,
              style: (bold ? AppTextStyles.title : AppTextStyles.bodyMedium)
                  .copyWith(
                    color: color,
                    fontSize: bold ? 15 : 13,
                    height: 1.2,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ],
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool flat;
  final bool padded;
  final EdgeInsetsGeometry? margin;

  const _Card({
    required this.child,
    this.flat = false,
    this.padded = false,
    this.margin,
  });

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
      child: padded
          ? Padding(padding: const EdgeInsets.all(12), child: child)
          : child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.title.copyWith(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
