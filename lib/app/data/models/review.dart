import '../../core/utils/json_utils.dart';

class Review {
  final int id;
  final int productId;
  final int rating;
  final String? title;
  final String? body;
  final String author;
  final bool isVerified;
  final bool isMine;
  final DateTime? createdAt;
  final String? productName; // present on "my reviews" list
  final String? productImage;

  Review({
    required this.id,
    required this.productId,
    required this.rating,
    this.title,
    this.body,
    required this.author,
    required this.isVerified,
    required this.isMine,
    this.createdAt,
    this.productName,
    this.productImage,
  });

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: asInt(j['id']),
        productId: asInt(j['product_id']),
        rating: asInt(j['rating']),
        title: j['title'],
        body: j['body'],
        author: asString(j['author']),
        isVerified: asBool(j['is_verified']),
        isMine: asBool(j['is_mine']),
        createdAt: j['created_at'] == null ? null : DateTime.tryParse(j['created_at']),
        productName: j['product_name'] ?? j['product']?['name'],
        productImage: j['product_image'] ?? j['product']?['image'],
      );
}

/// A delivered product still waiting for the shopper's review.
class PendingReview {
  final int productId;
  final String productName;
  final String? productImage;
  final int orderId;
  final String? orderNumber;

  PendingReview({required this.productId, required this.productName, this.productImage, required this.orderId, this.orderNumber});

  factory PendingReview.fromJson(Map<String, dynamic> j) => PendingReview(
        productId: asInt(j['product_id']),
        productName: asString(j['product_name'] ?? j['name']),
        productImage: j['product_image'] ?? j['image'],
        orderId: asInt(j['order_id']),
        orderNumber: j['order_number'],
      );
}
