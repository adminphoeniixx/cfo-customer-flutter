import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';

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
    final child = s == null || s.isEmpty
        ? const Icon(Icons.image_outlined, color: AppColors.ink3)
        : _looksLikeUrl(s)
        ? CachedNetworkImage(
            imageUrl: s.startsWith('/') ? '${ApiClient.baseUrl}$s' : s,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: AppColors.surface2),
            errorWidget: (context, url, error) => const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.ink3,
            ),
          )
        : Center(
            child: Text(s, style: TextStyle(fontSize: fontSize)),
          );
    final w = width ?? size ?? 44;
    final h = height ?? size ?? 44;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(9),
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          border: Border.all(color: AppColors.line),
        ),
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
