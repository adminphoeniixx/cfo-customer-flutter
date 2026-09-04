import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/wishlist_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/cfo_app_bar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/product_card.dart';
import 'results_controller.dart';

class ResultsView extends GetView<ResultsController> {
  const ResultsView({super.key});

  static const _sortOptions = {
    'relevance': 'Popularity',
    'low': 'Price: low to high',
    'high': 'Price: high to low',
    'rating': 'Customer rating',
    'discount': 'Discount',
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ResultsController(),
      tag: UniqueKey().toString(),
    );
    final scroll = ScrollController();
    scroll.addListener(() {
      if (scroll.position.pixels > scroll.position.maxScrollExtent - 300) {
        controller.loadMore();
      }
    });
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Obx(
          () => CfoAppBar(
            title: controller.title,
            subtitle:
                '${controller.products.length} product${controller.products.length == 1 ? '' : 's'}',
            actions: [
              CfoAppBarAction(
                icon: AppSvgIcons.heart,
                tooltip: 'Wishlist',
                badgeCount: () => Get.find<WishlistService>().ids.length,
                onTap: () => Get.toNamed(AppRoutes.wishlist),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(
            () => _Toolbar(
              controller: controller,
              sortKey: controller.sort.value,
              activeFilterCount: controller.activeFilterCount,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.products.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No products match',
                  message:
                      'Try clearing a filter, or widening the price range.',
                  actionLabel: 'Clear filters',
                  onAction: controller.clearFilters,
                );
              }
              return GridView.builder(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 250,
                ),
                itemCount: controller.products.length,
                itemBuilder: (context, i) {
                  final p = controller.products[i];
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
              );
            }),
          ),
        ],
      ),
    );
  }

  static String sortLabel(String key) => _sortOptions[key] ?? 'Popularity';
}

class _Toolbar extends StatelessWidget {
  final ResultsController controller;
  final String sortKey;
  final int activeFilterCount;

