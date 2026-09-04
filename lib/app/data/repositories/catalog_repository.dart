import 'package:get/get.dart';
import '../../core/cache/cache_service.dart';
import '../../core/network/api_client.dart';
import '../models/category.dart';
import '../models/paginated.dart';
import '../models/product.dart';
import '../models/reference.dart';
import '../models/review.dart';

/// Everything under "browsing" — no token required, but sends one when
/// present so cards gain `is_wishlisted`.
class CatalogRepository {
  final ApiClient _api = Get.find<ApiClient>();
  final _cache = CacheService.instance;

  Future<Map<String, dynamic>> home() => _cache.getOrFetch(
    'home',
    () async => Map<String, dynamic>.from((await _api.get('/home')).data),
    ttl: const Duration(minutes: 5),
  );

  Future<List<Category>> categories() =>
      _cache.getOrFetch('categories', () async {
        final res = await _api.get('/categories');
        return (res.data['data'] as List)
            .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }, ttl: const Duration(minutes: 15));

  Future<Paginated<ProductCardModel>> products({
    String? q,
    int? categoryId,
    int? vendorId,
    String? brand,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? minDiscount,
    bool? assured,
    bool? cod,
    bool? inStock,
    String? sort,
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await _api.get(
      '/products',
      query: {
        'q': q,
        'category_id': categoryId,
        'vendor_id': vendorId,
        'brand': brand,
        'min_price': minPrice,
        'max_price': maxPrice,
        'min_rating': minRating,
        'min_discount': minDiscount,
        'assured': assured == true ? 1 : null,
        'cod': cod == true ? 1 : null,
        'in_stock': inStock == true ? 1 : null,
        'sort': switch (sort) {
          'low' => 'price_low',
          'high' => 'price_high',
          final value => value,
        },
        'page': page,
        'per_page': perPage,
      },
    );
    return Paginated.fromJson(
      Map<String, dynamic>.from(res.data),
      ProductCardModel.fromJson,
    );
  }

  Future<Map<String, dynamic>> productFilters({
    String? q,
    int? categoryId,
    int? vendorId,
    String? brand,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? minDiscount,
    bool? assured,
    bool? cod,
    bool? inStock,
    String? sort,
  }) async {
    final res = await _api.get(
      '/products/filters',
      query: {
        'q': q,
        'category_id': categoryId,
        'vendor_id': vendorId,
        'brand': brand,
        'min_price': minPrice,
        'max_price': maxPrice,
        'min_rating': minRating,
        'min_discount': minDiscount,
        'assured': assured == true ? 1 : null,
        'cod': cod == true ? 1 : null,
        'in_stock': inStock == true ? 1 : null,
        'sort': switch (sort) {
          'low' => 'price_low',
          'high' => 'price_high',
          final value => value,
        },
      },
    );
    return Map<String, dynamic>.from(res.data['data'] ?? res.data);
  }

  Future<List<ProductCardModel>> suggestions(String q) async {
    if (q.trim().length < 2) return [];
    final res = await _api.get('/products/suggestions', query: {'q': q});
    final list = (res.data['data'] ?? res.data) as List;
    return list
        .map((e) => ProductCardModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ProductDetail> product(String idOrSlug) async {
    final res = await _api.get('/products/$idOrSlug');
    return ProductDetail.fromJson(Map<String, dynamic>.from(res.data['data']));
  }

  Future<Paginated<Review>> productReviews(
    int productId, {
    int page = 1,
  }) async {
    final res = await _api.get(
      '/products/$productId/reviews',
      query: {'page': page},
    );
    return Paginated.fromJson(
      Map<String, dynamic>.from(res.data),
      Review.fromJson,
    );
  }

  Future<Map<String, dynamic>> seller(int vendorId) async {
    final res = await _api.get('/sellers/$vendorId');
    return Map<String, dynamic>.from(res.data);
  }

  Future<ReferenceData> reference() => _cache.getOrFetch('reference', () async {
    final res = await _api.get('/reference');
    return ReferenceData.fromJson(Map<String, dynamic>.from(res.data));
  }, ttl: const Duration(hours: 1));
}
