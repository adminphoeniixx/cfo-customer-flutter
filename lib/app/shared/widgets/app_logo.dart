import 'package:flutter/widgets.dart';

/// The launcher icon as an in-app logo (login, splash, about), clipped to
/// the same rounded-square silhouette the home screen gives it.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64});

  static const asset = 'assets/branding/app_logo.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.225),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
