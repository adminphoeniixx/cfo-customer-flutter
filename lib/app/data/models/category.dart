import '../../core/utils/json_utils.dart';

class Category {
  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String? image;
  final bool isFeatured;
  final int? productsCount;
  final List<Category> children;

  Category({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.image,
    required this.isFeatured,
    this.productsCount,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: asInt(j['id']),
    parentId: j['parent_id'] == null ? null : asInt(j['parent_id']),
    name: asString(j['name']),
    slug: asString(j['slug']),
    image: j['image'] ?? j['emoji'] ?? j['icon'],
    isFeatured: asBool(j['is_featured']),
    productsCount: j['products_count'] == null
        ? null
        : asInt(j['products_count']),
    children: (j['children'] as List? ?? [])
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}
