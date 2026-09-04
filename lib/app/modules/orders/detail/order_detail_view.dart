import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/address.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/orders_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/prototype_image.dart';
import '../list/orders_list_controller.dart';

class OrderDetailView extends StatefulWidget {
  const OrderDetailView({super.key});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  final _repo = Get.find<OrdersRepository>();
  late String number;
  Order? order;
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
    setState(() => loading = order == null);
    try {
      order = await _repo.detail(number);
      if (Get.isRegistered<OrdersListController>()) {
        Get.find<OrdersListController>().load();
      }
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _reorder() async {
    setState(() => busy = true);
    try {
      final result = await _repo.reorder(number);
      CfoToast.success(
        '${result.added.length} item(s) added${result.skipped.isNotEmpty ? ', ${result.skipped.length} skipped' : ''}.',
      );
      Get.toNamed(AppRoutes.cart);
    } on AppException catch (e) {
      CfoToast.error(e.message);
    } finally {
      setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final o = order;
    if (o == null) {
      return const Scaffold(body: Center(child: Text('Order not found')));
    }
    return Scaffold(
      appBar: CfoAppBar(
        title: 'Order ${o.number}',
        subtitle: formatDateTime(o.placedAt),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        children: [
          _TimelineCard(order: o),
          const SizedBox(height: 12),
          for (final group in _groups(o)) ...[
            _SellerCard(
              vendorName: group.vendorName,
              items: group.items,
              canCancel: o.canCancel,
              canReturn: o.canReturn,
              busy: busy,
              onBuyAgain: _reorder,
              onCancel: () async {
                final ok = await Get.toNamed(
                  AppRoutes.cancelForm,
                  arguments: {'order': o},
                );
                if (ok == true) _load();
              },
              onReturn: () async {
                final ok = await Get.toNamed(
                  AppRoutes.returnForm,
                  arguments: {'order': o},
                );
                if (ok == true) _load();
              },
            ),
            const SizedBox(height: 12),
          ],
          if (o.shippingAddress != null) ...[
            const _SectionTitle('Delivery address'),
            const SizedBox(height: 8),
            _AddressCard(address: o.shippingAddress!),
            const SizedBox(height: 12),
          ],
          const _SectionTitle('Payment'),
          const SizedBox(height: 8),
          _PaymentCard(order: o),
          const SizedBox(height: 12),
          _HelpCard(order: o),
        ],
      ),
    );
  }

  List<_VendorGroup> _groups(Order o) {
    final sellerNames = {
      for (final seller in o.sellers) seller.id: seller.name,
    };
    final map = <int, List<OrderItem>>{};
    for (final item in o.items) {
      map.putIfAbsent(item.vendorId, () => []).add(item);
    }
    return map.entries
        .map(
          (entry) => _VendorGroup(
            vendorName: sellerNames[entry.key] ?? 'Seller',
            items: entry.value,
          ),
        )
        .toList();
  }
}

class _TimelineCard extends StatelessWidget {
  final Order order;
  const _TimelineCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final rows = _rows(order);
    final lastDone = rows.lastIndexWhere((row) => row.done);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusPill(status: order.status, label: order.statusLabel),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _eta(order),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.ink2,
                    fontSize: 12.5,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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

  List<_TimelineData> _rows(Order o) {
    final paidAt = o.paidAt ?? (o.paymentStatus == 'paid' ? o.placedAt : null);
    final cash = o.paymentMethod.toLowerCase().contains('cash');
    return [
      _TimelineData('Order placed', _when(o.placedAt), o.placedAt != null),
      _TimelineData(
        cash ? 'Pay on delivery' : 'Payment confirmed',
        paidAt == null ? (cash ? 'Due at the door' : 'Pending') : _when(paidAt),
        paidAt != null || cash,
      ),
      _TimelineData('Shipped', _when(o.shippedAt), o.shippedAt != null),
      _TimelineData('Delivered', _when(o.deliveredAt), o.deliveredAt != null),
    ];
  }

  String _when(DateTime? date) =>
      date == null ? 'Pending' : formatDateTime(date);

  String _eta(Order o) {
    if (o.deliveredAt != null) return 'Delivered ${formatDate(o.deliveredAt)}';
    if (o.cancelledAt != null) return 'Cancelled ${formatDate(o.cancelledAt)}';
    return o.eta ?? 'Delivery date pending';
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

class _SellerCard extends StatelessWidget {
  final String vendorName;
  final List<OrderItem> items;
  final bool canCancel;
  final bool canReturn;
  final bool busy;
  final VoidCallback onBuyAgain;
  final VoidCallback onCancel;
  final VoidCallback onReturn;

  const _SellerCard({
    required this.vendorName,
    required this.items,
    required this.canCancel,
    required this.canReturn,
    required this.busy,
    required this.onBuyAgain,
    required this.onCancel,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      flat: true,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.surface2,
            child: Row(
              children: [
                const Text('🏬', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vendorName,
                    style: AppTextStyles.tiny.copyWith(
                      color: AppColors.ink,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final item in items)
            _OrderItemLine(
              item: item,
              canCancel: canCancel,
              canReturn: canReturn,
              busy: busy,
              onBuyAgain: onBuyAgain,
              onCancel: onCancel,
              onReturn: onReturn,
            ),
        ],
      ),
    );
  }
}

class _OrderItemLine extends StatelessWidget {
  final OrderItem item;
  final bool canCancel;
  final bool canReturn;
  final bool busy;
  final VoidCallback onBuyAgain;
  final VoidCallback onCancel;
  final VoidCallback onReturn;

  const _OrderItemLine({
    required this.item,
    required this.canCancel,
    required this.canReturn,
    required this.busy,
    required this.onBuyAgain,
    required this.onCancel,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final meta = item.options == null || item.options!.isEmpty
        ? 'Qty ${item.quantity}'
        : 'Qty ${item.quantity} · ${item.options!.entries.map((e) => '${e.key}: ${e.value}').join(' · ')}';
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrototypeImage(
            source: item.image,
            width: 68,
            height: 78,
            fontSize: 30,
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
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    height: 1.45,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  formatInr(item.total),
                  style: AppTextStyles.price.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _LinkButton(
                      label: busy ? 'Adding...' : 'Buy again',
                      onTap: busy ? null : onBuyAgain,
                    ),
                    if (canCancel)
                      _LinkButton(
                        label: 'Cancel',
                        color: AppColors.critical,
                        onTap: onCancel,
                      ),
                    if (canReturn)
                      _LinkButton(label: 'Return', onTap: onReturn),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${address.fullName} · ${address.label ?? 'Address'}',
            style: AppTextStyles.label.copyWith(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            address.singleLine.replaceAll(', ', '\n'),
            style: AppTextStyles.label.copyWith(
              color: AppColors.ink2,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            address.phone,
            style: AppTextStyles.caption.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final Order order;
  const _PaymentCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _totalRow('Items', formatInr(order.totals.subtotal)),
          if (order.totals.discountTotal > 0)
            _totalRow(
              'Discount${order.couponCode == null ? '' : ' (${order.couponCode})'}',
              '-${formatInr(order.totals.discountTotal)}',
              color: AppColors.deal,
            ),
          _totalRow(
            'Delivery',
            order.totals.shippingTotal == 0
                ? 'FREE'
                : formatInr(order.totals.shippingTotal),
            color: order.totals.shippingTotal == 0 ? AppColors.deal : null,
          ),
          _totalRow('GST', formatInr(order.totals.taxTotal)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(),
          ),
          _totalRow(
            order.paymentStatus == 'paid' ? 'Paid' : 'Payable',
            formatInr(order.totals.grandTotal),
            bold: true,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                order.paymentMethod,
                style: AppTextStyles.caption.copyWith(fontSize: 11.5),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalRow(
    String label,
    String value, {
    Color? color,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (bold ? AppTextStyles.title : AppTextStyles.body).copyWith(
              fontSize: bold ? 15 : 13,
              height: 1.2,
            ),
          ),
          Text(
            value,
            style: (bold ? AppTextStyles.title : AppTextStyles.bodyMedium)
                .copyWith(
                  color: color,
                  fontSize: bold ? 15 : 13,
                  height: 1.2,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final Order order;
  const _HelpCard({required this.order});

  Future<void> _invoice() async {
    try {
      final url = order.invoiceUrl?.isNotEmpty == true
          ? order.invoiceUrl!
          : await Get.find<OrdersRepository>().invoiceUrl(order.number);
      CfoToast.show(url.isEmpty ? 'Invoice is not available.' : url);
    } catch (e) {
      CfoToast.error('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      flat: true,
      child: Column(
        children: [
          _ActionRow(
            icon: '🧾',
            title: 'Download invoice',
            subtitle: 'Invoice, one document for this order',
            onTap: _invoice,
          ),
          _ActionRow(
            icon: '💬',
            title: 'Need help with this order',
            subtitle: 'Chat, or call the seller',
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        text,
        style: AppTextStyles.title.copyWith(
          fontSize: 13,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final String label;
  const _StatusPill({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final critical = status == 'cancelled' || status == 'rejected';
    final ok = status == 'delivered' || status == 'completed';
    final bg = ok
        ? AppColors.okBg
        : critical
        ? AppColors.critBg
        : AppColors.infoBg;
    final fg = ok
        ? AppColors.okInk
        : critical
        ? AppColors.critInk
        : AppColors.infoInk;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: AppTextStyles.tiny.copyWith(
          color: fg,
          fontSize: 9.5,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _LinkButton({required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: AppTextStyles.tiny.copyWith(
          color: color ?? AppColors.action,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TimelineData {
  final String title;
  final String subtitle;
  final bool done;

  const _TimelineData(this.title, this.subtitle, this.done);
}

class _VendorGroup {
  final String vendorName;
  final List<OrderItem> items;

  const _VendorGroup({required this.vendorName, required this.items});
}
