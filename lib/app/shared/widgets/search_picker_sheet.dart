import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_icons.dart';
import 'app_sheet.dart';

/// What the shopper picked in a [SearchPickerSheet].
class PickerResult {
  const PickerResult.option(String this.value) : typeOwn = false;
  const PickerResult.typeOwn() : value = null, typeOwn = true;

  final String? value;

  /// The shopper chose the footer action (e.g. "Type your city").
  final bool typeOwn;
}

/// Searchable single-choice list in an [AppSheet] — state / city pickers.
/// [load] is awaited inside the sheet so it can show progress and retry.
class SearchPickerSheet extends StatefulWidget {
  const SearchPickerSheet({
    super.key,
    required this.load,
    this.selected,
    this.searchHint = 'Search',
    this.typeOwnLabel,
  });

  final Future<List<String>> Function() load;
  final String? selected;
  final String searchHint;

  /// When set, a row at the end lets the shopper type a value that is not
  /// in the list.
  final String? typeOwnLabel;

  static Future<PickerResult?> show({
    required String title,
    required Future<List<String>> Function() load,
    String? selected,
    String searchHint = 'Search',
    String? typeOwnLabel,
  }) {
    return AppSheet.show<PickerResult>(
      title: title,
      scrollable: false,
      child: SearchPickerSheet(
        load: load,
        selected: selected,
        searchHint: searchHint,
        typeOwnLabel: typeOwnLabel,
      ),
    );
  }

  @override
  State<SearchPickerSheet> createState() => _SearchPickerSheetState();
}

class _SearchPickerSheetState extends State<SearchPickerSheet> {
  late Future<List<String>> _future = widget.load();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Leave room for the sheet header and the keyboard while searching.
    final room = mq.size.height - mq.viewInsets.bottom - mq.padding.top - 140;
    return SizedBox(
      height: (mq.size.height * 0.62).clamp(220.0, room < 220 ? 220.0 : room),
      child: Column(
        children: [
          TextField(
            autofocus: false,
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: const Icon(AppIcons.search, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return _Message(
                    text: 'Could not load the list.',
                    actionLabel: 'Retry',
                    onAction: () => setState(() => _future = widget.load()),
                  );
                }
                final all = snap.data ?? const <String>[];
                final items = _query.isEmpty
                    ? all
                    : all.where((s) => s.toLowerCase().contains(_query)).toList();
                return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length + (widget.typeOwnLabel == null ? 0 : 1),
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, i) {
                      if (i == items.length) {
                        return ListTile(
                          leading: const Icon(
                            IconsaxPlusLinear.edit_2,
                            color: AppColors.brand,
                            size: 20,
                          ),
                          title: Text(
                            widget.typeOwnLabel!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: items.isEmpty && _query.isNotEmpty
                              ? const Text('Not in the list? Type it yourself.')
                              : null,
                          onTap: () => Navigator.of(context)
                              .pop(const PickerResult.typeOwn()),
                        );
                      }
                      final s = items[i];
                      final on = s.toLowerCase() ==
                          (widget.selected ?? '').toLowerCase();
                      return ListTile(
                        title: Text(
                          s,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                            color: on ? AppColors.brand : AppColors.ink,
                          ),
                        ),
                        trailing: on
                            ? const Icon(
                                IconsaxPlusBold.tick_circle,
                                color: AppColors.brand,
                                size: 20,
                              )
                            : null,
                        onTap: () =>
                            Navigator.of(context).pop(PickerResult.option(s)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: AppTextStyles.body.copyWith(color: AppColors.ink3)),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
