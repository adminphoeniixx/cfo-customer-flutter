import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/address.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/pill_badge.dart';

class AddressesView extends StatefulWidget {
  const AddressesView({super.key});

  @override
  State<AddressesView> createState() => _AddressesViewState();
}

class _AddressesViewState extends State<AddressesView> {
  final _repo = Get.find<AccountRepository>();
  List<Address> addresses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = addresses.isEmpty);
    try {
      addresses = await _repo.addresses();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _delete(Address a) async {
    try {
      await _repo.deleteAddress(a.id);
      _load();
    } on AppException catch (e) {
      CfoToast.error(e.message);
    }
  }

  Future<void> _setDefault(Address a) async {
    try {
      await _repo.setDefaultAddress(a.id);
      _load();
    } on AppException catch (e) {
      CfoToast.error(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const CfoAppBar(title: 'Saved addresses'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
          ? EmptyState(
              icon: Icons.location_on_outlined,
              title: 'No saved addresses',
              actionLabel: 'Add address',
              onAction: () =>
                  Get.toNamed(AppRoutes.addressForm)?.then((_) => _load()),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              children: [
                for (final a in addresses) ...[
                  _AddressCard(
                    address: a,
                    onEdit: () => Get.toNamed(
                      AppRoutes.addressForm,
                      arguments: {'address': a},
                    )?.then((_) => _load()),
                    onMakeDefault: () => _setDefault(a),
                    onDelete: () => _delete(a),
                  ),
                  const SizedBox(height: 9),
                ],
                _GhostButton(
                  label: '+ Add a new address',
                  onTap: () =>
                      Get.toNamed(AppRoutes.addressForm)?.then((_) => _load()),
                ),
              ],
            ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onMakeDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onMakeDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  address.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.5,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if ((address.label ?? '').isNotEmpty) ...[
                const SizedBox(width: 7),
                PillBadge(label: address.label!, tone: PillTone.neutral),
              ],
              if (address.isDefaultShipping) ...[
                const SizedBox(width: 7),
                const PillBadge(label: 'Default', tone: PillTone.info),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _addressLines(address),
            style: AppTextStyles.body.copyWith(
              color: AppColors.ink2,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            address.phone,
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LinkButton(label: 'Edit', onTap: onEdit),
              if (!address.isDefaultShipping) ...[
                const SizedBox(width: 16),
                _LinkButton(
                  label: 'Make default',
                  color: AppColors.ink2,
                  onTap: onMakeDefault,
                ),
              ],
              const SizedBox(width: 16),
              _LinkButton(
                label: 'Delete',
                color: AppColors.critical,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LinkButton({
    required this.label,
    required this.onTap,
    this.color = AppColors.action,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: color,
          fontSize: 12.5,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.action,
          textStyle: AppTextStyles.button.copyWith(
            fontSize: 14,
            height: 1,
            letterSpacing: 0.02,
          ),
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label),
      ),
    );
  }
}

String _addressLines(Address a) {
  return [
    a.addressLine1,
    if ((a.addressLine2 ?? '').isNotEmpty) a.addressLine2!,
    [a.city, a.state, a.postcode].where((e) => e.isNotEmpty).join(' '),
  ].where((line) => line.isNotEmpty).join('\n');
}
