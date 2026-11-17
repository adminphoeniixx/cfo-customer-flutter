import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icons.dart';
import 'cfo_app_bar.dart';

/// The one bottom-sheet look used across the app: off-white panel with
/// rounded top, drag handle, title and a round close button. Content sits
/// on the off-white ground so white chips / cards inside it read clearly.
class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    required this.child,
    this.title,
    this.scrollable = true,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
  });

  final String? title;
  final Widget child;
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  /// Opens [child] in an [AppSheet]. Keyboard-safe and height-capped.
  static Future<T?> show<T>({
    BuildContext? context,
    String? title,
    required Widget child,
    bool scrollable = true,
  }) {
    return showModalBottomSheet<T>(
      context: context ?? Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (context) =>
          AppSheet(title: title, scrollable: scrollable, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final body = Padding(padding: padding, child: child);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.ground,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.sheet),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                  ),
                ),
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 12, 12),
                    child: Row(
                      children: [
                        Expanded(child: Text(title!, style: AppTextStyles.h3)),
                        CircleIconButton(
                          icon: AppIcons.close,
                          size: 36,
                          iconSize: 18,
                          tooltip: 'Close',
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ),
                Flexible(
                  child: scrollable ? SingleChildScrollView(child: body) : body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Themed confirm / info dialogs.
class AppDialog {
  AppDialog._();

  /// Returns true when the user confirms.
  static Future<bool> confirm({
    BuildContext? context,
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context ?? Get.context!,
      builder: (ctx) => AppDialogFrame(
        title: title,
        content: message == null ? null : Text(message),
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        destructive: destructive,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
    return ok == true;
  }
}

/// Rounded white dialog with a ghost "Cancel" and a filled primary action
/// side by side (red when [destructive]).
class AppDialogFrame extends StatelessWidget {
  const AppDialogFrame({
    super.key,
    required this.title,
    this.content,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.destructive = false,
  });

  final String title;
  final Widget? content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h3),
            if (content != null) ...[
              const SizedBox(height: 8),
              DefaultTextStyle(
                style: AppTextStyles.body.copyWith(
                  color: AppColors.ink2,
                  height: 1.4,
                ),
                child: content!,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: TextButton(
                      onPressed: onCancel ?? () => Navigator.maybePop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surface2,
                        foregroundColor: AppColors.ink,
                      ),
                      child: Text(cancelLabel),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: destructive
                          ? ElevatedButton.styleFrom(
                              backgroundColor: AppColors.critical,
                              padding: EdgeInsets.zero,
                            )
                          : ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(confirmLabel),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
