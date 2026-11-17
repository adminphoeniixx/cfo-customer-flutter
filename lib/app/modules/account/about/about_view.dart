import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_content.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/app_logo.dart';
import 'package:get/get.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  final _repo = Get.find<AccountRepository>();
  List<LegalPageRef> pages = [];
  AppConfig? config;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final nextConfig = await _repo.appConfig();
      final nextPages = await _repo.legalPages();
      if (!mounted) return;
      setState(() {
        config = nextConfig;
        pages = nextPages;
        loading = false;
      });
    } catch (e) {
      CfoToast.error('$e');
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openLegal(LegalPageRef page) async {
    try {
      final data = await _repo.legalPage(page.slug);
      if (!mounted) return;
      AppSheet.show(
        context: context,
        title: '${data['title'] ?? page.title}',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Text(
            '${data['body'] ?? ''}',
            style: AppTextStyles.body.copyWith(height: 1.5),
          ),
        ),
      );
    } catch (e) {
      CfoToast.error('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const CfoAppBar(title: 'About & legal'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 64),
                const SizedBox(height: 8),
                Text(
                  config?.storeName ?? 'CFO Shop',
                  style: AppTextStyles.title.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  config?.supportEmail ?? config?.supportPhone ?? 'Support details unavailable',
                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          _Card(
            children: [
              for (final link in pages)
                _LegalRow(
                  title: link.title,
                  onTap: () => _openLegal(link),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LegalRow({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.5,
                  height: 1.2,
                ),
              ),
            ),
            const Icon(IconsaxPlusLinear.arrow_right_3, size: 18, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, thickness: 1, color: AppColors.lineSoft),
          ],
        ],
      ),
    );
  }
}
