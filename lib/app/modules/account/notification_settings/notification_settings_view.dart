import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_content.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final _repo = Get.find<AccountRepository>();
  final _auth = Get.find<AuthService>();
  NotificationPreferences? prefs;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final next = await _repo.notificationPreferences();
      if (!mounted) return;
      setState(() {
        prefs = next;
        loading = false;
      });
    } catch (e) {
      CfoToast.error('$e');
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save(NotificationPreferences next) async {
    if (saving) return;
    final previous = prefs;
    setState(() {
      prefs = next;
      saving = true;
    });
    try {
      final saved = await _repo.updateNotificationPreferences(next);
      if (!mounted) return;
      setState(() => prefs = saved);
      final customer = _auth.customer.value;
      if (customer != null && customer.acceptsMarketing != saved.emailMarketing) {
        _auth.customer.value = await _repo.me();
      }
      CfoToast.success('Notification settings saved');
    } catch (e) {
      if (mounted) setState(() => prefs = previous);
      CfoToast.error('$e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const CfoAppBar(title: 'Notifications'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        children: [
          _Card(
            children: [
              _SwitchRow(
                title: 'Push notifications',
                subtitle: 'On this device',
                value: prefs?.pushEnabled ?? false,
                onTap: saving
                    ? null
                    : () => _save(
                        prefs!.copyWith(pushEnabled: !prefs!.pushEnabled),
                      ),
              ),
              _SwitchRow(
                title: 'Order updates',
                subtitle: 'Packed, shipped, out for delivery, refunds',
                value: prefs?.orderUpdates ?? false,
                onTap: saving
                    ? null
                    : () => _save(
                        prefs!.copyWith(orderUpdates: !prefs!.orderUpdates),
                      ),
              ),
              _SwitchRow(
                title: 'Deals and price drops',
                subtitle: 'Only for things on your wishlist',
                value: prefs?.dealsPriceDrops ?? false,
                onTap: saving
                    ? null
                    : () => _save(
                        prefs!.copyWith(
                          dealsPriceDrops: !prefs!.dealsPriceDrops,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              "Order updates also arrive by SMS and email. Turning push off here doesn't stop those.",
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
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final VoidCallback? onTap;

  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
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
          _Switch(value: value, onTap: onTap),
        ],
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final bool value;
  final VoidCallback? onTap;

  const _Switch({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 38,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.deal : AppColors.line,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
          ),
        ),
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
