import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/notifications_badge_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_content.dart';
import '../../data/repositories/account_repository.dart';
import '../../routes/app_routes.dart';
import '../../shared/utils/cfo_toast.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/cfo_app_bar.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/prototype_image.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final _repo = Get.find<AccountRepository>();
  AccountSummary? summary;
  AppConfig? config;

  @override
  void initState() {
    super.initState();
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    try {
      final nextSummary = await _repo.summary();
      final nextConfig = await _repo.appConfig();
      if (!mounted) return;
      setState(() {
        summary = nextSummary;
        config = nextConfig;
      });
    } catch (e) {
      CfoToast.error('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: CfoAppBar(
        title: 'My account',
        showBack: false,
        actions: [
          CfoAppBarAction(
            icon: AppSvgIcons.bell,
            tooltip: 'Notifications',
            badgeCount: () =>
                Get.find<NotificationsBadgeService>().unreadCount.value,
            onTap: () => Get.toNamed(AppRoutes.notifications),
          ),
        ],
      ),
      body: Obx(() {
        final loggedIn = auth.isLoggedIn.value;
        final c = auth.customer.value;
        if (!loggedIn) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            children: [
              _Card(
                padded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome to CFO Shop', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to track orders, save addresses and more.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.ink2,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Sign in',
                      expand: false,
                      onPressed: () => Get.toNamed(AppRoutes.login),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          children: [
            _ProfileCard(
              initials: _initials(c?.firstName, c?.lastName),
              name: c?.displayName ?? 'Shopper',
              detail: [
                c?.phone,
                c?.email,
              ].where((e) => e != null && e.isNotEmpty).join(' · '),
            ),
            const SizedBox(height: 9),
            _Card(
              children: [
                _MenuRow(
                  icon: '📦',
                  title: 'My orders',
                  subtitle:
                      '${summary?.ordersCount ?? c?.ordersCount ?? 0} orders · ${formatInr(summary?.ordersSpent ?? c?.totalSpent ?? 0)} spent',
                  onTap: () => Get.toNamed(AppRoutes.orders),
                ),
                _MenuRow(
                  icon: '♥',
                  title: 'Wishlist',
                  subtitle: '${summary?.wishlistCount ?? 0} saved',
                  onTap: () => Get.toNamed(AppRoutes.wishlist),
                ),
                _MenuRow(
                  icon: '🏷️',
                  title: 'Coupons',
                  subtitle: '${summary?.couponCount ?? 0} available',
                  onTap: () => Get.toNamed(AppRoutes.coupons),
                ),
                _MenuRow(
                  icon: '⭐',
                  title: 'My reviews',
                  subtitle:
                      '${summary?.reviewsWrittenCount ?? 0} written · ${summary?.reviewsPendingCount ?? 0} waiting',
                  onTap: () => Get.toNamed(AppRoutes.myReviews),
                ),
              ],
            ),
            const SizedBox(height: 9),
            const _SectionTitle('Account'),
            const SizedBox(height: 9),
            _Card(
              children: [
                _MenuRow(
                  icon: '📍',
                  title: 'Saved addresses',
                  subtitle: '${summary?.addressesCount ?? 0} saved',
                  onTap: () => Get.toNamed(AppRoutes.addresses),
                ),
                _MenuRow(
                  icon: '💳',
                  title: 'Payments',
                  subtitle: 'Cards, UPI, store credit',
                  onTap: () => Get.toNamed(AppRoutes.paymentsInfo),
                ),
                _MenuRow(
                  icon: '🔔',
                  title: 'Notifications',
                  subtitle:
                      '${c?.acceptsMarketing == true ? 'Push on' : 'Push off'} · order and deal alerts',
                  onTap: () => Get.toNamed(AppRoutes.notificationSettings),
                ),
                _MenuRow(
                  icon: '📱',
                  title: 'Signed-in devices',
                  subtitle: '${summary?.devicesCount ?? 0} active',
                  onTap: () => Get.toNamed(AppRoutes.devices),
                ),
                _MenuRow(
                  icon: '🔒',
                  title: 'Change password',
                  onTap: () => Get.toNamed(AppRoutes.changePassword),
                ),
              ],
            ),
            const SizedBox(height: 9),
            const _SectionTitle('More'),
            const SizedBox(height: 9),
            _Card(
              children: [
                _MenuRow(
                  icon: '💬',
                  title: 'Help centre',
                  subtitle: 'Orders, refunds, payments',
                  onTap: () => Get.toNamed(AppRoutes.help),
                ),
                _MenuRow(
                  icon: 'ℹ️',
                  title: 'About & legal',
                  subtitle: 'Terms, privacy, licences',
                  onTap: () => Get.toNamed(AppRoutes.about),
                ),
                _MenuRow(
                  icon: '🏬',
                  title: 'Sell on CFO',
                  subtitle: 'Open a store - takes 5 minutes',
                  onTap: () => CfoToast.show(
                    config?.sellerOnboardingUrl?.isNotEmpty == true
                        ? config!.sellerOnboardingUrl!
                        : 'Seller onboarding is not available yet.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            _DangerButton(
              label: 'Sign out',
              onTap: () async {
                await auth.logout();
                Get.offAllNamed(AppRoutes.nav);
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                config?.storeName ?? 'CFO Shop',
                style: AppTextStyles.caption.copyWith(fontSize: 11.5),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String initials;
  final String name;
  final String detail;

  const _ProfileCard({
    required this.initials,
    required this.name,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padded: true,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.infoBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              initials,
              style: AppTextStyles.h2.copyWith(
                color: AppColors.action,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.profile),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.action,
              textStyle: AppTextStyles.body.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Text(
              '›',
              style: TextStyle(
                color: AppColors.ink3,
                fontSize: 18,
                height: 1,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget? child;
  final List<Widget>? children;
  final bool padded;

  const _Card({this.child, this.children, this.padded = false});

  @override
  Widget build(BuildContext context) {
    final content =
        child ??
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children!.length; i++) ...[
              children![i],
              if (i != children!.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.lineSoft,
                ),
            ],
          ],
        );
    return Container(
      padding: padded ? const EdgeInsets.all(12) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
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

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DangerButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.critical,
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

String _initials(String? first, String? last) {
  final a = first?.trim().isNotEmpty == true ? first!.trim()[0] : '';
  final b = last?.trim().isNotEmpty == true ? last!.trim()[0] : '';
  final initials = '$a$b'.toUpperCase();
  return initials.isEmpty ? 'PN' : initials;
}
