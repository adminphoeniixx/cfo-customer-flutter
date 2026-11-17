import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/cfo_app_bar.dart';
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
        preferredSize: const Size.fromHeight(CfoAppBar.barHeight),
        child: Material(
          color: AppColors.chrome,
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: CfoAppBar.barHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: AppIcons.back,
                      tooltip: 'Back',
                      onTap: () => Get.back(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.input),
                        ),
                        child: Row(
                          children: [
                            const AppIcon(
                              AppIcons.search,
                              size: 20,
                              color: AppColors.ink2,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: textCtrl,
                                autofocus: true,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search products, brands…',
                                  hintStyle: AppTextStyles.body.copyWith(
                                    color: AppColors.ink3,
                                    fontSize: 13.5,
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
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
