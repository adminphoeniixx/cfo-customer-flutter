import 'package:flutter/material.dart';
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
        final selected = controller.selectedPaymentMethod.value;
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
                    child: Column(
                      children: [
                        for (final method in s.paymentMethods)
                          _PaymentOption(
                            method: method,
                            selected: selected == method.code,
                            onTap: () =>
                                controller.selectedPaymentMethod.value =
                                    method.code,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_isCod(selected)) const _GatewayNote(),
                  if (_isCod(selected)) _CodNote(total: s.totals.grandTotal),
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
        final total = s?.totals.grandTotal ?? 0;
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
          actionLabel: _isCod(controller.selectedPaymentMethod.value)
              ? 'Place order'
              : 'Pay ${formatInr(total)}',
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

  bool _isCod(String code) =>
      kCodPaymentMethods.contains(code) || code.toLowerCase().contains('cod');
}

class _PaymentOption extends StatelessWidget {
  final PaymentMethodOption method;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !method.isAvailable;
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.45 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Mark(selected: selected && !disabled),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${method.icon ?? _iconFor(method.code)} ${method.name}',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 13.5,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    if (disabled && (method.unavailableReason ?? '').isNotEmpty)
                      Text(
                        method.unavailableReason!,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.5,
                          height: 1.45,
                          color: AppColors.critical,
                        ),
                      )
                    else if ((method.description ?? '').isNotEmpty)
                      Text(
                        method.description!,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _iconFor(String code) {
    final c = code.toLowerCase();
    if (c.contains('upi')) return '⚡';
    if (c.contains('card')) return '💳';
    if (c.contains('net')) return '🏦';
    if (c.contains('cod') || c.contains('cash')) return '💵';
    return '💳';
  }
}

class _GatewayNote extends StatelessWidget {
  const _GatewayNote();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          "You'll enter your UPI ID or card details on the next screen. Nothing is charged until you approve it there.",
          style: AppTextStyles.caption.copyWith(fontSize: 12, height: 1.45),
        ),
      ),
    );
  }
}

class _CodNote extends StatelessWidget {
  final double total;
  const _CodNote({required this.total});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Keep ${formatInr(total)} ready. The courier accepts UPI at the door too. Cash on delivery is not available on some seller items.',
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
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: flat ? Clip.antiAlias : Clip.none,
      child: child,
    );
  }
}

class _Mark extends StatelessWidget {
  final bool selected;
  final bool square;

  const _Mark({required this.selected, this.square = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 19,
      height: 19,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        shape: square ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: square ? BorderRadius.circular(4) : null,
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
                  borderRadius: BorderRadius.circular(square ? 1 : 9),
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
