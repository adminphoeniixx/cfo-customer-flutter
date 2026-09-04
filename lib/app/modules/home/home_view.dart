import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/notifications_badge_service.dart';
import '../../core/auth/wishlist_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_content.dart';
import '../../data/models/category.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/cfo_app_bar.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/prototype_image.dart';
import '../../shared/widgets/section_header.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) Get.put(HomeController());
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: CfoAppBar.search(
        showBack: false,
        searchPlaceholder: 'Search for sarees, kurtas…',
        onSearchTap: () => Get.toNamed(AppRoutes.search),
        actions: [
          CfoAppBarAction(
            icon: AppSvgIcons.heart,
            tooltip: 'Wishlist',
            badgeCount: () => Get.find<WishlistService>().ids.length,
            onTap: () => Get.toNamed(AppRoutes.wishlist),
          ),
          CfoAppBarAction(
            icon: AppSvgIcons.bell,
            tooltip: 'Notifications',
            badgeCount: () =>
                Get.find<NotificationsBadgeService>().unreadCount.value,
            onTap: () => Get.toNamed(AppRoutes.notifications),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value && controller.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.isNotEmpty && controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 40,
                  color: AppColors.ink3,
                ),
                const SizedBox(height: 8),
                Text(controller.error.value, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpace.xl),
            children: [
              if (controller.banners.isNotEmpty)
                _BannerCarousel(
                  banners: controller.banners,
                  onTap: controller.openBanner,
                ),
              if (controller.categories.isNotEmpty)
                _CategoryStrip(categories: controller.categories),
              if (controller.deals.isNotEmpty) ...[
                SectionHeader(
                  title: 'Deals of the day',
                  actionLabel: 'See all',
                  onAction: () => Get.toNamed(
                    AppRoutes.results,
                    arguments: {'sort': 'discount'},
                  ),
                ),
                _DealsGrid(products: controller.deals.take(4).toList()),
              ],
              if (controller.topRated.isNotEmpty) ...[
                SectionHeader(
                  title: 'Top rated',
                  actionLabel: 'See all',
                  onAction: () => Get.toNamed(
                    AppRoutes.results,
                    arguments: {'sort': 'rating'},
                  ),
                ),
                _ProductRow(products: controller.topRated),
              ],
              if (controller.newArrivals.isNotEmpty) ...[
                SectionHeader(
                  title: 'New arrivals',
                  actionLabel: 'See all',
                  onAction: () => Get.toNamed(
                    AppRoutes.results,
                    arguments: {'sort': 'newest'},
                  ),
                ),
                _ProductRow(products: controller.newArrivals),
              ],
              if (controller.sellers.isNotEmpty) ...[
                const SectionHeader(title: 'Popular sellers'),
                _SellerRow(sellers: controller.sellers),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  final List<HomeBanner> banners;
  final ValueChanged<HomeBanner> onTap;
  const _BannerCarousel({required this.banners, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: 6),
        itemCount: banners.length,
        itemBuilder: (context, i) {
          final b = banners[i];
          return GestureDetector(
            onTap: () => onTap(b),
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: AppSpace.sm),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.line),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PrototypeImage(
                    source: b.imageUrl,
                    fontSize: 32,
                    borderRadius: BorderRadius.zero,
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          b.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onBrand,
                          ),
                        ),
                        if ((b.subtitle ?? '').isNotEmpty)
                          Text(
                            b.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11.5,
                              color: AppColors.onBrand,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Rounded-square icon chips (the prototype's `.circles .ic`,
/// `border-radius: 16px`, not a full circle) — using the category's real
/// photo from the live API rather than the prototype's placeholder emoji.
class _CategoryStrip extends StatelessWidget {
  final List<Category> categories;
  const _CategoryStrip({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final c = categories[i];
          return GestureDetector(
            onTap: () => Get.toNamed(
              AppRoutes.results,
              arguments: {'category_id': c.id, 'title': c.name},
            ),
            child: SizedBox(
              width: 70,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight.isFinite
                      ? constraints.maxHeight
                      : 96.0;
                  final compact = h < 86;
                  final labelHeight = compact ? 18.0 : 34.0;
                  final gap = compact ? 2.0 : 4.0;
                  final imageSlot = (h - labelHeight - gap)
                      .clamp(40.0, 58.0)
                      .toDouble();
                  final imageSize = (imageSlot - 6)
                      .clamp(34.0, 52.0)
                      .toDouble();
                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          height: imageSlot,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: PrototypeImage(
                              source: c.image,
                              size: imageSize,
                              fontSize: imageSize * 0.54,
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: labelHeight,
                        child: Text(
                          c.name,
                          style: AppTextStyles.tiny.copyWith(
                            fontSize: 10.5,
                            height: 1.15,
                            color: AppColors.ink2,
                          ),
                          maxLines: compact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Deals of the day — a non-scrolling 2-column grid (the prototype's
/// `.pgrid`), not a horizontal rail like the other sections.
class _DealsGrid extends StatelessWidget {
  final List products;
  const _DealsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpace.sm,
          crossAxisSpacing: AppSpace.sm,
          mainAxisExtent: 250,
        ),
        itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          return ProductCard(
            product: p,
            showWishlist: true,
            wide: true,
            onTap: () => Get.toNamed(
              AppRoutes.productDetail,
              arguments: {'idOrSlug': p.slug},
            ),
          );
        },
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final List products;
  const _ProductRow({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 264,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
        itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpace.sm),
            child: SizedBox(
              width: 150,
              child: ProductCard(
                product: p,
                showWishlist: true,
                onTap: () => Get.toNamed(
                  AppRoutes.productDetail,
                  arguments: {'idOrSlug': p.slug},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SellerRow extends StatelessWidget {
  final List sellers;
  const _SellerRow({required this.sellers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
        itemCount: sellers.length,
        itemBuilder: (context, i) {
          final s = sellers[i];
          return GestureDetector(
            onTap: () =>
                Get.toNamed(AppRoutes.seller, arguments: {'vendorId': s['id']}),
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: AppSpace.sm),
              padding: const EdgeInsets.all(AppSpace.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${s['name']}',
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('${s['city'] ?? ''}', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      Text(' ${s['rating']}', style: AppTextStyles.tiny),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
