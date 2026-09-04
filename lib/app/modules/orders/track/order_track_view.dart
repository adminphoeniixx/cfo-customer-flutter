import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/orders_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/prototype_image.dart';

class OrderTrackView extends StatefulWidget {
  const OrderTrackView({super.key});

  @override
  State<OrderTrackView> createState() => _OrderTrackViewState();
}

class _OrderTrackViewState extends State<OrderTrackView> {
  final _repo = Get.find<OrdersRepository>();
  late String number;
  OrderTrack? track;
  Order? order;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    number = args is Map ? (args['number']?.toString() ?? '') : '';
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = track == null);
    try {
      track = await _repo.track(number);
    } finally {
      setState(() => loading = false);
    }
    try {
      order = await _repo.detail(number);
      if (mounted) setState(() {});
    } catch (_) {
      // Track info alone is enough to render the screen.
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrier = track?.carrier ?? 'Delivery partner';
    return Scaffold(
      appBar: CfoAppBar(
        title: 'Track order',
        subtitle: [number, carrier].where((e) => e.isNotEmpty).join(' · '),
        onBack: () {
          if (Navigator.of(context).canPop()) {
            Get.back();
          } else if (number.isNotEmpty) {
            Get.offNamed(AppRoutes.orderDetail, arguments: {'number': number});
          } else {
            Get.offAllNamed(AppRoutes.nav);
          }
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : track == null
          ? const Center(child: Text('Tracking not available yet.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              children: [
                _TrackSummary(order: order, track: track!),
                const SizedBox(height: 12),
                _TrackTimeline(track: track!),
                if (order != null && order!.items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ItemsCard(order: order!),
                ],
                const SizedBox(height: 12),
                _ActionCard(track: track!, carrier: carrier),
              ],
            ),
    );
  }
}

class _TrackSummary extends StatelessWidget {
  final Order? order;
  final OrderTrack track;
  const _TrackSummary({required this.order, required this.track});

  @override
  Widget build(BuildContext context) {
    final delivered = order?.deliveredAt != null;
    final eta = delivered
        ? 'Delivered ${formatDate(order!.deliveredAt)}'
        : (track.etaLabel ?? 'Delivery date pending');
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eta,
            style: AppTextStyles.title.copyWith(
              fontSize: 15,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${track.carrier ?? order?.carrier ?? 'Delivery partner'} · ${track.trackingNumber ?? order?.trackingNumber ?? 'Tracking pending'}',
            style: AppTextStyles.caption.copyWith(fontSize: 12.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(track.milestones.isEmpty ? 4 : track.milestones.length, (i) {
              final total = track.milestones.isEmpty ? 4 : track.milestones.length;
              final doneCount = track.milestones.where((m) => m.at != null).length;
              final active = delivered ? true : i < doneCount;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.brand : AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TrackTimeline extends StatelessWidget {
  final OrderTrack track;
  const _TrackTimeline({required this.track});

  @override
  Widget build(BuildContext context) {
    final rows = _rows(track);
    final lastDone = rows.lastIndexWhere((row) => row.done);
    return _Card(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            _TimelineNode(
              title: rows[i].title,
              subtitle: rows[i].subtitle,
              done: rows[i].done,
              now: i == lastDone && i != rows.length - 1,
              last: i == rows.length - 1,
            ),
        ],
      ),
    );
  }

  List<_TimelineData> _rows(OrderTrack track) {
    if (track.milestones.isNotEmpty) {
      return track.milestones
          .map(
            (event) => _TimelineData(
              event.title,
              event.at == null ? 'Pending' : formatDateTime(event.at),
              event.at != null,
            ),
          )
          .toList();
    }
    return const [
      _TimelineData('Picked up from the seller', 'Pending', false),
      _TimelineData('In transit', 'Pending', false),
      _TimelineData('Out for delivery', 'Pending', false),
      _TimelineData('Delivered', 'Pending', false),
    ];
  }
}

class _TimelineNode extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final bool now;
  final bool last;

  const _TimelineNode({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.now,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = now ? AppColors.brand : AppColors.deal;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(
                width: 19,
                height: 19,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done ? activeColor : AppColors.line,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: done ? activeColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (!last)
                Container(
                  width: 2,
                  height: 26,
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
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.ink,
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
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

class _ItemsCard extends StatelessWidget {
  final Order order;
  const _ItemsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final sellers = {
      for (final seller in order.sellers) seller.id: seller.name,
    };
    return _Card(
      flat: true,
      child: Column(
        children: [
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  PrototypeImage(
                    source: item.image,
                    width: 44,
                    height: 44,
                    fontSize: 20,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.ink,
                            fontSize: 13.5,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Qty ${item.quantity} · ${sellers[item.vendorId] ?? 'Seller'}',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

class _ActionCard extends StatelessWidget {
  final OrderTrack track;
  final String carrier;
  const _ActionCard({required this.track, required this.carrier});

  @override
  Widget build(BuildContext context) {
    return _Card(
      flat: true,
      child: Column(
        children: [
          _ActionRow(
            icon: '🔗',
            title: 'Copy tracking number',
            subtitle: track.trackingUrl ?? 'Tracking link not available',
            onTap: () => CfoToast.show(
              track.trackingNumber ?? 'Tracking number not available.',
            ),
          ),
          _ActionRow(
            icon: '📞',
            title: 'Call $carrier',
            subtitle: 'Support phone not available',
            onTap: () => Get.toNamed(AppRoutes.help),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PrototypeImage(
              source: icon,
              width: 44,
              height: 44,
              fontSize: 20,
              borderRadius: BorderRadius.circular(9),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.ink,
                      fontSize: 13.5,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Text(
              '›',
              style: TextStyle(color: AppColors.ink3, fontSize: 18, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool flat;
  const _Card({required this.child, this.flat = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: flat ? EdgeInsets.zero : const EdgeInsets.all(12),
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

class _TimelineData {
  final String title;
  final String subtitle;
  final bool done;

  const _TimelineData(this.title, this.subtitle, this.done);
}
