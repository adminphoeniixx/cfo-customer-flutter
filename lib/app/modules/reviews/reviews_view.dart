import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/account_badge_service.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/paginated.dart';
import '../../data/models/review.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../shared/utils/cfo_toast.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/rating_pill.dart';
import '../../shared/widgets/cfo_app_bar.dart';

/// Published reviews for one product, with a "write a review" entry point
/// for buyers of a delivered order.
class ReviewsView extends StatefulWidget {
  const ReviewsView({super.key});

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  late int productId;
  late String productName;
  final _catalog = Get.find<CatalogRepository>();
  Paginated<Review>? page;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    productId = args is Map ? asIntArg(args['productId']) : 0;
    productName = args is Map ? (args['productName'] ?? 'Product') : 'Product';
    _load();
  }

  int asIntArg(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  Future<void> _load() async {
    setState(() => loading = page == null);
    try {
      page = await _catalog.productReviews(productId);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CfoAppBar(title: 'Reviews · $productName'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWriteReview(context),
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Write a review'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (page == null || page!.data.isEmpty)
          ? const EmptyState(
              icon: Icons.rate_review_outlined,
              title: 'No reviews yet',
              message: 'Be the first to review this product.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpace.md),
                itemCount: page!.data.length,
                separatorBuilder: (_, index) => const Divider(),
                itemBuilder: (context, i) {
                  final r = page!.data[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RatingPill(rating: r.rating.toDouble()),
                          const SizedBox(width: 8),
                          Text(
                            r.author,
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (r.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.blue,
                            ),
                          ],
                          const Spacer(),
                          Text(
                            formatDate(r.createdAt),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      if (r.title != null && r.title!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            r.title!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      if (r.body != null && r.body!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(r.body!, style: AppTextStyles.body),
                        ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  void _openWriteReview(BuildContext context) {
    int rating = 5;
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpace.md,
          right: AppSpace.md,
          top: AppSpace.md,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rate this product', style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(
                    5,
                    (i) => IconButton(
                      onPressed: () => setSheetState(() => rating = i + 1),
                      icon: Icon(
                        i < rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Title (optional)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Share details of your experience',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await Get.find<AccountRepository>().writeReview(
                          productId,
                          rating: rating,
                          title: titleCtrl.text,
                          body: bodyCtrl.text,
                        );
                        if (context.mounted) Navigator.pop(context);
                        CfoToast.success('Thanks - your review is live');
                        _load();
                        if (Get.isRegistered<AccountBadgeService>()) {
                          Get.find<AccountBadgeService>().refresh();
                        }
                      } catch (e) {
                        CfoToast.error('$e');
                      }
                    },
                    child: const Text('Submit review'),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
              ],
            );
          },
        ),
      ),
    );
  }
}
