import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/address.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../shared/widgets/bottom_buy_bar.dart';
import '../../../shared/widgets/cfo_app_bar.dart';

class AddressFormView extends StatefulWidget {
  const AddressFormView({super.key});

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  final _repo = Get.find<AccountRepository>();
  Address? existing;
  late final TextEditingController firstName;
  late final TextEditingController lastName;
  late final TextEditingController phone;
  late final TextEditingController line1;
  late final TextEditingController line2;
  late final TextEditingController city;
  late final TextEditingController postcode;
  String label = 'Home';
  String state = 'Tamil Nadu';
  bool isDefault = false;
  bool saving = false;
  String? error;
  Map<String, String> fieldErrors = {};

  static const states = [
    'Tamil Nadu',
    'Karnataka',
    'Maharashtra',
    'Delhi',
    'Rajasthan',
    'West Bengal',
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    existing = args is Map ? args['address'] as Address? : null;
    firstName = TextEditingController(text: existing?.firstName ?? '');
    lastName = TextEditingController(text: existing?.lastName ?? '');
    phone = TextEditingController(text: existing?.phone ?? '');
    line1 = TextEditingController(text: existing?.addressLine1 ?? '');
    line2 = TextEditingController(text: existing?.addressLine2 ?? '');
    city = TextEditingController(text: existing?.city ?? '');
    postcode = TextEditingController(text: existing?.postcode ?? '');
    label = existing?.label ?? 'Home';
    state = states.contains(existing?.state) ? existing!.state : 'Tamil Nadu';
    isDefault = existing?.isDefaultShipping ?? false;
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    line1.dispose();
    line2.dispose();
    city.dispose();
    postcode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      saving = true;
      error = null;
      fieldErrors = {};
    });
    final body = {
      'label': label,
      'first_name': firstName.text.trim(),
      'last_name': lastName.text.trim(),
      'phone': phone.text.trim(),
      'address_line1': line1.text.trim(),
      'address_line2': line2.text.trim(),
      'city': city.text.trim(),
      'state': state,
      'postcode': postcode.text.trim(),
      'is_default_shipping': isDefault,
      'is_default_billing': isDefault,
    };
    try {
      if (existing != null) {
        await _repo.updateAddress(existing!.id, body);
      } else {
        await _repo.createAddress(body);
      }
      Get.back(result: true);
    } on AppException catch (e) {
      setState(() {
        error = e.message;
        fieldErrors = e.fieldErrors?.map((k, v) => MapEntry(k, v.first)) ?? {};
      });
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CfoAppBar.editForm(
        title: existing == null ? 'New address' : 'Edit address',
        onSave: _save,
        saving: saving,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.md),
        children: [
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: 'First name',
                  controller: firstName,
                  errorText: fieldErrors['first_name'],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: _Field(label: 'Last name', controller: lastName),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          _Field(
            label: 'Mobile number',
            controller: phone,
            keyboardType: TextInputType.phone,
            errorText: fieldErrors['phone'],
          ),
          const SizedBox(height: AppSpace.sm),
          _Field(
            label: 'Flat, house no., building',
            controller: line1,
            errorText: fieldErrors['address_line1'],
          ),
          const SizedBox(height: AppSpace.sm),
          _Field(label: 'Area, street, landmark', controller: line2),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: 'Pincode',
                  controller: postcode,
                  keyboardType: TextInputType.number,
                  errorText: fieldErrors['postcode'],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: _Field(
                  label: 'City',
                  controller: city,
                  errorText: fieldErrors['city'],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'State',
            style: AppTextStyles.tiny.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: state,
            items: states
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => state = v ?? state),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Save this address as',
            style: AppTextStyles.tiny.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final l in ['Home', 'Work', 'Other']) ...[
                _Swatch(
                  label: l,
                  selected: label == l,
                  onTap: () => setState(() => label = l),
                ),
                const SizedBox(width: AppSpace.xs),
              ],
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          InkWell(
            onTap: () => setState(() => isDefault = !isDefault),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDefault ? AppColors.action : AppColors.line,
                      width: 2,
                    ),
                    color: isDefault ? AppColors.brandSoft : AppColors.surface,
                  ),
                  child: isDefault
                      ? const Icon(
                          Icons.check,
                          size: 15,
                          color: AppColors.action,
                        )
                      : null,
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make this my default address',
                        style: AppTextStyles.title,
                      ),
                      Text(
                        'New orders will be sent here unless you change it.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              error!,
              style: AppTextStyles.body.copyWith(color: AppColors.critical),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomBuyBar(
        actionLabel: 'Save address',
        loading: saving,
        onAction: _save,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? errorText;

  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(errorText: errorText),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? AppColors.action : AppColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? AppColors.action : AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
