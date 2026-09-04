import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CfoToast {
  CfoToast._();

  static void show(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Text(
        trimmed,
        textAlign: TextAlign.center,
        style: AppTextStyles.label.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w500,
          height: 1.25,
        ),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.ink,
      borderRadius: 6,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 84),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      duration: const Duration(milliseconds: 2200),
      animationDuration: const Duration(milliseconds: 200),
      isDismissible: false,
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
    );
  }

  static void error(String message) => show(message);

  static void success(String message) => show(message);
}
