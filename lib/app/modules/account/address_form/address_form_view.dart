import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:get/get.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/address.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../shared/widgets/bottom_buy_bar.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/search_picker_sheet.dart';

class AddressFormView extends StatefulWidget {
  const AddressFormView({super.key});

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  final _repo = Get.find<AccountRepository>();
  final _catalog = Get.find<CatalogRepository>();
  Address? existing;
  late final TextEditingController firstName;
  late final TextEditingController lastName;
  late final TextEditingController phone;
  late final TextEditingController line1;
  late final TextEditingController line2;
  late final TextEditingController city;
  late final TextEditingController postcode;
  String label = 'Home';

  /// Spelled exactly as `GET /states` returns it; the API rejects others.
  String? state;

  /// True once the shopper chose "Type your city" — the city list is the
  /// census town list, so not every village is in it.
  bool typingCity = false;
  bool isDefault = false;
  bool saving = false;
  String? error;
  Map<String, String> fieldErrors = {};

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
    state = (existing?.state ?? '').trim().isEmpty ? null : existing!.state;
    isDefault = existing?.isDefaultShipping ?? false;
    _canonicaliseState();
  }

  /// Saved addresses may hold any casing ("tamil nadu"); show and send the
  /// list's spelling so the save is not refused.
  Future<void> _canonicaliseState() async {
    final current = state;
    if (current == null) return;
    try {
      final all = await _catalog.states();
      final match = all.firstWhereOrNull(
        (s) => s.toLowerCase() == current.trim().toLowerCase(),
      );
      if (match != null && mounted) setState(() => state = match);
    } catch (_) {
      // Keep what was saved; the picker still works once the list loads.
    }
  }

  Future<void> _pickState() async {
    final picked = await SearchPickerSheet.show(
      title: 'Select state',
      searchHint: 'Search state',
      selected: state,
      load: _catalog.states,
    );
    final value = picked?.value;
    if (value == null || value == state) return;
    setState(() {
      state = value;
      city.clear();
      typingCity = false;
      fieldErrors.remove('state');
    });
  }

  Future<void> _pickCity() async {
    final st = state;
    if (st == null) {
      setState(() => fieldErrors['state'] = 'Select your state first');
      return;
    }
    final picked = await SearchPickerSheet.show(
      title: 'Select city',
      searchHint: 'Search city in $st',
      selected: city.text,
      typeOwnLabel: 'Type your city',
      load: () => _catalog.cities(st),
    );
    if (picked == null) return;
    setState(() {
      fieldErrors.remove('city');
      if (picked.typeOwn) {
        typingCity = true;
      } else {
        typingCity = false;
        city.text = picked.value!;
      }
    });
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
      'state': ?state,
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
      backgroundColor: AppColors.ground,
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
          _PickerField(
            label: 'State',
            value: state,
            placeholder: 'Select state',
            errorText: fieldErrors['state'],
            onTap: _pickState,
          ),
          const SizedBox(height: AppSpace.sm),
          if (typingCity)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Field(
                  label: 'City / town',
                  controller: city,
                  errorText: fieldErrors['city'],
                ),
                TextButton(
                  onPressed: _pickCity,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Text('Choose from list instead'),
                ),
              ],
            )
          else
            _PickerField(
              label: 'City',
              value: city.text.trim().isEmpty ? null : city.text.trim(),
              placeholder: state == null ? 'Select state first' : 'Select city',
              enabled: state != null,
              errorText: fieldErrors['city'],
              onTap: _pickCity,
            ),
          const SizedBox(height: AppSpace.sm),
          _Field(
            label: 'Pincode',
            controller: postcode,
            keyboardType: TextInputType.number,
            errorText: fieldErrors['postcode'],
          ),
          const SizedBox(height: AppSpace.md),
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
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDefault ? AppColors.brand : AppColors.ink3,
                      width: 1.5,
                    ),
                    color: isDefault ? AppColors.brand : AppColors.surface,
                  ),
                  child: isDefault
                      ? const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.onBrand,
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
    return Material(
      color: selected ? AppColors.brand : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: selected ? AppColors.onBrand : AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Looks like a text field; opens a picker on tap.
class _PickerField extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final bool enabled;
  final String? errorText;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Material(
          color: enabled ? AppColors.surface : AppColors.surface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            side: BorderSide(
              color: hasError ? AppColors.critical : AppColors.lineSoft,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: value == null ? AppColors.ink3 : AppColors.ink,
                      ),
                    ),
                  ),
                  Icon(
                    IconsaxPlusLinear.arrow_down_1,
                    size: 18,
                    color: enabled ? AppColors.ink2 : AppColors.ink3,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: AppTextStyles.caption.copyWith(color: AppColors.critical),
            ),
          ),
      ],
    );
  }
}
