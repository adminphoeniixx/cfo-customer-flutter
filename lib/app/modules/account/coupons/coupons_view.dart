import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/cart.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/prototype_image.dart';

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  final _repo = Get.find<CartRepository>();
  final _code = TextEditingController();
  List<AvailableCoupon> coupons = [];
  bool loading = true;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = coupons.isEmpty);
    try {
      coupons = await _repo.availableCoupons();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _apply(String code) async {
    if (code.trim().isEmpty || busy) return;
    setState(() => busy = true);
    try {
      await _repo.applyCoupon(code.trim().toUpperCase());
      await _load();
      CfoToast.success('${code.trim().toUpperCase()} applied');
    } on AppException catch (e) {
      CfoToast.error(e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _remove() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await _repo.removeCoupon();
      await _load();
      CfoToast.success('Coupon removed');
    } on AppException catch (e) {
      CfoToast.error(e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const CfoAppBar(title: 'Coupons'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              children: [
                _Card(
                  padded: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have a code?',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 46,
                        child: TextField(
                          controller: _code,
                          textCapitalization: TextCapitalization.characters,
                          style: AppTextStyles.body.copyWith(fontSize: 14),
                          decoration: _inputDecoration('FIRST100'),
                        ),
                      ),
                      const SizedBox(height: 9),
                      _BrandButton(
                        label: busy ? 'Applying...' : 'Apply',
                        onTap: busy ? null : () => _apply(_code.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                const _SectionTitle('Available for you'),
                const SizedBox(height: 9),
                _Card(
                  children: [
                    for (final coupon in coupons)
                      _CouponRow(
                        coupon: coupon,
                        busy: busy,
                        onApply: () => _apply(coupon.code),
                        onRemove: _remove,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'One coupon per order. Seller offers on the product page stack with these.',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.5,
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CouponRow extends StatelessWidget {
  final AvailableCoupon coupon;
  final bool busy;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _CouponRow({
    required this.coupon,
    required this.busy,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      coupon.description ?? _couponDescription(coupon),
      if (!coupon.usable && (coupon.reason ?? '').isNotEmpty) coupon.reason,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PrototypeImage(source: '🏷️', size: 44, fontSize: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        coupon.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13.5,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (coupon.applied) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.okBg,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'Applied',
                          style: AppTextStyles.tiny.copyWith(
                            color: AppColors.okInk,
                            fontSize: 9.5,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: busy
                ? null
                : coupon.applied
                ? onRemove
                : coupon.usable
                ? onApply
                : null,
            style: TextButton.styleFrom(
              foregroundColor: coupon.usable || coupon.applied
                  ? AppColors.action
                  : AppColors.ink3,
              textStyle: AppTextStyles.body.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(coupon.applied ? 'Remove' : 'Apply'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;
  final bool padded;

  const _Card({this.child, this.children, this.padded = false});

  @override
  Widget build(BuildContext context) {
    final content =
        child ??
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children!.length; i++) ...[
              children![i],
              if (i != children!.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.lineSoft,
                ),
            ],
          ],
        );
    return Container(
      padding: padded ? const EdgeInsets.all(12) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BrandButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _BrandButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onBrand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTextStyles.button.copyWith(
            fontSize: 14,
            height: 1,
            letterSpacing: 0.02,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: const BorderSide(color: AppColors.action),
    ),
  );
}

String _couponDescription(AvailableCoupon coupon) {
  return switch (coupon.type) {
    'flat' => '${coupon.value.toStringAsFixed(0)} off',
    'percent' => '${coupon.value.toStringAsFixed(0)}% off',
    'free_shipping' => 'Free delivery',
    _ => coupon.code,
  };
}
