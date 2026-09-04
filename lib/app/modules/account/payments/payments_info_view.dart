import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/app_content.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/prototype_image.dart';
import 'package:get/get.dart';

class PaymentsInfoView extends StatefulWidget {
  const PaymentsInfoView({super.key});

  @override
  State<PaymentsInfoView> createState() => _PaymentsInfoViewState();
}

class _PaymentsInfoViewState extends State<PaymentsInfoView> {
  final _repo = Get.find<AccountRepository>();
  WalletSummary? wallet;
  List<SavedPaymentMethod> methods = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = wallet == null && methods.isEmpty);
    try {
      final nextWallet = await _repo.wallet();
      final nextMethods = await _repo.paymentMethods();
      if (!mounted) return;
      setState(() {
        wallet = nextWallet;
        methods = nextMethods;
      });
    } catch (e) {
      CfoToast.error('$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _remove(SavedPaymentMethod method) async {
    try {
      await _repo.deletePaymentMethod(method.id);
      CfoToast.success('Payment method removed');
      await _load();
    } catch (e) {
      CfoToast.error('$e');
    }
  }

  Future<void> _makeDefault(SavedPaymentMethod method) async {
    try {
      await _repo.setDefaultPaymentMethod(method.id);
      CfoToast.success('Default payment method updated');
      await _load();
    } catch (e) {
      CfoToast.error('$e');
    }
  }

  Future<void> _addUpi() async {
    final ctrl = TextEditingController();
    final vpa = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add UPI ID'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'yourname@bank'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (vpa == null || vpa.isEmpty) return;
    if (!RegExp(r'^[\w.\-]{2,}@[a-zA-Z]{2,}$').hasMatch(vpa)) {
      CfoToast.error('Enter a valid UPI ID, e.g. yourname@bank');
      return;
    }
    try {
      await _repo.addPaymentMethod(type: 'upi', label: 'UPI', maskedValue: vpa);
      CfoToast.success('UPI ID saved');
      await _load();
    } catch (e) {
      CfoToast.error('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const CfoAppBar(title: 'Payments'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STORE CREDIT',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.infoInk,
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.07,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatInr(wallet?.balance ?? 0),
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.infoInk,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    wallet?.source,
                    wallet?.expiresAt == null
                        ? 'no expiry'
                        : 'expires ${wallet!.expiresAt}',
                  ].where((e) => e != null && e.isNotEmpty).join(' · '),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.infoInk.withValues(alpha: 0.85),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          const _SectionTitle('Saved cards'),
          const SizedBox(height: 9),
          if (_methodsOf('card').isEmpty)
            const EmptyState(icon: Icons.credit_card, title: 'No saved cards')
          else
            _Card(
              children: [
                for (final method in _methodsOf('card'))
                  _PaymentRow(
                    icon: '💳',
                    title: _methodTitle(method),
                    subtitle: _methodSubtitle(method),
                    onRemove: () => _remove(method),
                    onMakeDefault:
                        method.isDefault ? null : () => _makeDefault(method),
                  ),
              ],
            ),
          const SizedBox(height: 9),
          const _SectionTitle('UPI'),
          const SizedBox(height: 9),
          if (_methodsOf('upi').isEmpty)
            const EmptyState(icon: Icons.bolt, title: 'No saved UPI')
          else
            _Card(
              children: [
                for (final method in _methodsOf('upi'))
                  _PaymentRow(
                    icon: '⚡',
                    title: _methodTitle(method),
                    subtitle: _methodSubtitle(method),
                    onRemove: () => _remove(method),
                    onMakeDefault:
                        method.isDefault ? null : () => _makeDefault(method),
                  ),
              ],
            ),
          const SizedBox(height: 9),
          _GhostButton(
            label: '+ Add a UPI ID',
            onTap: _addUpi,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Card numbers are held by the payment gateway, never by CFO Shop.',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SavedPaymentMethod> _methodsOf(String type) =>
      methods.where((m) => m.type == type).toList();

  String _methodTitle(SavedPaymentMethod method) =>
      [method.label, method.maskedValue]
          .where((e) => e.isNotEmpty)
          .join(' ');

  String _methodSubtitle(SavedPaymentMethod method) => [
    method.provider,
    if (method.expiresAt != null) 'expires ${method.expiresAt}',
    method.verified ? 'Verified' : null,
    method.isDefault ? 'Default' : null,
  ].where((e) => e != null && e.isNotEmpty).join(' · ');
}

class _PaymentRow extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onRemove;
  final VoidCallback? onMakeDefault;

  const _PaymentRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRemove,
    this.onMakeDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          PrototypeImage(source: icon, size: 44, fontSize: 20),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
          if (onMakeDefault != null)
            TextButton(
              onPressed: onMakeDefault,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.action,
                textStyle: AppTextStyles.body.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Set default'),
            ),
          TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.critical,
              textStyle: AppTextStyles.body.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.action,
          textStyle: AppTextStyles.button.copyWith(
            fontSize: 14,
            height: 1,
            letterSpacing: 0.02,
          ),
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label),
      ),
    );
  }
}
