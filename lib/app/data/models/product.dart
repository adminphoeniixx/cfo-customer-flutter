import '../../core/utils/json_utils.dart';

/// Lightweight vendor reference as embedded in a product card / cart line.
class VendorRef {
  final int id;
  final String name;
  VendorRef({required this.id, required this.name});
  factory VendorRef.fromJson(Map<String, dynamic> j) =>
      VendorRef(id: asInt(j['id']), name: asString(j['name']));
}

class ProductImage {
  final int id;
  final String url;
  final String? alt;
  ProductImage({required this.id, required this.url, this.alt});
  factory ProductImage.fromJson(Map<String, dynamic> j) => ProductImage(
    id: asInt(j['id']),
    url: asString(j['url'] ?? j['emoji'] ?? j['icon']),
    alt: j['alt'],
  );
}

/// One attribute (Size, Colour) with its selectable values — drives pickers.
class ProductOption {
  final String name;
  final List<ProductOptionValue> values;
  ProductOption({required this.name, required this.values});
  factory ProductOption.fromJson(Map<String, dynamic> j) => ProductOption(
    name: asString(j['name']),
    values: (j['values'] as List? ?? [])
        .map((e) => ProductOptionValue.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}

class ProductOptionValue {
  final String value;
  final bool inStock;
  ProductOptionValue({required this.value, required this.inStock});
  factory ProductOptionValue.fromJson(Map<String, dynamic> j) =>
      ProductOptionValue(
        value: asString(j['value']),
        inStock: asBool(j['in_stock'], true),
      );
}

/// A concrete buyable combination — its own price and stock.
class ProductVariant {
  final int id;
  final Map<String, String> options; // e.g. {"Size": "M", "Colour": "Red"}
  final double price;
  final double? mrp;
  final bool inStock;
  final int? stockQuantity;
  final String? sku;
  final String? image;

  ProductVariant({
    required this.id,
    required this.options,
    required this.price,
    this.mrp,
    required this.inStock,
    this.stockQuantity,
    this.sku,
    this.image,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> j) => ProductVariant(
    id: asInt(j['id']),
    options: (j['options'] as Map? ?? {}).map(
      (k, v) => MapEntry(k.toString(), v.toString()),
    ),
    price: asDouble(j['price']),
    mrp: j['mrp'] == null ? null : asDouble(j['mrp']),
    inStock: asBool(j['in_stock'], true),
    stockQuantity: j['stock_quantity'] == null
        ? null
        : asInt(j['stock_quantity']),
    sku: j['sku'],
    image: j['image'] ?? j['emoji'] ?? j['icon'],
  );
}

/// Compact card shape — used in listings, search, home sections, wishlist.
class ProductCardModel {
  final int id;
  final String name;
  final String slug;
  final String? brand;
  final String? image;
  final double price;
  final double? mrp;
  final int discountPercent;
  final double rating;
  final int ratingsCount;
  final bool inStock;
  final bool assured;
  final bool codAvailable;
  final VendorRef? vendor;
  final bool? isWishlisted; // absent (null) when unauthenticated

  ProductCardModel({
    required this.id,
    required this.name,
    required this.slug,
    this.brand,
    this.image,
    required this.price,
    this.mrp,
    required this.discountPercent,
    required this.rating,
    required this.ratingsCount,
    required this.inStock,
    this.assured = false,
    this.codAvailable = false,
    this.vendor,
    this.isWishlisted,
  });

  factory ProductCardModel.fromJson(Map<String, dynamic> j) => ProductCardModel(
    id: asInt(j['id']),
    name: asString(j['name']),
    slug: asString(j['slug']),
    brand: j['brand'],
    image: j['image'],
    price: asDouble(j['price']),
    mrp: j['mrp'] == null ? null : asDouble(j['mrp']),
    discountPercent: asInt(j['discount_percent']),
    rating: asDouble(j['rating']),
    ratingsCount: asInt(j['ratings_count']),
    inStock: asBool(j['in_stock'], true),
    assured: asBool(j['assured'], false),
    codAvailable: asBool(j['cod_available'] ?? j['cod']),
    vendor: j['vendor'] == null
        ? null
        : VendorRef.fromJson(Map<String, dynamic>.from(j['vendor'])),
    isWishlisted: j.containsKey('is_wishlisted')
        ? asBool(j['is_wishlisted'])
        : null,
  );
}

class ProductCategoryRef {
  final int id;
  final String name;
  final String slug;
  ProductCategoryRef({
    required this.id,
    required this.name,
    required this.slug,
  });
  factory ProductCategoryRef.fromJson(Map<String, dynamic> j) =>
      ProductCategoryRef(
        id: asInt(j['id']),
        name: asString(j['name']),
        slug: asString(j['slug']),
      );
}

class ProductVendorRef {
  final int id;
  final String name;
  final String? city;
  final double? rating;
  ProductVendorRef({
    required this.id,
    required this.name,
    this.city,
    this.rating,
  });
  factory ProductVendorRef.fromJson(Map<String, dynamic> j) => ProductVendorRef(
    id: asInt(j['id']),
    name: asString(j['name']),
    city: j['city'],
    rating: j['rating'] == null ? null : asDouble(j['rating']),
  );
}

/// Full product-page shape.
class ProductDetail {
  final int id;
  final String name;
  final String slug;
  final String? sku;
  final String? brand;
  final String type; // "simple" | "variable"
  final String? shortDescription;
  final String? description;
  final double price;
  final double? mrp;
  final int discountPercent;
  final double? taxRate;
  final double rating;
  final int ratingsCount;
  final List<int> ratingBreakdown;
  final bool inStock;
  final String? stockStatus;
  final int? stockQuantity;
  final bool requiresShipping;
  final List<String> tags;
  final List<ProductImage> images;
  final ProductCategoryRef? category;
  final ProductVendorRef? vendor;
  final Map<String, dynamic> specifications;
  final List<ProductOption> options;
  final List<ProductVariant> variants;
  final bool? isWishlisted;

  ProductDetail({
    required this.id,
    required this.name,
    required this.slug,
    this.sku,
    this.brand,
    required this.type,
    this.shortDescription,
    this.description,
    required this.price,
    this.mrp,
    required this.discountPercent,
    this.taxRate,
    required this.rating,
    required this.ratingsCount,
    required this.ratingBreakdown,
    required this.inStock,
    this.stockStatus,
    this.stockQuantity,
    required this.requiresShipping,
    required this.tags,
    required this.images,
    this.category,
    this.vendor,
    required this.specifications,
    required this.options,
    required this.variants,
    this.isWishlisted,
  });

  bool get isVariable => type == 'variable';

  factory ProductDetail.fromJson(Map<String, dynamic> j) => ProductDetail(
    id: asInt(j['id']),
    name: asString(j['name']),
    slug: asString(j['slug']),
    sku: j['sku'],
    brand: j['brand'],
    type: asString(j['type'], 'simple'),
    shortDescription: j['short_description'],
    description: j['description'],
    price: asDouble(j['price']),
    mrp: j['mrp'] == null ? null : asDouble(j['mrp']),
    discountPercent: asInt(j['discount_percent']),
    taxRate: j['tax_rate'] == null ? null : asDouble(j['tax_rate']),
    rating: asDouble(j['rating']),
    ratingsCount: asInt(j['ratings_count']),
    ratingBreakdown: (j['rating_breakdown'] as List? ?? [])
        .map((e) => asInt(e))
        .toList(),
    inStock: asBool(j['in_stock'], true),
    stockStatus: j['stock_status'],
    stockQuantity: j['stock_quantity'] == null
        ? null
        : asInt(j['stock_quantity']),
    requiresShipping: asBool(j['requires_shipping'], true),
    tags: (j['tags'] as List? ?? []).map((e) => e.toString()).toList(),
    images: (j['images'] as List? ?? [])
        .map((e) => ProductImage.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    category: j['category'] == null
        ? null
        : ProductCategoryRef.fromJson(Map<String, dynamic>.from(j['category'])),
    vendor: j['vendor'] == null
        ? null
        : ProductVendorRef.fromJson(Map<String, dynamic>.from(j['vendor'])),
    specifications: Map<String, dynamic>.from(j['specifications'] ?? {}),
    options: (j['options'] as List? ?? [])
        .map((e) => ProductOption.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    variants: (j['variants'] as List? ?? [])
        .map((e) => ProductVariant.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    isWishlisted: j.containsKey('is_wishlisted')
        ? asBool(j['is_wishlisted'])
        : null,
  );
}
