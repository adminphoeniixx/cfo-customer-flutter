import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/wishlist_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/product.dart';
import 'app_icons.dart';
import 'price_line.dart';
import 'prototype_image.dart';
import 'rating_pill.dart';

/// One product tile — used in listings, home sections, search, wishlist.
class ProductCard extends StatelessWidget {
  final ProductCardModel product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  /// Show the heart bound live to the app-wide [WishlistService] and toggle
  /// it in place, so hearts everywhere the product appears agree instantly.
  /// Ignored if [onWishlistTap] is supplied (screens with bespoke behaviour,
  /// e.g. the Wishlist tab's "remove" action, keep their own handler).
  final bool showWishlist;

  /// True for the wider 2-column grid cells (matches the prototype's
  /// `.pgrid` deal cards) — there's room to show "X% off" next to the
  /// price without wrapping, unlike the narrow horizontal-rail cards.
  final bool wide;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistTap,
    this.showWishlist = false,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: PrototypeImage(
                    source: product.image,
                    width: double.infinity,
                    height: wide ? 116 : 96,
                    fontSize: wide ? 46 : 38,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                if (onWishlistTap != null || showWishlist)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: GestureDetector(
                      onTap:
                          onWishlistTap ??
                          () => Get.find<WishlistService>().toggle(product.id),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.line),
                        ),
                        child: onWishlistTap != null
                            ? AppIcon(
                                AppSvgIcons.heart,
                                size: 15,
                                color: product.isWishlisted == true
                                    ? AppColors.brand
                                    : AppColors.ink3,
                              )
                            : Obx(
                                () => AppIcon(
                                  AppSvgIcons.heart,
                                  size: 15,
                                  color:
                                      Get.find<WishlistService>().ids.contains(
                                        product.id,
                                      )
                                      ? AppColors.brand
                                      : AppColors.ink3,
                                ),
                              ),
                      ),
                    ),
                  ),
                if (!product.inStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      alignment: Alignment.center,
                      child: Text(
                        'OUT OF STOCK',
                        style: AppTextStyles.tiny.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.brand != null)
                      Text(
                        product.brand!,
                        style: AppTextStyles.tiny.copyWith(fontSize: 10.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      product.name,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.ink,
                        height: 1.25,
                        fontSize: 12.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // The narrow horizontal-rail cards don't have room for the
                    // "X% off" text without wrapping onto a second line and
                    // overflowing the fixed-height cell (it's already shown as
                    // a badge on the image there); the wider grid cards do.
                    PriceLine(
                      price: product.price,
                      mrp: product.mrp,
                      discountPercent: wide ? product.discountPercent : null,
                      priceSize: 15.5,
                      singleLine: !wide,
                    ),
                    if (product.rating > 0) ...[
                      const SizedBox(height: 2),
                      RatingPill(
                        rating: product.rating,
                        count: wide ? product.ratingsCount : null,
                      ),
                    ],
                    if (wide && product.assured) ...[
                      const SizedBox(height: 4),
                      Text(
                        '✓ CFO Assured',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.tiny.copyWith(
                          color: AppColors.action,
                          fontSize: 9.5,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.02,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
