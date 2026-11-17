import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/address.dart';
import '../../../data/models/checkout.dart';
import '../../../shared/widgets/bottom_buy_bar.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../checkout_controller.dart';
import '../checkout_step_indicator.dart';

class CheckoutPaymentView extends StatefulWidget {
  const CheckoutPaymentView({super.key});

  @override
  State<CheckoutPaymentView> createState() => _CheckoutPaymentViewState();
}

class _CheckoutPaymentViewState extends State<CheckoutPaymentView> {
  final noteCtrl = TextEditingController();

  @override
  void dispose() {
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckoutController>();
    return Scaffold(
      appBar: CfoAppBar(title: 'Payment', subtitle: 'Step 3 of 3'),
      body: Obx(() {
        final s = controller.summary.value;
        if (s == null) return const Center(child: CircularProgressIndicator());
        final available = controller.selectedPaymentMethod.value.isNotEmpty;
        final gateway = controller.gateway.value;
        final address = _selectedAddress(s);
        return Column(
          children: [
            const CheckoutStepIndicator(step: 2),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 82),
                children: [
                  _Card(
                    flat: true,
                    child: _GatewayOption(
                      available: available,
                      gateway: gateway,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (available && gateway.enabled)
                    _GatewayNote(name: gateway.name ?? 'The payment page'),
                  const SizedBox(height: 16),
                  const _SectionTitle('Delivering to'),
                  const SizedBox(height: 8),
                  if (address != null) _AddressSummary(address: address),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final s = controller.summary.value;
        final total =
            controller.chargeAmount.value ?? s?.totals.grandTotal ?? 0;
        final gatewayOn = controller.gateway.value.enabled;
        return BottomBuyBar(
          leading: SizedBox(
            width: 126,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(formatInr(total), style: AppTextStyles.h3),
                const Text('payable now', style: AppTextStyles.caption),
              ],
            ),
          ),
          actionLabel: gatewayOn ? 'Pay ${formatInr(total)}' : 'Place order',
          loading: controller.placing.value,
          onAction: controller.placeOrder,
        );
      }),
    );
  }

  Address? _selectedAddress(CheckoutSummary summary) {
    final id = Get.find<CheckoutController>().selectedAddressId.value;
    for (final address in summary.addresses) {
      if (address.id == id) return address;
    }
    return summary.addresses.isEmpty ? null : summary.addresses.first;
  }
}

/// The only way to pay: the gateway switched on in the admin panel offers
/// UPI, cards, net banking and wallets itself, so the app does not list them.
class _GatewayOption extends StatelessWidget {
  final bool available;
  final PaymentGatewayConfig gateway;

  const _GatewayOption({required this.available, required this.gateway});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: available ? 1 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Mark(selected: available),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        IconsaxPlusLinear.shield_tick,
                        size: 18,
                        color: AppColors.brand,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          gateway.enabled && gateway.name != null
                              ? 'Pay with ${gateway.name}'
                              : 'Pay online',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 13.5,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (gateway.enabled && gateway.isTest) const _TestBadge(),
                    ],
                  ),
                  Text(
                    available
                        ? 'UPI, cards, net banking and wallets.'
                        : 'Online payment is unavailable right now.',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.5,
                      height: 1.45,
                      color: available ? null : AppColors.critical,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestBadge extends StatelessWidget {
  const _TestBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Text(
        'TEST MODE',
        style: AppTextStyles.tag.copyWith(color: AppColors.onAccent),
      ),
    );
  }
}

class _GatewayNote extends StatelessWidget {
  final String name;
  const _GatewayNote({required this.name});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "$name opens on the next screen, where you choose how to pay. Nothing is charged until you approve it there.",
          style: AppTextStyles.caption.copyWith(fontSize: 12, height: 1.45),
        ),
      ),
    );
  }
}

class _AddressSummary extends StatelessWidget {
  final Address address;
  const _AddressSummary({required this.address});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${address.fullName} · ${address.label ?? 'Address'}',
              style: AppTextStyles.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              address.singleLine,
              style: AppTextStyles.label.copyWith(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool flat;
  const _Card({required this.child, this.flat = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: flat ? Clip.antiAlias : Clip.none,
      child: child,
    );
  }
}

class _Mark extends StatelessWidget {
  final bool selected;

  const _Mark({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 19,
      height: 19,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.action : AppColors.line,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.action,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            )
          : null,
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
