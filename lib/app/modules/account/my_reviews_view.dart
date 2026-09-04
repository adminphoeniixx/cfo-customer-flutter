import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/review.dart';
import '../../data/repositories/account_repository.dart';
import '../../routes/app_routes.dart';
import '../../shared/utils/cfo_toast.dart';
import '../../shared/widgets/cfo_app_bar.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/prototype_image.dart';

/// `/reviews` returns both what the shopper already wrote and delivered
/// products still waiting for a rating.
class MyReviewsView extends StatefulWidget {
  const MyReviewsView({super.key});

  @override
  State<MyReviewsView> createState() => _MyReviewsViewState();
}

class _MyReviewsViewState extends State<MyReviewsView> {
  final _repo = Get.find<AccountRepository>();
  List<Review> written = [];
  List<PendingReview> pending = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = written.isEmpty && pending.isEmpty);
    try {
      final data = await _repo.myReviews();
      written = (data['written'] as List? ?? [])
          .map((e) => Review.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      pending = (data['pending'] as List? ?? [])
          .map((e) => PendingReview.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      CfoToast.error('$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const CfoAppBar(title: 'My reviews'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              children: [
                const _SectionTitle('Waiting for your rating'),
                const SizedBox(height: 9),
                if (pending.isEmpty)
                  const EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'Nothing waiting for a review',
                  )
                else
                  _Card(
                    children: [
                      for (final p in pending)
                        _PendingRow(
                          item: p,
                          onRate: () => Get.toNamed(
                            AppRoutes.reviews,
                            arguments: {
                              'productId': p.productId,
                              'productName': p.productName,
                            },
                          )?.then((_) => _load()),
                        ),
                    ],
                  ),
                const SizedBox(height: 9),
                const _SectionTitle('Written'),
                const SizedBox(height: 9),
                if (written.isEmpty)
                  const EmptyState(
                    icon: Icons.rate_review_outlined,
                    title: 'No reviews written yet',
                  )
                else
                  _Card(
                    padded: true,
                    children: [
                      for (final r in written) _WrittenReview(review: r),
                    ],
                  ),
              ],
            ),
    );
  }
}

class _PendingRow extends StatelessWidget {
  final PendingReview item;
  final VoidCallback onRate;

  const _PendingRow({required this.item, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRate,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PrototypeImage(
              source: item.productImage ?? '🧶',
              size: 44,
              fontSize: 22,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Delivered · order ${item.orderNumber ?? '#${item.orderId}'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warnBg,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'Rate',
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.warnInk,
                  fontSize: 9.5,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WrittenReview extends StatelessWidget {
  final Review review;

  const _WrittenReview({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _RatingBadge(rating: review.rating),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.productName ?? review.title ?? 'Review',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if ((review.body ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.body!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.ink2,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTextStyles.caption.copyWith(
                fontSize: 11.5,
                height: 1.35,
              ),
              children: [
                TextSpan(text: _monthYear(review.createdAt)),
                const TextSpan(text: ' · '),
                TextSpan(
                  text: 'Edit',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.action,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final int rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$rating ★',
        style: AppTextStyles.tiny.copyWith(
          color: Colors.white,
          fontSize: 11,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  final bool padded;

  const _Card({required this.children, this.padded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padded ? const EdgeInsets.symmetric(horizontal: 12) : null,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, thickness: 1, color: AppColors.lineSoft),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _monthYear(DateTime? date) {
  if (date == null) return '';
  return DateFormat('MMM yyyy').format(date.toLocal());
}
