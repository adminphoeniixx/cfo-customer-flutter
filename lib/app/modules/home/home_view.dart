import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:get/get.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/notifications_badge_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_content.dart';
import '../../data/models/category.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/cfo_app_bar.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/prototype_image.dart';
import '../../shared/widgets/rating_pill.dart';
import '../../shared/widgets/section_header.dart';
import '../nav/nav_controller.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) Get.put(HomeController());
    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _GreetingHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.md,
                AppSpace.xs,
                AppSpace.md,
                AppSpace.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SearchFieldButton(
                      placeholder: 'Search products, sellers…',
                      onTap: () => Get.toNamed(AppRoutes.search),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilterSquareButton(
                    onTap: () => Get.toNamed(AppRoutes.results),
                  ),
                ],
              ),
            ),
            Expanded(child: Obx(_body)),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (controller.loading.value && controller.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error.isNotEmpty && controller.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              IconsaxPlusLinear.wifi_square,
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
        padding: const EdgeInsets.only(top: AppSpace.xs, bottom: AppSpace.xl),
        children: [
          if (controller.banners.isNotEmpty)
            _BannerCarousel(
              banners: controller.banners,
              onTap: controller.openBanner,
            ),
          const _QuickActions(),
          if (controller.categories.isNotEmpty) ...[
            SectionHeader(
              title: 'Shop by category',
              actionLabel: 'See All',
              onAction: () => _goToTab(1),
            ),
            _CategoryChips(categories: controller.categories),
          ],
          if (controller.deals.isNotEmpty) ...[
            SectionHeader(
              title: 'Deals of the day',
              actionLabel: 'See All',
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
              actionLabel: 'See All',
              onAction: () =>
                  Get.toNamed(AppRoutes.results, arguments: {'sort': 'rating'}),
            ),
            _ProductRow(products: controller.topRated),
          ],
          if (controller.newArrivals.isNotEmpty) ...[
            SectionHeader(
              title: 'New arrivals',
              actionLabel: 'See All',
              onAction: () =>
                  Get.toNamed(AppRoutes.results, arguments: {'sort': 'newest'}),
            ),
            _ProductRow(products: controller.newArrivals),
          ],
          if (controller.sellers.isNotEmpty) ...[
            const SectionHeader(title: 'Top sellers near you'),
            _SellerList(sellers: controller.sellers),
          ],
        ],
      ),
    );
  }
}

void _goToTab(int i) {
  if (Get.isRegistered<NavController>()) Get.find<NavController>().changeTab(i);
}

