import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/prototype_image.dart';
import 'search_controller.dart' as local;

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(local.AppSearchController());
    final textCtrl = TextEditingController();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Material(
          color: AppColors.chrome,
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Get.back(),
                      child: SizedBox(
                        width: 34,
                        height: 34,
                        child: Center(
                          child: Text(
                            '‹',
                            style: TextStyle(
                              fontSize: 26,
                              color: AppColors.chromeInk,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.ink.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            AppIcon(
                              AppSvgIcons.search,
                              size: 17,
                              color: AppColors.ink3,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: textCtrl,
                                autofocus: true,
                                style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 13.5,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Search products, brands…',
                                  hintStyle: TextStyle(
                                    color: AppColors.ink3,
                                    fontSize: 13.5,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: controller.onQueryChanged,
                                onSubmitted: (q) => Get.toNamed(
                                  AppRoutes.results,
                                  arguments: {'q': q, 'title': q},
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.suggestions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppSpace.md),
            child: Text(
              'Type at least 2 characters to search.',
              style: TextStyle(color: AppColors.ink3),
            ),
          );
        }
        return ListView.separated(
          itemCount: controller.suggestions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final p = controller.suggestions[i];
            return ListTile(
              leading: PrototypeImage(source: p.image, size: 44, fontSize: 22),
              title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: p.brand == null ? null : Text(p.brand!),
              onTap: () => Get.toNamed(
                AppRoutes.productDetail,
                arguments: {'idOrSlug': p.slug},
              ),
            );
          },
        );
      }),
    );
  }
}
