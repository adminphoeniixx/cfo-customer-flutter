import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/notifications_badge_service.dart';
import '../../core/auth/wishlist_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/category.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/cfo_app_bar.dart';
import '../../shared/widgets/prototype_image.dart';
import 'categories_controller.dart';

/// A vertical list grouped by top-level category, each with a "Shop all"
/// link and its children as tappable rows — matches the prototype's
/// `categories()` screen (a stack of `.sect` + `.card.flat` rows), not a
/// two-pane rail/grid browser.
class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CategoriesController>()) {
      Get.put(CategoriesController());
    }
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
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.categories.isEmpty) {
          return const Center(child: Text('No categories yet.'));
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: AppSpace.xl),
            itemCount: controller.categories.length,
            itemBuilder: (context, i) =>
                _ParentSection(parent: controller.categories[i]),
          ),
        );
      }),
    );
  }
}

class _ParentSection extends StatelessWidget {
  final Category parent;
  const _ParentSection({required this.parent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.md,
            AppSpace.md,
            AppSpace.sm,
            AppSpace.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(parent.name, style: AppTextStyles.title),
              TextButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.results,
                  arguments: {'category_id': parent.id, 'title': parent.name},
                ),
                child: const Text(
                  'Shop all',
                  style: TextStyle(
                    color: AppColors.brand,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpace.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: parent.children.isEmpty
              ? _ChildRow(
                  name: 'All ${parent.name}',
                  image: parent.image,
                  onTap: () => Get.toNamed(
                    AppRoutes.results,
                    arguments: {'category_id': parent.id, 'title': parent.name},
                  ),
                  showDivider: false,
                )
              : Column(
                  children: [
                    for (int i = 0; i < parent.children.length; i++)
                      _ChildRow(
                        name: parent.children[i].name,
                        image: parent.children[i].image,
                        onTap: () => Get.toNamed(
                          AppRoutes.results,
                          arguments: {
                            'category_id': parent.children[i].id,
                            'title': parent.children[i].name,
                          },
                        ),
                        showDivider: i < parent.children.length - 1,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ChildRow extends StatelessWidget {
  final String name;
  final String? image;
  final VoidCallback onTap;
  final bool showDivider;
  const _ChildRow({
    required this.name,
    this.image,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: showDivider
            ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.lineSoft)),
              )
            : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.sm + 2,
        ),
        child: Row(
          children: [
            PrototypeImage(source: image, size: 44, fontSize: 22),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.ink,
                  fontSize: 13.5,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}
