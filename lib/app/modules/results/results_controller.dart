import 'package:get/get.dart';
import '../../data/models/paginated.dart';
import '../../data/models/product.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../shared/utils/cfo_toast.dart';

class ResultsController extends GetxController {
  final CatalogRepository _repo = Get.find<CatalogRepository>();

  String? q;
  int? categoryId;
  String title = 'Results';

  final RxList<ProductCardModel> products = <ProductCardModel>[].obs;
  final RxBool loading = true.obs;
  final RxBool loadingMore = false.obs;
  int _page = 1;
  Paginated<ProductCardModel>? _lastPage;

  final RxString sort = 'relevance'.obs;
  final Rxn<double> minPriceR = Rxn<double>();
  final Rxn<double> maxPriceR = Rxn<double>();
  final Rxn<double> minRatingR = Rxn<double>();
  final Rxn<double> minDiscountR = Rxn<double>();
  final Rxn<int> vendorIdR = Rxn<int>();
  final RxBool assuredOnly = false.obs;
  final RxBool codOnly = false.obs;
  final RxBool inStockOnly = false.obs;
  final RxMap<String, dynamic> facets = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      q = args['q'];
      categoryId = args['category_id'];
      title = args['title'] ?? args['q'] ?? 'Results';
      if (args['sort'] is String) {
        sort.value = switch (args['sort']) {
          'price_low' => 'low',
          'price_high' => 'high',
          final v => v,
        };
      }
    }
    load();
    loadFilters();
  }

  Future<void> load() async {
    loading.value = products.isEmpty;
    _page = 1;
    try {
      _lastPage = await _repo.products(
        q: q,
        categoryId: categoryId,
        minPrice: minPriceR.value,
        maxPrice: maxPriceR.value,
        minRating: minRatingR.value,
        minDiscount: minDiscountR.value,
        vendorId: vendorIdR.value,
        assured: assuredOnly.value ? true : null,
        cod: codOnly.value ? true : null,
        inStock: inStockOnly.value ? true : null,
        sort: sort.value,
        page: _page,
      );
      products.assignAll(_lastPage!.data);
    } catch (e) {
      CfoToast.error('Could not load products. Please try again.');
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadFilters() async {
    try {
      facets.assignAll(
        await _repo.productFilters(
          q: q,
          categoryId: categoryId,
          minPrice: minPriceR.value,
          maxPrice: maxPriceR.value,
          minRating: minRatingR.value,
          minDiscount: minDiscountR.value,
          vendorId: vendorIdR.value,
          assured: assuredOnly.value ? true : null,
          cod: codOnly.value ? true : null,
          inStock: inStockOnly.value ? true : null,
          sort: sort.value,
        ),
      );
    } catch (e) {
      CfoToast.error('Could not load filters.');
    }
  }

  Future<void> loadMore() async {
    if (loadingMore.value || _lastPage == null || !_lastPage!.hasMore) return;
    loadingMore.value = true;
    try {
      _page++;
      final page = await _repo.products(
        q: q,
        categoryId: categoryId,
        minPrice: minPriceR.value,
        maxPrice: maxPriceR.value,
        minRating: minRatingR.value,
        minDiscount: minDiscountR.value,
        vendorId: vendorIdR.value,
        assured: assuredOnly.value ? true : null,
        cod: codOnly.value ? true : null,
        inStock: inStockOnly.value ? true : null,
        sort: sort.value,
        page: _page,
      );
      _lastPage = page;
      products.addAll(page.data);
    } catch (e) {
      CfoToast.error('Could not load more products.');
      _page--;
    } finally {
      loadingMore.value = false;
    }
  }

  void applySort(String s) {
    sort.value = s;
    load();
    loadFilters();
  }

  void applyFilters({
    double? minP,
    double? maxP,
    double? minRating,
    double? minDiscount,
    int? vendorId,
    bool? assured,
    bool? cod,
    bool? inStock,
  }) {
    minPriceR.value = minP;
    maxPriceR.value = maxP;
    minRatingR.value = minRating;
    minDiscountR.value = minDiscount;
    vendorIdR.value = vendorId;
    assuredOnly.value = assured ?? false;
    codOnly.value = cod ?? false;
    inStockOnly.value = inStock ?? false;
    load();
    loadFilters();
  }

  void clearFilters() {
    minPriceR.value = null;
    maxPriceR.value = null;
    minRatingR.value = null;
    minDiscountR.value = null;
    vendorIdR.value = null;
    assuredOnly.value = false;
    codOnly.value = false;
    inStockOnly.value = false;
    load();
    loadFilters();
  }

  int get activeFilterCount {
    return [
      maxPriceR.value,
      minRatingR.value,
      minDiscountR.value,
      vendorIdR.value,
      assuredOnly.value ? true : null,
      codOnly.value ? true : null,
      inStockOnly.value ? true : null,
    ].where((value) => value != null).length;
  }
}
