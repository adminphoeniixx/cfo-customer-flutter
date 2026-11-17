import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const _family = AppTextStyles.family;

  /// Material 3 defaults add wide letter-spacing (e.g. 0.5 on bodyLarge,
  /// used by text fields); Inter in this design is set slightly tight.
  static TextTheme _tightTracking(TextTheme t) {
    TextStyle? tight(TextStyle? s) => s?.copyWith(letterSpacing: -0.1);
    return t.copyWith(
      displayLarge: tight(t.displayLarge),
      displayMedium: tight(t.displayMedium),
      displaySmall: tight(t.displaySmall),
      headlineLarge: tight(t.headlineLarge),
      headlineMedium: tight(t.headlineMedium),
      headlineSmall: tight(t.headlineSmall),
      titleLarge: tight(t.titleLarge),
      titleMedium: tight(t.titleMedium),
      titleSmall: tight(t.titleSmall),
      bodyLarge: tight(t.bodyLarge),
      bodyMedium: tight(t.bodyMedium),
      bodySmall: tight(t.bodySmall),
      labelLarge: tight(t.labelLarge),
      labelMedium: tight(t.labelMedium),
      labelSmall: tight(t.labelSmall),
    );
  }

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, fontFamily: _family);
    final roundedInput = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: BorderSide.none,
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ground,
      canvasColor: AppColors.ground,
      splashFactory: InkSparkle.splashFactory,
      highlightColor: AppColors.brand.withValues(alpha: 0.04),
      splashColor: AppColors.brand.withValues(alpha: 0.08),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.brand,
        onPrimary: AppColors.onBrand,
        primaryContainer: AppColors.brandSoft,
        onPrimaryContainer: AppColors.brand,
        secondary: AppColors.accent,
        onSecondary: AppColors.onAccent,
        secondaryContainer: AppColors.brandSoft,
        onSecondaryContainer: AppColors.brand,
        tertiary: AppColors.deal,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.ink3,
        surfaceContainerLowest: AppColors.surface,
        surfaceContainerLow: AppColors.surface,
        surfaceContainer: AppColors.surface,
        surfaceContainerHigh: AppColors.surface,
        surfaceContainerHighest: AppColors.surface2,
        surfaceTint: Colors.transparent,
        outline: AppColors.line,
        outlineVariant: AppColors.lineSoft,
        error: AppColors.critical,
        onError: AppColors.onBrand,
        shadow: AppColors.ink.withValues(alpha: 0.08),
        scrim: AppColors.ink.withValues(alpha: 0.45),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.chrome,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: IconThemeData(color: AppColors.ink, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      textTheme: _tightTracking(
        base.textTheme.apply(
          fontFamily: _family,
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lineSoft,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.ink2,
        textColor: AppColors.ink,
        titleTextStyle: AppTextStyles.bodyMedium,
        subtitleTextStyle: AppTextStyles.caption,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onBrand,
          disabledBackgroundColor: AppColors.brand.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.onBrand,
          textStyle: AppTextStyles.button,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: buttonShape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.onBrand,
          disabledBackgroundColor: AppColors.brand.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.onBrand,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.surface,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.ink),
          side: const BorderSide(color: AppColors.line),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: buttonShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.ink),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brand,
        foregroundColor: AppColors.onBrand,
        elevation: 0,
        shape: StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        // Hairline keeps fields visible when they sit on a white card.
        border: roundedInput.copyWith(
          borderSide: const BorderSide(color: AppColors.lineSoft),
        ),
        enabledBorder: roundedInput.copyWith(
          borderSide: const BorderSide(color: AppColors.lineSoft),
        ),
        disabledBorder: roundedInput,
        focusedBorder: roundedInput.copyWith(
          borderSide: const BorderSide(color: AppColors.brand, width: 1.4),
        ),
        errorBorder: roundedInput.copyWith(
          borderSide: const BorderSide(color: AppColors.critical),
        ),
        focusedErrorBorder: roundedInput.copyWith(
          borderSide: const BorderSide(color: AppColors.critical, width: 1.4),
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.ink3),
        labelStyle: AppTextStyles.label,
        floatingLabelStyle: AppTextStyles.label.copyWith(
          color: AppColors.brand,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: AppColors.ink3,
        suffixIconColor: AppColors.ink3,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.critical),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.brand,
        selectionColor: AppColors.brand.withValues(alpha: 0.2),
        selectionHandleColor: AppColors.brand,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.brand,
        unselectedItemColor: AppColors.ink3,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTextStyles.tiny,
        unselectedLabelStyle: AppTextStyles.tiny,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => AppTextStyles.tiny.copyWith(
            color: s.contains(WidgetState.selected)
                ? AppColors.brand
                : AppColors.ink3,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.onBrand,
        unselectedLabelColor: AppColors.ink2,
        labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.label,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicator: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabAlignment: TabAlignment.start,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.brand,
        disabledColor: AppColors.surface2,
        checkmarkColor: AppColors.onBrand,
        labelStyle: AppTextStyles.label.copyWith(color: AppColors.ink),
        secondaryLabelStyle: AppTextStyles.label.copyWith(
          color: AppColors.onBrand,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        side: BorderSide.none,
        elevation: 0,
        pressElevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.surface),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.brand
              : AppColors.line,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.brand
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(AppColors.onBrand),
        side: const BorderSide(color: AppColors.ink3, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.brand
              : AppColors.ink3,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brand,
        linearTrackColor: AppColors.surface2,
        circularTrackColor: Colors.transparent,
        refreshBackgroundColor: AppColors.surface,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.brand,
        inactiveTrackColor: AppColors.line,
        thumbColor: AppColors.brand,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.ground,
        modalBackgroundColor: AppColors.ground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: false,
        dragHandleColor: AppColors.line,
        dragHandleSize: Size(40, 4),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.ink2),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.brand,
        headerForegroundColor: AppColors.onBrand,
        todayBorder: const BorderSide(color: AppColors.brand),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: AppColors.ink.withValues(alpha: 0.12),
        textStyle: AppTextStyles.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.surface),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.body,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.surface),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        textStyle: AppTextStyles.caption.copyWith(color: AppColors.surface),
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.brand,
        textColor: AppColors.onBrand,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: AppColors.ink,
        collapsedIconColor: AppColors.ink3,
        textColor: AppColors.ink,
        collapsedTextColor: AppColors.ink,
        shape: Border(),
        collapsedShape: Border(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.surface,
        ),
        actionTextColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
    );
  }
}
