import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/account_badge_service.dart';
import '../../core/auth/auth_service.dart';
import '../../core/auth/notifications_badge_service.dart';
import '../../core/auth/wishlist_service.dart';
import '../../core/storage/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await StorageService.init();
    final auth = await AuthService().init();
    Get.put(auth, permanent: true);
    final wishlist = await WishlistService().init();
    Get.put(wishlist, permanent: true);
    final notifBadge = await NotificationsBadgeService().init();
    Get.put(notifBadge, permanent: true);
    final accountBadge = await AccountBadgeService().init();
    Get.put(accountBadge, permanent: true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.nav);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.brand,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_rounded, color: Colors.white, size: 56),
            SizedBox(height: 12),
            Text('CFO Shop', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
