import 'package:get/get.dart';
import '../../data/models/app_content.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../routes/app_routes.dart';
import '../../shared/utils/cfo_toast.dart';

class HomeController extends GetxController {
  final CatalogRepository _repo = Get.find<CatalogRepository>();

  final RxBool loading = true.obs;
  final RxString error = ''.obs;

  final RxList<Category> categories = <Category>[].obs;
  final RxList<ProductCardModel> deals = <ProductCardModel>[].obs;
  final RxList<ProductCardModel> topRated = <ProductCardModel>[].obs;
  final RxList<ProductCardModel> newArrivals = <ProductCardModel>[].obs;
  final RxList<dynamic> sellers = <dynamic>[].obs;
  final RxList<HomeBanner> banners = <HomeBanner>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value =
        categories.isEmpty &&
        deals.isEmpty &&
        topRated.isEmpty &&
        newArrivals.isEmpty &&
        sellers.isEmpty;
    error.value = '';
    try {
      final data = await _repo.home();
      categories.assignAll(
        (data['categories'] as List? ?? []).map(
          (e) => Category.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      deals.assignAll(
        (data['deals'] as List? ?? []).map(
          (e) => ProductCardModel.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      topRated.assignAll(
        (data['top_rated'] as List? ?? []).map(
          (e) => ProductCardModel.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      newArrivals.assignAll(
        (data['new_arrivals'] as List? ?? []).map(
          (e) => ProductCardModel.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
      sellers.assignAll(data['sellers'] as List? ?? []);
      final parsedBanners = (data['banners'] as List? ?? [])
          .map((e) => HomeBanner.fromJson(Map<String, dynamic>.from(e)))
          .where((b) => b.active)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      banners.assignAll(parsedBanners);
    } catch (e) {
      error.value = e.toString();
      CfoToast.error('Could not refresh home. Please try again.');
    } finally {
      loading.value = false;
    }
  }

  /// Maps a banner's app-owned `deeplink_route` to an actual app route.
  /// Currently-live rows use `category` (with `category_id`) and `products`
  /// (with `sort`) — the same navigation the category strip / section
  /// headers already use.
  void openBanner(HomeBanner banner) {
    switch (banner.deeplinkRoute) {
      case 'category':
        Get.toNamed(
          AppRoutes.results,
          arguments: {'category_id': banner.deeplinkParams['category_id']},
        );
        return;
      case 'products':
        Get.toNamed(
          AppRoutes.results,
          arguments: {'sort': banner.deeplinkParams['sort']},
        );
        return;
      default:
        CfoToast.show(banner.title);
    }
  }
}
