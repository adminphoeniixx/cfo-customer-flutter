import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/product.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../routes/app_routes.dart';
import '../../shared/utils/cfo_toast.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/rating_pill.dart';
import '../../shared/widgets/cfo_app_bar.dart';

class SellerView extends StatefulWidget {
  const SellerView({super.key});

  @override
  State<SellerView> createState() => _SellerViewState();
}

class _SellerViewState extends State<SellerView> {
  final _catalog = Get.find<CatalogRepository>();
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final vendorId = args is Map ? args['vendorId'] : null;
    if (vendorId != null) {
      _load(vendorId is int ? vendorId : int.tryParse('$vendorId') ?? 0);
    }
  }

  Future<void> _load(int id) async {
    setState(() => loading = data == null);
    try {
      data = await _catalog.seller(id);
    } catch (e) {
      CfoToast.error('$e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final vendor = Map<String, dynamic>.from(data?['vendor'] ?? {});
    final productsData = (data?['products']?['data'] as List? ?? [])
        .map((e) => ProductCardModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return Scaffold(
      appBar: CfoAppBar(title: '${vendor['name'] ?? 'Seller'}'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.md),
            decoration: BoxDecoration(
              color: AppColors.brandSoft,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${vendor['name'] ?? ''}',
                        style: AppTextStyles.h2,
                      ),
                    ),
                    if (vendor['rating'] != null)
                      RatingPill(
                        rating: double.tryParse('${vendor['rating']}') ?? 0,
                      ),
                  ],
                ),
                if (vendor['city'] != null)
                  Text('${vendor['city']}', style: AppTextStyles.caption),
                if (vendor['description'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${vendor['description']}',
                      style: AppTextStyles.body,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${vendor['products_count'] ?? productsData.length} products · since ${vendor['since'] ?? ''}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpace.sm,
              crossAxisSpacing: AppSpace.sm,
              mainAxisExtent: 240,
            ),
            itemCount: productsData.length,
            itemBuilder: (context, i) {
              final p = productsData[i];
              return ProductCard(
                product: p,
                onTap: () => Get.toNamed(
                  AppRoutes.productDetail,
                  arguments: {'idOrSlug': p.slug},
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
