import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/cart.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_sheet.dart';
import '../../shared/widgets/prototype_image.dart';
import '../cart/cart_controller.dart';

/// Shown when `POST /orders` answers 422 on `items`: a product in the cart
/// came off sale (e.g. while its price was being updated). Lists the
/// server's messages and lets the shopper remove the affected lines here,
/// then return to placing the order. Resolves to true if anything was
/// removed, so the caller can re-quote the checkout.
class UnavailableItemsSheet extends StatefulWidget {
  const UnavailableItemsSheet({super.key, required this.messages});

  final List<String> messages;

  static Future<bool> show(List<String> messages) async {
    final removed = await AppSheet.show<bool>(
      title: 'Some items are unavailable',
      child: UnavailableItemsSheet(messages: messages),
    );
    return removed == true;
  }

  @override
  State<UnavailableItemsSheet> createState() => _UnavailableItemsSheetState();
}

class _UnavailableItemsSheetState extends State<UnavailableItemsSheet> {
  final Set<int> _removing = {};
  final Set<int> _removed = {};

  CartController? get _cart =>
      Get.isRegistered<CartController>() ? Get.find<CartController>() : null;

  /// Cart lines the server named. Messages carry the product name, not an
  /// id, so lines are matched by name.
  List<CartItem> _affected() {
    final groups = _cart?.cart.value?.groups ?? const <CartGroup>[];
    final text = widget.messages.join('\n').toLowerCase();
    return [
      for (final g in groups)
        for (final item in g.items)
          if (item.name.trim().isNotEmpty &&
              text.contains(item.name.trim().toLowerCase()))
            item,
    ];
  }

  Future<void> _remove(CartItem item) async {
    final cart = _cart;
    if (cart == null) return;
    setState(() => _removing.add(item.id));
    await cart.removeItem(item.id);
    if (!mounted) return;
    final stillThere = (cart.cart.value?.groups ?? const <CartGroup>[])
        .any((g) => g.items.any((i) => i.id == item.id));
    setState(() {
      _removing.remove(item.id);
      if (!stillThere) _removed.add(item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final affected = _affected();
    final pending = affected.where((i) => !_removed.contains(i.id)).toList();
    final allRemoved = affected.isNotEmpty && pending.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warnBg,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                IconsaxPlusLinear.info_circle,
                size: 20,
                color: AppColors.warnInk,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final m in widget.messages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          m,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.warnInk,
                            height: 1.35,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Nothing is charged for removed items.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warnInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final item in affected)
          _Line(
            item: item,
            removing: _removing.contains(item.id),
            removed: _removed.contains(item.id),
            onRemove: () => _remove(item),
          ),
        const SizedBox(height: 8),
        if (affected.isEmpty)
          // Could not match a line by name — let the shopper fix it in the
          // cart, where every line has its own remove action.
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                Get.offAllNamed(AppRoutes.nav, arguments: {'tab': 3});
              },
              child: const Text('Review cart'),
            ),
          )
        else
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: allRemoved
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: Text(
                allRemoved ? 'Continue to checkout' : 'Remove items to continue',
              ),
            ),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.item,
    required this.removing,
    required this.removed,
    required this.onRemove,
  });

  final CartItem item;
  final bool removing;
  final bool removed;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Opacity(
        opacity: removed ? 0.5 : 1,
        child: Row(
          children: [
            PrototypeImage(
              source: item.image,
              size: 52,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  decoration: removed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (removed)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    IconsaxPlusLinear.tick_circle,
                    size: 16,
                    color: AppColors.deal,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Removed',
                    style: AppTextStyles.label.copyWith(color: AppColors.deal),
                  ),
                ],
              )
            else
              SizedBox(
                height: 36,
                child: TextButton.icon(
                  onPressed: removing ? null : onRemove,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.critBg,
                    foregroundColor: AppColors.critInk,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: removing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.critInk,
                          ),
                        )
                      : const Icon(IconsaxPlusLinear.trash, size: 16),
                  label: const Text('Remove'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
