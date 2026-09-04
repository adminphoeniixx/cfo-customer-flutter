import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/order.dart';
import '../../../data/models/reference.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/requests_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/bottom_buy_bar.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/prototype_image.dart';

class ReturnFormView extends StatefulWidget {
  const ReturnFormView({super.key});

  @override
  State<ReturnFormView> createState() => _ReturnFormViewState();
}

class _ReturnFormViewState extends State<ReturnFormView> {
  late Order order;
  ReferenceData? reference;
  String? selectedReason;
  String? selectedMethod;
  final noteCtrl = TextEditingController();
  final Map<int, int> quantities = {};
  bool loading = true;
  bool submitting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    order = args['order'] as Order;
    _load();
  }

  Future<void> _load() async {
    reference = await Get.find<CatalogRepository>().reference();
    if (reference!.refundMethods.isNotEmpty) {
      selectedMethod = reference!.refundMethods.first.code;
    }
    setState(() => loading = false);
  }

  Future<void> _submit() async {
    final items = quantities.entries
        .where((e) => e.value > 0)
        .map((e) => {'order_item_id': e.key, 'quantity': e.value})
        .toList();
    if (selectedReason == null || items.isEmpty) {
      setState(
        () => error = 'Choose a reason and at least one item to return.',
      );
      return;
    }
    setState(() {
      submitting = true;
      error = null;
    });
    try {
      await Get.find<RequestsRepository>().returnOrder(
        order.number,
        reason: selectedReason!,
        method: selectedMethod ?? 'original',
        note: noteCtrl.text.trim(),
        items: items,
      );
      Get.back(result: true);
      CfoToast.success('Return requested');
    } on AppException catch (e) {
      setState(() => error = e.message);
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: CfoAppBar(title: 'Return items', subtitle: order.number),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Text('What are you returning?', style: AppTextStyles.title),
                const SizedBox(height: AppSpace.xs),
                _Card(
                  child: Column(
                    children: [
                      for (final item in order.items.where(
                        (i) => i.quantityAvailable > 0,
                      ))
                        _ReturnItemRow(
                          item: item,
                          quantity: quantities[item.id] ?? 0,
                          onChanged: (q) =>
                              setState(() => quantities[item.id] = q),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                Text('Reason', style: AppTextStyles.title),
                const SizedBox(height: AppSpace.xs),
                _Card(
                  child: Column(
                    children: [
                      for (final r in reference!.refundReasons)
                        _OptionRow(
                          label: r.label,
                          selected: selectedReason == r.code,
                          onTap: () => setState(() => selectedReason = r.code),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                Text('Refund method', style: AppTextStyles.title),
                const SizedBox(height: AppSpace.xs),
                _Card(
                  child: Column(
                    children: [
                      for (final m in reference!.refundMethods)
                        _OptionRow(
                          label: m.label,
                          selected: selectedMethod == m.code,
                          onTap: () => setState(() => selectedMethod = m.code),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                TextField(
                  controller: noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'The pallu had a tear near the border.',
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.critical,
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: BottomBuyBar(
        actionLabel: 'Submit return',
        loading: submitting,
        onAction: _submit,
      ),
    );
  }
}

class _ReturnItemRow extends StatelessWidget {
  final OrderItem item;
  final int quantity;
  final ValueChanged<int> onChanged;

  const _ReturnItemRow({
    required this.item,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.sm),
      child: Row(
        children: [
          PrototypeImage(source: item.image, size: 44, fontSize: 22),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty ${item.quantity} · returns available ${item.quantityAvailable}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          _QtyStepper(
            quantity: quantity,
            max: item.quantityAvailable,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  const _QtyStepper({
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(
            Icons.remove,
            quantity > 0 ? () => onChanged(quantity - 1) : null,
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: AppColors.line),
              ),
            ),
            child: Text('$quantity', style: AppTextStyles.bodyMedium),
          ),
          _button(
            Icons.add,
            quantity < max ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback? onTap) => InkWell(
    onTap: onTap,
    child: SizedBox(
      width: 30,
      height: 28,
      child: Icon(
        icon,
        size: 16,
        color: onTap == null ? AppColors.ink3 : AppColors.ink,
      ),
    ),
  );
}

class _OptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm,
          vertical: 11,
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.action : AppColors.line,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: AppTextStyles.body)),
          ],
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
