import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'app_icons.dart';

class PrototypeImage extends StatelessWidget {
  final String? source;
  final double? size;
  final double? width;
  final double? height;
  final double fontSize;
  final BorderRadiusGeometry? borderRadius;

  const PrototypeImage({
    super.key,
    required this.source,
    this.size,
    this.width,
    this.height,
    this.fontSize = 32,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final s = source?.trim();
    final w = width ?? size ?? 44;
    final h = height ?? size ?? 44;
    final glyph = s == null ? null : AppIcons.glyph(s);
    final child = s == null || s.isEmpty
        ? const Icon(IconsaxPlusLinear.gallery, color: AppColors.ink3)
        : glyph != null
        ? Center(
            child: Icon(
              glyph,
              size: (w < h ? w : h).clamp(16, 400) * 0.46,
              color: AppColors.brand,
            ),
          )
        : s.startsWith('assets/')
        ? Image.asset(s, fit: BoxFit.cover)
        : _looksLikeUrl(s)
        ? CachedNetworkImage(
            imageUrl: s.startsWith('/') ? '${ApiClient.baseUrl}$s' : s,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: AppColors.surface2),
            errorWidget: (context, url, error) => const Icon(
              IconsaxPlusLinear.gallery_slash,
              color: AppColors.ink3,
            ),
          )
        : Center(
            child: Text(s, style: TextStyle(fontSize: fontSize)),
          );
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.small),
      child: Container(
        width: w,
        height: h,
        decoration: const BoxDecoration(color: AppColors.surface2),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  bool _looksLikeUrl(String value) {
    final lower = value.toLowerCase();
    return lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('/') ||
        lower.startsWith('assets/');
  }
}