/// "Hello, Name / What would you like to shop today?" with round
/// support + notification buttons, as in the design's header.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final auth = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>()
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.md,
        AppSpace.sm,
        AppSpace.md,
        AppSpace.xs,
      ),
      child: Row(
        children: [
          if (Navigator.of(context).canPop()) ...[
            CircleIconButton(
              icon: AppIcons.back,
              tooltip: 'Back',
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 8),
          ],
          Obx(() {
            final first = auth?.customer.value?.firstName?.trim() ?? '';
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: first.isEmpty
                        ? const AppIcon(
                            AppIcons.navAccountActive,
                            size: 22,
                            color: AppColors.onBrand,
                          )
                        : Text(
                            first.characters.first.toUpperCase(),
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.onBrand,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          first.isEmpty ? 'Hello there' : 'Hello, $first',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'What would you like to shop today?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: AppIcons.support,
            tooltip: 'Help & support',
            onTap: () => Get.toNamed(AppRoutes.help),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleIconButton(
                icon: AppIcons.bell,
                tooltip: 'Notifications',
                onTap: () => Get.toNamed(AppRoutes.notifications),
              ),
              Positioned(
                right: 11,
                top: 10,
                child: Obx(() {
                  final n = Get.isRegistered<NotificationsBadgeService>()
                      ? Get.find<NotificationsBadgeService>().unreadCount.value
                      : 0;
                  if (n <= 0) return const SizedBox.shrink();
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.critical,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dark full-width hero card with a lime CTA and page dots.
class _BannerCarousel extends StatefulWidget {
  final List<HomeBanner> banners;
  final ValueChanged<HomeBanner> onTap;
  const _BannerCarousel({required this.banners, required this.onTap});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  final _pager = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pager,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final b = banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
                child: GestureDetector(
                  onTap: () => widget.onTap(b),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PrototypeImage(
                          source: b.imageUrl,
                          fontSize: 32,
                          borderRadius: BorderRadius.zero,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [AppColors.heroScrim, Color(0x6614160E)],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.onBrand,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if ((b.subtitle ?? '').isNotEmpty) ...[
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 220,
                                  child: Text(
                                    b.subtitle!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.onBrand.withValues(
                                        alpha: 0.85,
                                      ),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Shop Now',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.onAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (banners.length > 1)
            Positioned(
              right: AppSpace.md + 16,
              bottom: 20,
              child: Row(
                children: [
                  for (var i = 0; i < banners.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 4),
                      width: i == _page ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? AppColors.accent
                            : AppColors.onBrand,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Three white tiles (icon in a soft circle + label).
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final items = [
      (IconsaxPlusLinear.category, 'Categories', () => _goToTab(1)),
      (IconsaxPlusLinear.receipt_2, 'My Orders', () => _goToTab(2)),
      (
        IconsaxPlusLinear.heart,
        'Wishlist',
        () => Get.toNamed(AppRoutes.wishlist),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.md,
        AppSpace.md,
        AppSpace.md,
        0,
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: items[i].$3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.surface2,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            items[i].$1,
                            size: 20,
                            color: AppColors.brand,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          items[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.ink,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pill chips, first one filled olive — the design's "All Vendors" row.
class _CategoryChips extends StatelessWidget {
  final List<Category> categories;
  const _CategoryChips({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final all = i == 0;
          final c = all ? null : categories[i - 1];
          return Material(
            color: all ? AppColors.brand : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: all
                  ? () => _goToTab(1)
                  : () => Get.toNamed(
                      AppRoutes.results,
                      arguments: {'category_id': c!.id, 'title': c.name},
                    ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  child: Text(
                    all ? 'All Categories' : c!.name,
                    style: AppTextStyles.label.copyWith(
                      color: all ? AppColors.onBrand : AppColors.ink,
                      fontWeight: all ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
          mainAxisExtent: 262,
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
      height: 270,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
        itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpace.sm),
            child: SizedBox(
              width: 156,
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

/// Vendor rows: square thumb, tag, rating, name, location, bookmark.
class _SellerList extends StatelessWidget {
  final List sellers;
  const _SellerList({required this.sellers});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
      child: Column(
        children: [
          for (final s in sellers) ...[
            _SellerTile(seller: s),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SellerTile extends StatelessWidget {
  final dynamic seller;
  const _SellerTile({required this.seller});

  @override
  Widget build(BuildContext context) {
    final name = '${seller['name'] ?? ''}';
    final city = '${seller['city'] ?? ''}';
    final rating = double.tryParse('${seller['rating'] ?? ''}') ?? 0;
    final logo = seller['logo'] ?? seller['image'];
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.seller,
          arguments: {'vendorId': seller['id']},
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              logo is String && logo.isNotEmpty
                  ? PrototypeImage(
                      source: logo,
                      size: 72,
                      borderRadius: BorderRadius.circular(AppRadius.image),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.brandSoft,
                        borderRadius: BorderRadius.circular(AppRadius.image),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name.isEmpty
                            ? '?'
                            : name.characters.first.toUpperCase(),
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.brand,
                        ),
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const PillBadge(label: 'Seller'),
                        const Spacer(),
                        if (rating > 0) RatingPill(rating: rating),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          IconsaxPlusLinear.location,
                          size: 14,
                          color: AppColors.ink3,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            city,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ),
                        const Icon(
                          IconsaxPlusLinear.arrow_right_3,
                          size: 16,
                          color: AppColors.ink3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