  const _Toolbar({
    required this.controller,
    required this.sortKey,
    required this.activeFilterCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToolbarButton(
              label: '↕ ${ResultsView.sortLabel(sortKey)}',
              onTap: () => _openSort(context, controller),
            ),
          ),
          Container(width: 1, color: AppColors.line),
          Expanded(
            child: _ToolbarButton(
              label:
                  '⚙ Filters${activeFilterCount > 0 ? ' · $activeFilterCount' : ''}',
              active: activeFilterCount > 0,
              onTap: () => _openFilters(context, controller),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: active ? AppColors.action : AppColors.ink2,
        padding: const EdgeInsets.all(12),
        textStyle: AppTextStyles.bodyMedium.copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
        shape: const RoundedRectangleBorder(),
      ),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

void _openSort(BuildContext context, ResultsController controller) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _SheetPanel(
        title: 'Sort by',
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in _sortEntries(controller))
                _OptionRow(
                  title: entry.$2,
                  selected: controller.sort.value == entry.$1,
                  onTap: () {
                    controller.applySort(entry.$1);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

void _openFilters(BuildContext context, ResultsController controller) {
  controller.loadFilters();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _SheetPanel(
        title: 'Filters',
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FilterTitle('Price'),
              _ChipRow(
                children: [
                  for (final item in _facetList(controller, 'price_ranges'))
                    _FilterChipButton(
                      label: _facetLabel(item),
                      selected:
                          controller.maxPriceR.value == _asDouble(item['max_price']),
                      onTap: () {
                        final max = _asDouble(item['max_price']);
                        controller.maxPriceR.value =
                            controller.maxPriceR.value == max ? null : max;
                      },
                    ),
                ],
              ),
              const _FilterTitle('Customer rating'),
              _ChipRow(
                children: [
                  for (final item in _facetList(controller, 'rating_ranges'))
                    _FilterChipButton(
                      label: _facetLabel(item),
                      selected:
                          controller.minRatingR.value == _asDouble(item['min_rating']),
                      onTap: () {
                        final min = _asDouble(item['min_rating']);
                        controller.minRatingR.value =
                            controller.minRatingR.value == min ? null : min;
                      },
                    ),
                ],
              ),
              const _FilterTitle('Discount'),
              _ChipRow(
                children: [
                  for (final item in _facetList(controller, 'discount_ranges'))
                    _FilterChipButton(
                      label: _facetLabel(item),
                      selected:
                          controller.minDiscountR.value ==
                          _asDouble(item['min_discount']),
                      onTap: () {
                        final min = _asDouble(item['min_discount']);
                        controller.minDiscountR.value =
                            controller.minDiscountR.value == min ? null : min;
                      },
                    ),
                ],
              ),
              const _FilterTitle('Seller'),
              _ChipRow(
                children: [
                  for (final seller in _facetList(controller, 'sellers'))
                    _FilterChipButton(
                      label: _facetLabel(seller),
                      selected: controller.vendorIdR.value == _asInt(seller['id']),
                      onTap: () {
                        final id = _asInt(seller['id']);
                        controller.vendorIdR.value =
                            controller.vendorIdR.value == id ? null : id;
                      },
                    ),
                ],
              ),
              _OptionRow(
                title: 'CFO Assured only',
                subtitle: 'Checked by us before it ships',
                selected: controller.assuredOnly.value,
                square: true,
                onTap: () => controller.assuredOnly.value =
                    !controller.assuredOnly.value,
              ),
              _OptionRow(
                title: 'Cash on delivery',
                selected: controller.codOnly.value,
                square: true,
                onTap: () =>
                    controller.codOnly.value = !controller.codOnly.value,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SheetButton(
                      label: 'Clear all',
                      ghost: true,
                      onTap: controller.clearFilters,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _SheetButton(
                      label:
                          'Show ${controller.products.length} result${controller.products.length == 1 ? '' : 's'}',
                      onTap: () {
                        controller.load();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

List<(String, String)> _sortEntries(ResultsController controller) {
  final list = _facetList(controller, 'sorts');
  if (list.isEmpty) {
    return ResultsView._sortOptions.entries
        .map((e) => (e.key, e.value))
        .toList();
  }
  return list.map((item) {
    final raw = '${item['value'] ?? item['key'] ?? ''}';
    final key = switch (raw) {
      'price_low' => 'low',
      'price_high' => 'high',
      final value => value,
    };
    return (key, _facetLabel(item));
  }).where((item) => item.$1.isNotEmpty && item.$2.isNotEmpty).toList();
}

List<Map<String, dynamic>> _facetList(
  ResultsController controller,
  String key,
) {
  final value = controller.facets[key];
  if (value is! List) return const [];
  return value.map((e) => Map<String, dynamic>.from(e as Map)).toList();
}

String _facetLabel(Map<String, dynamic> item) {
  final count = _asInt(item['count']) ?? 0;
  final label = '${item['label'] ?? item['name'] ?? item['title'] ?? ''}';
  if (count <= 0) return label;
  return '$label ($count)';
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse('$value');
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse('$value');
}

class _SheetPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetPanel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.h3.copyWith(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 22),
                    color: AppColors.ink,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 36,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final bool square;
  final VoidCallback onTap;

  const _OptionRow({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.square = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.lineSoft)),
        ),
        child: Row(
          children: [
            _SelectionMark(selected: selected, square: square),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.5,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  final bool selected;
  final bool square;

  const _SelectionMark({required this.selected, this.square = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(square ? 4 : 999),
        border: Border.all(
          color: selected ? AppColors.brand : AppColors.line,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: square ? 10 : 11,
                height: square ? 10 : 11,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(square ? 2 : 999),
                ),
              ),
            )
          : null,
    );
  }
}

class _FilterTitle extends StatelessWidget {
  final String text;

  const _FilterTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
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

class _ChipRow extends StatelessWidget {
  final List<Widget> children;

  const _ChipRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: selected ? AppColors.brand : AppColors.ink2,
        backgroundColor: selected ? AppColors.brandSoft : AppColors.surface,
        side: BorderSide(color: selected ? AppColors.brand : AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: AppTextStyles.bodyMedium.copyWith(
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: Text(label),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final bool ghost;
  final VoidCallback onTap;

  const _SheetButton({
    required this.label,
    required this.onTap,
    this.ghost = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: ghost ? AppColors.surface : AppColors.brand,
          foregroundColor: ghost ? AppColors.action : AppColors.onBrand,
          side: BorderSide(color: ghost ? AppColors.line : AppColors.brand),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: AppTextStyles.button.copyWith(
            fontSize: 14,
            height: 1,
            letterSpacing: 0.02,
          ),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
