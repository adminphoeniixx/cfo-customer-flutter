import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/wishlist_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/product.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/bottom_buy_bar.dart';
import '../../shared/widgets/cfo_app_bar.dart';
import '../../shared/widgets/price_line.dart';
import '../../shared/widgets/prototype_image.dart';
import '../../shared/widgets/rating_pill.dart';
import '../cart/cart_controller.dart';
import 'product_detail_controller.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ProductDetailController(),
      tag: UniqueKey().toString(),
    );
    return Obx(() {
      final p = controller.product.value;
      return Scaffold(
        backgroundColor: AppColors.ground,
        appBar: CfoAppBar(
          title: p?.name ?? 'Product',
          subtitle: p?.vendor?.name,
          actions: [
            CfoAppBarAction(
              icon: AppSvgIcons.heart,
              tooltip: 'Wishlist',
              badgeCount: () => Get.find<WishlistService>().ids.length,
              onTap: controller.toggleWishlist,
            ),
            CfoAppBarAction(
              icon: AppSvgIcons.bag,
              tooltip: 'Cart',
              badgeCount: () => Get.isRegistered<CartController>()
                  ? (Get.find<CartController>().cart.value?.totals.itemsCount ??
                        0)
                  : 0,
              onTap: () => Get.toNamed(AppRoutes.cart),
            ),
          ],
        ),
        body: controller.loading.value
            ? const Center(child: CircularProgressIndicator())
            : p == null
            ? const Center(child: Text('Product not found'))
            : ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  _ImageCard(product: p),
                  const SizedBox(height: AppSpace.sm),
                  _InfoCard(product: p),
                  const SizedBox(height: AppSpace.sm),
                  _DeliveryCard(product: p),
                  if (p.options.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.sm),
                    _OptionsPicker(controller: controller, product: p),
                  ],
                  if (p.shortDescription != null || p.description != null) ...[
                    const SizedBox(height: AppSpace.sm),
                    _TextCard(text: p.shortDescription ?? p.description!),
                  ],
                  if (p.specifications.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.sm),
                    _SpecsTable(specs: p.specifications),
                  ],
                ],
              ),
        bottomNavigationBar: p == null
            ? const SizedBox.shrink()
            : BottomBuyBar(
                enabled: p.inStock,
                loading: controller.addingToCart.value,
                secondaryLabel: p.inStock ? 'Add to cart' : null,
                onSecondaryAction: p.inStock ? controller.addToCart : null,
                actionLabel: p.inStock ? 'Buy now' : 'Out of stock',
                onAction: p.inStock ? controller.buyNow : null,
              ),
      );
    });
  }
}

class _ImageCard extends StatelessWidget {
  final ProductDetail product;
  const _ImageCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final images = product.images.isEmpty
        ? [ProductImage(id: 0, url: product.imageSource ?? '')]
        : product.images;
    return _Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        child: Column(
          children: [
            PrototypeImage(
              source: images.first.url,
              width: double.infinity,
              height: 250,
              fontSize: 108,
              borderRadius: BorderRadius.circular(9),
            ),
            const SizedBox(height: AppSpace.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < images.take(4).length; i++) ...[
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: i == 0 ? AppColors.action : AppColors.line,
                        width: i == 0 ? 2 : 1,
                      ),
                    ),
                    child: PrototypeImage(
                      source: images[i].url,
                      size: 44,
                      fontSize: 20,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: AppSpace.xs),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ProductDetail product;
  const _InfoCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.brand != null)
              Text(
                product.brand!,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.ink3,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(product.name, style: AppTextStyles.h3.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              children: [
                if (product.rating > 0)
                  RatingPill(
                    rating: product.rating,
                    count: product.ratingsCount,
                  ),
                if (product.rating > 0) const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.reviews,
                    arguments: {
                      'productId': product.id,
                      'productName': product.name,
                    },
                  ),
                  child: Text(
                    '${product.ratingsCount} ratings',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PriceLine(
              price: product.price,
              mrp: product.mrp,
              discountPercent: product.discountPercent,
              priceSize: 24,
            ),
            const SizedBox(height: 8),
            const Text('Inclusive of all taxes', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final ProductDetail product;
  const _DeliveryCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final vendor = product.vendor;
    return _Card(
      flat: true,
      child: Column(
        children: [
          _InfoRow(
            icon: '📍',
            title: 'Deliver to 600090, Chennai',
            subtitle:
                '${product.stockStatus ?? '4-7 days'} · ${product.requiresShipping ? 'Prepaid only' : 'Digital delivery'}',
            action: 'Change',
          ),
          _InfoRow(
            icon: '↩',
            title: '7-day return',
            subtitle: 'Free pickup if it arrives damaged or wrong',
          ),
          if (vendor != null)
            _InfoRow(
              icon: '🏬',
              title: 'Sold by ${vendor.name}',
              subtitle:
                  '${vendor.rating?.toStringAsFixed(1) ?? '4.4'} Seller rating · ships from ${vendor.city ?? 'seller city'}',
              chevron: true,
              onTap: () => Get.toNamed(
                AppRoutes.seller,
                arguments: {'vendorId': vendor.id},
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? action;
  final bool chevron;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.chevron = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.sm),
        child: Row(
          children: [
            PrototypeImage(
              source: icon,
              size: 44,
              fontSize: 22,
              borderRadius: BorderRadius.circular(9),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (action != null)
              Text(
                action!,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.action,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (chevron) const Icon(Icons.chevron_right, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}

class _OptionsPicker extends StatelessWidget {
  final ProductDetailController controller;
  final ProductDetail product;
  const _OptionsPicker({required this.controller, required this.product});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final opt in product.options) ...[
              Text(opt.name, style: AppTextStyles.title),
              const SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final val in opt.values)
                      ChoiceChip(
                        label: Text(val.value),
                        selected:
                            controller.selectedOptions[opt.name] == val.value,
                        onSelected: val.inStock
                            ? (_) =>
                                  controller.selectOption(opt.name, val.value)
                            : null,
                        backgroundColor: val.inStock
                            ? AppColors.surface
                            : AppColors.surface2,
                        labelStyle: TextStyle(
                          color: val.inStock ? null : AppColors.ink3,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  final String text;
  const _TextCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Text(text, style: AppTextStyles.body.copyWith(height: 1.45)),
      ),
    );
  }
}

class _SpecsTable extends StatelessWidget {
  final Map<String, dynamic> specs;
  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Specifications', style: AppTextStyles.title),
            const SizedBox(height: 8),
            for (final e in specs.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(e.key, style: AppTextStyles.caption),
                    ),
                    Expanded(
                      child: Text('${e.value}', style: AppTextStyles.body),
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

class _Card extends StatelessWidget {
  final Widget child;
  final bool flat;
  const _Card({required this.child, this.flat = false});

  @override
  Widget build(BuildContext context) {
    return Container(
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

extension on ProductDetail {
  String? get imageSource => images.isNotEmpty ? images.first.url : null;
}
