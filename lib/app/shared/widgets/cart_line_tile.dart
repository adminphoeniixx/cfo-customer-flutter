import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/cart.dart';
import '../../core/utils/formatters.dart';
import 'prototype_image.dart';

class CartLineTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove;
  final VoidCallback? onSaveForLater;
  final VoidCallback?
  onMoveToCart; // shown when this line is in saved-for-later
  final bool isSaved;

  const CartLineTile({
    super.key,
    required this.item,
    this.onQuantityChanged,
    this.onRemove,
    this.onSaveForLater,
    this.onMoveToCart,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final optionsLabel = item.options?.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(' · ');
    final discount = item.mrp == null || item.mrp! <= item.unitPrice
        ? 0
        : (((item.mrp! - item.unitPrice) / item.mrp!) * 100).round();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrototypeImage(
            source: item.image,
            size: 64,
            fontSize: 30,
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
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (optionsLabel != null && optionsLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      optionsLabel,
                      style: AppTextStyles.tiny.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      formatInr(item.total),
                      style: AppTextStyles.price.copyWith(fontSize: 16),
                    ),
                    if (item.mrp != null && item.mrp! > item.unitPrice) ...[
                      Text(
                        formatInr(item.mrp! * item.quantity),
                        style: AppTextStyles.priceStrike,
                      ),
                      Text(
                        '$discount% off',
                        style: AppTextStyles.tiny.copyWith(
                          color: AppColors.sale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                if (!item.inStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Out of stock',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.critical,
                        fontSize: 11.5,
                      ),
                    ),
                  )
                else if (item.available != null &&
                    item.available! < item.quantity)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Only ${item.available} left',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.sale,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 16,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!isSaved)
                      _QtyStepper(
                        quantity: item.quantity,
                        onChanged: onQuantityChanged,
                      ),
                    if (isSaved && onMoveToCart != null)
                      _ActionTextButton(
                        label: 'Move to cart',
                        onPressed: onMoveToCart,
                      )
                    else if (onSaveForLater != null)
                      _ActionTextButton(
                        label: 'Save for later',
                        onPressed: onSaveForLater,
                      ),
                    _ActionTextButton(
                      label: 'Remove',
                      onPressed: onRemove,
                      color: AppColors.critical,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const _ActionTextButton({
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int>? onChanged;
  const _QtyStepper({required this.quantity, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn(
            Icons.remove,
            quantity > 1 ? () => onChanged?.call(quantity - 1) : null,
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: AppColors.line),
              ),
            ),
            child: Text('$quantity', style: AppTextStyles.bodyMedium),
          ),
          _stepBtn(
            Icons.add,
            quantity < 10 ? () => onChanged?.call(quantity + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap) => InkWell(
    onTap: onTap,
    child: SizedBox(
      width: 30,
      height: 28,
      child: Icon(
        icon,
        size: 16,
        color: onTap == null ? AppColors.ink3 : AppColors.ink,
      ),
    ),
  );
}
