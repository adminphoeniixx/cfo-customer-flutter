import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/request_item.dart';
import '../../../data/repositories/requests_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/order_status_pill.dart';
import '../../../shared/widgets/prototype_image.dart';

class RequestDetailView extends StatefulWidget {
  const RequestDetailView({super.key});

  @override
  State<RequestDetailView> createState() => _RequestDetailViewState();
}

class _RequestDetailViewState extends State<RequestDetailView> {
  final _repo = Get.find<RequestsRepository>();
  late String number;
  RequestItem? item;
  bool loading = true;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    number = args is Map ? (args['number']?.toString() ?? '') : '';
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = item == null);
    try {
      item = await _repo.detail(number);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _withdraw() async {
    setState(() => busy = true);
    try {
      await _repo.withdraw(number);
      Get.back(result: true);
    } on AppException catch (e) {
      CfoToast.error(e.message);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final r = item;
    if (r == null) {
      return const Scaffold(body: Center(child: Text('Request not found')));
    }
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: CfoAppBar(
        title: r.number,
        subtitle: r.isCancellation ? 'Cancellation' : 'Return & refund',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        children: [
          _SummaryCard(request: r),
          const SizedBox(height: 9),
          _TimelineCard(request: r),
          const SizedBox(height: 9),
          const _SectionTitle('What you told us'),
          const SizedBox(height: 9),
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _reasonLabel(r),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  if ((r.note ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      r.note!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.ink2,
                        fontSize: 12.5,
                        height: 1.55,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (r.items.isNotEmpty) ...[
            const SizedBox(height: 9),
            const _SectionTitle('Items'),
            const SizedBox(height: 9),
            _Card(
              child: Column(
                children: [
                  for (final li in r.items)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          PrototypeImage(source: '📦', size: 44, fontSize: 22),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              li.name ?? 'Item',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 13.5,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton(
              onPressed: () => Get.toNamed(
                AppRoutes.orderDetail,
                arguments: {'number': r.orderNumber ?? '#${r.orderId}'},
              ),
              style: _ghostButtonStyle(),
              child: Text('Open order ${r.orderNumber ?? '#${r.orderId}'}'),
            ),
          ),
          if (r.canWithdraw) ...[
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: busy ? null : _withdraw,
                style: _ghostButtonStyle(color: AppColors.critical),
                child: Text(busy ? 'Withdrawing…' : 'Withdraw request'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final RequestItem request;
  const _SummaryCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final amount = request.amount == null ? null : formatInr(request.amount!);
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                OrderStatusPill(
                  status: request.status,
                  label: _titleCase(request.status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Raised ${formatDate(request.createdAt)} on order ${request.orderNumber ?? '#${request.orderId}'}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.ink2,
                      fontSize: 12.5,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount == null
                  ? (request.isCancellation
                        ? 'Cancellation requested'
                        : 'Refund requested')
                  : '$amount to ${_methodLabel(request.method)}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              request.eta ??
                  (request.isCancellation
                      ? 'Seller will review this request.'
                      : 'Back in your account after approval'),
              style: AppTextStyles.body.copyWith(
                color: AppColors.ink3,
                fontSize: 12.5,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final RequestItem request;
  const _TimelineCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final rows = request.isCancellation
        ? [
            ('Cancellation requested', formatDate(request.createdAt), true),
            (
              'Seller approved',
              formatDate(request.createdAt),
              request.status != 'pending',
            ),
            (
              'Refund issued',
              request.eta ?? 'After approval',
              request.status == 'approved',
            ),
          ]
        : [
            ('Return requested', formatDate(request.createdAt), true),
            (
              'Seller approved',
              request.status == 'approved'
                  ? formatDate(request.createdAt?.add(const Duration(days: 1)))
                  : 'Waiting for approval',
              request.status == 'approved',
            ),
            (
              'Item picked up',
              'Scheduled after approval',
              false,
            ),
            ('Refund issued', request.eta ?? 'After pickup', false),
          ];
    return _Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++)
              _TimelineRow(
                title: rows[i].$1,
                subtitle: rows[i].$2,
                done: rows[i].$3,
                now: rows[i].$3 && (i == rows.length - 1 || !rows[i + 1].$3),
                last: i == rows.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final bool now;
  final bool last;

  const _TimelineRow({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.now,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final beadColor = !done
        ? AppColors.line
        : now
        ? AppColors.brand
        : AppColors.deal;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: beadColor,
                  boxShadow: now
                      ? [
                          const BoxShadow(
                            color: AppColors.infoBg,
                            spreadRadius: 4,
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
              ),
              if (!last)
                Container(
                  width: 2,
                  constraints: const BoxConstraints(minHeight: 26),
                  color: done ? AppColors.deal : AppColors.line,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

String _reasonLabel(RequestItem r) {
  final raw =
      r.reason ??
      (r.isCancellation ? 'Cancellation requested' : 'Return requested');
  return raw
      .split('_')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1))
      .join(' ');
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}

String _methodLabel(String? method) {
  final raw = method?.trim();
  if (raw == null || raw.isEmpty) return 'original payment method';
  return raw.replaceAll('_', ' ').toLowerCase();
}

ButtonStyle _ghostButtonStyle({Color color = AppColors.action}) {
  return OutlinedButton.styleFrom(
    foregroundColor: color,
    textStyle: AppTextStyles.button.copyWith(
      fontSize: 14,
      height: 1,
      letterSpacing: 0.02,
    ),
    side: BorderSide(color: color == AppColors.action ? AppColors.line : color),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    minimumSize: const Size.fromHeight(46),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}
