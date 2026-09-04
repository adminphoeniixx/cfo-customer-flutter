import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/address.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/bottom_buy_bar.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../checkout_controller.dart';
import '../checkout_step_indicator.dart';

class CheckoutAddressView extends StatelessWidget {
  const CheckoutAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CheckoutController>()
        ? Get.find<CheckoutController>()
        : Get.put(CheckoutController());
    return Scaffold(
      appBar: CfoAppBar(title: 'Delivery address', subtitle: 'Step 1 of 3'),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final s = controller.summary.value;
        if (s == null) {
          return Center(
            child: Text(
              controller.error.value.isEmpty
                  ? 'Could not load checkout.'
                  : controller.error.value,
            ),
          );
        }
        return Column(
          children: [
            const CheckoutStepIndicator(step: 0),
            Expanded(
              child: s.addresses.isEmpty
                  ? EmptyState(
                      icon: Icons.location_on_outlined,
                      title: 'No saved addresses',
                      message: 'Add an address before choosing delivery.',
                      actionLabel: 'Add address',
                      onAction: controller.addAddress,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 82),
                      children: [
                        for (final address in s.addresses)
                          _AddressCard(
                            address: address,
                            selected:
                                controller.selectedAddressId.value ==
                                address.id,
                            onSelect: () =>
                                controller.selectedAddressId.value = address.id,
                            onEdit: () => controller.editAddress(address),
                            onDelete: () => controller.deleteAddress(address),
                          ),
                        const SizedBox(height: AppSpace.sm),
                        SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: controller.addAddress,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              side: const BorderSide(color: AppColors.line),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              '+ Add a new address',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.brand,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () => BottomBuyBar(
          actionLabel: 'Deliver here',
          enabled:
              controller.selectedAddressId.value != null &&
              !controller.addressBusy.value,
          onAction: () => Get.toNamed(AppRoutes.checkoutDelivery),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.action : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
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
                  Wrap(
                    spacing: 7,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        address.fullName,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      if ((address.label ?? '').isNotEmpty)
                        _Pill(address.label!),
                      if (address.isDefaultShipping)
                        const _Pill('Default', info: true),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _addressLines(address),
                    style: AppTextStyles.label.copyWith(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.ink2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    address.phone,
                    style: AppTextStyles.caption.copyWith(fontSize: 12),
                  ),
                  if (selected) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      children: [
                        _LinkAction(onPressed: onEdit, label: 'Edit'),
                        _LinkAction(
                          onPressed: onDelete,
                          label: 'Delete',
                          color: AppColors.critical,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _addressLines(Address a) => [
    a.addressLine1,
    a.addressLine2,
    '${a.city}, ${a.state} ${a.postcode}',
  ].where((e) => e != null && e.isNotEmpty).join('\n');
}

class _Pill extends StatelessWidget {
  final String label;
  final bool info;
  const _Pill(this.label, {this.info = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: info ? AppColors.infoBg : AppColors.surface2,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: AppTextStyles.tiny.copyWith(
          color: info ? AppColors.infoInk : AppColors.ink3,
          fontSize: 10.5,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LinkAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _LinkAction({required this.label, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: AppTextStyles.tiny.copyWith(
            color: color ?? AppColors.action,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
