import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:get/get.dart';
import '../../core/auth/account_badge_service.dart';
import '../../core/auth/auth_service.dart';
import '../../core/moderation/review_moderation.dart';
import '../../core/network/app_exception.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/paginated.dart';
import '../../data/models/review.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../routes/app_routes.dart';
import '../../shared/utils/cfo_toast.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/rating_pill.dart';
import '../../shared/widgets/app_sheet.dart';
import '../../shared/widgets/app_icons.dart';
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

  List<Review> get _visible => [
    for (final r in page?.data ?? const <Review>[])
      if (r.isMine ||
          !ReviewModeration.isHidden(reviewId: r.id, author: r.author))
        r,
  ];

  @override
  Widget build(BuildContext context) {
    final reviews = _visible;
    return Scaffold(
      appBar: CfoAppBar(title: 'Reviews · $productName'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWriteReview(context),
        icon: const Icon(IconsaxPlusLinear.message_edit),
        label: const Text('Write a review'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
          ? const EmptyState(
              icon: IconsaxPlusLinear.message_edit,
              title: 'No reviews yet',
              message: 'Be the first to review this product.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpace.md),
                itemCount: reviews.length,
                separatorBuilder: (_, index) => const Divider(),
                itemBuilder: (context, i) {
                  final r = reviews[i];
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
                              IconsaxPlusBold.verify,
                              size: 14,
                              color: AppColors.brand,
                            ),
                          ],
                          const Spacer(),
                          Text(
                            formatDate(r.createdAt),
                            style: AppTextStyles.caption,
                          ),
                          if (!r.isMine)
                            _ReviewMenu(
                              onReport: () => _report(r),
                              onBlock: () => _block(r),
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

  Future<void> _report(Review r) async {
    if (!Get.find<AuthService>().isLoggedIn.value) {
      CfoToast.show('Sign in to report a review.');
      Get.toNamed(AppRoutes.login);
      return;
    }
    final message = await _ReportSheet.show(
      onSubmit: (reason, details) => Get.find<AccountRepository>()
          .reportReview(r.id, reason: reason, details: details),
    );
    if (message == null) return;
    await ReviewModeration.hideReview(r.id);
    setState(() {});
    CfoToast.success(message);
  }

  Future<void> _block(Review r) async {
    final ok = await AppDialog.confirm(
      title: 'Block ${r.author}?',
      message: "You won't see reviews from ${r.author} any more.",
      confirmLabel: 'Block',
      destructive: true,
    );
    if (ok != true) return;
    await ReviewModeration.blockAuthor(r.author);
    setState(() {});
    CfoToast.success('${r.author} is blocked');
  }

  void _openWriteReview(BuildContext context) {
    int rating = 5;
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    AppSheet.show(
      context: context,
      title: 'Rate this product',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => IconButton(
                    onPressed: () => setSheetState(() => rating = i + 1),
                    icon: Icon(
                      i < rating
                          ? AppIcons.star
                          : AppIcons.starOutline,
                      color: AppColors.brand,
                      size: 28,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(hintText: 'Title (optional)'),
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
            ],
          );
        },
      ),
    );
  }
}

class _ReviewMenu extends StatelessWidget {
  final VoidCallback onReport;
  final VoidCallback onBlock;

  const _ReviewMenu({required this.onReport, required this.onBlock});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'More',
      padding: EdgeInsets.zero,
      icon: const Icon(IconsaxPlusLinear.more, size: 18, color: AppColors.ink3),
      onSelected: (v) => v == 0 ? onReport() : onBlock(),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(IconsaxPlusLinear.flag, size: 18),
              SizedBox(width: 10),
              Text('Report review'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(IconsaxPlusLinear.user_remove, size: 18, color: AppColors.critical),
              SizedBox(width: 10),
              Text('Block user', style: TextStyle(color: AppColors.critical)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Asks why a review is being reported and sends it. Pops the server's
/// message once the report is accepted.
class _ReportSheet extends StatefulWidget {
  final Future<String> Function(String reason, String details) onSubmit;

  const _ReportSheet({required this.onSubmit});

  static Future<String?> show({
    required Future<String> Function(String reason, String details) onSubmit,
  }) => AppSheet.show<String>(
    title: 'Report review',
    child: _ReportSheet(onSubmit: onSubmit),
  );

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const _reasons = {
    'spam': 'Spam or advertising',
    'offensive': 'Offensive or abusive',
    'fake': 'Fake or misleading',
    'off_topic': 'Not about this product',
    'personal_info': 'Shares personal information',
    'other': 'Something else',
  };

  String? reason;
  final details = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    details.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => sending = true);
    try {
      final message = await widget.onSubmit(reason!, details.text);
      if (mounted) Navigator.of(context).pop(message);
    } on AppException catch (e) {
      // 404: the review was already taken down — nothing left to report.
      if (e.statusCode == 404 && mounted) {
        Navigator.of(context).pop('This review has already been removed.');
        return;
      }
      CfoToast.error(e.message);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tell us what's wrong. The review is hidden for you straight away.",
          style: AppTextStyles.caption.copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: reason,
          onChanged: (v) => setState(() => reason = v),
          child: Column(
            children: [
              for (final e in _reasons.entries)
                RadioListTile<String>(
                  value: e.key,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(e.value, style: AppTextStyles.body),
                ),
            ],
          ),
        ),
        TextField(
          controller: details,
          maxLines: 2,
          maxLength: 1000,
          decoration: const InputDecoration(hintText: 'Add details (optional)'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: reason == null || sending ? null : _send,
            child: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send report'),
          ),
        ),
      ],
    );
  }
}
