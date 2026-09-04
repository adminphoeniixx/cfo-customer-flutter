import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, fontFamily: 'Roboto');
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ground,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.brand,
        secondary: AppColors.deal,
        surface: AppColors.surface,
        error: AppColors.critical,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.chrome,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: IconThemeData(color: AppColors.ink),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.line, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onBrand,
          disabledBackgroundColor: AppColors.brand.withValues(alpha: 0.4),
          textStyle: AppTextStyles.button,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.action,
          textStyle: AppTextStyles.bodyMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.critical),
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.ink3),
        labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.brand,
        unselectedItemColor: AppColors.ink3,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.tiny,
        unselectedLabelStyle: AppTextStyles.tiny,
        elevation: 8,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.brandSoft,
        labelStyle: AppTextStyles.label.copyWith(color: AppColors.action),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        side: BorderSide.none,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
