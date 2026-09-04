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

/// Whole-order cancellation only, before anything ships — matches the API's
/// rule that `items` is omitted to cancel the entire order.
class CancelFormView extends StatefulWidget {
  const CancelFormView({super.key});

  @override
  State<CancelFormView> createState() => _CancelFormViewState();
}

class _CancelFormViewState extends State<CancelFormView> {
  late Order order;
  ReferenceData? reference;
  String? selectedReason;
  final noteCtrl = TextEditingController();
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
    setState(() => loading = false);
  }

  Future<void> _submit() async {
    if (selectedReason == null) {
      setState(() => error = 'Please choose a reason.');
      return;
    }
    setState(() {
      submitting = true;
      error = null;
    });
    try {
      await Get.find<RequestsRepository>().cancelOrder(
        order.number,
        reason: selectedReason,
        note: noteCtrl.text.trim(),
      );
      Get.back(result: true);
      CfoToast.success('Cancellation requested');
    } on AppException catch (e) {
      setState(() => error = e.message);
    } finally {
      setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CfoAppBar(title: 'Cancel order ${order.number}'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpace.md),
              children: [
                Text('Why are you cancelling?', style: AppTextStyles.title),
                const SizedBox(height: AppSpace.xs),
                _Card(
                  child: Column(
                    children: [
                      for (final r in reference!.cancellationReasons)
                        _OptionRow(
                          label: r.label,
                          selected: selectedReason == r.code,
                          onTap: () => setState(() => selectedReason = r.code),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                TextField(
                  controller: noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        'Ordered the wrong colour, please cancel before it ships.',
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: BottomBuyBar(
        actionLabel: 'Submit cancellation',
        loading: submitting,
        onAction: _submit,
      ),
    );
  }
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
