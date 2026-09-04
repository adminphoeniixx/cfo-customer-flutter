import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_content.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
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
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${data['title'] ?? page.title}', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Text('${data['body'] ?? ''}', style: AppTextStyles.body),
                ],
              ),
            ),
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
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brand, Color(0xFFF15A24)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'C',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.onBrand,
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
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
            const Text(
              '›',
              style: TextStyle(
                color: AppColors.ink3,
                fontSize: 18,
                height: 1,
                fontFamily: 'Roboto',
              ),
            ),
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
        border: Border.all(color: AppColors.line),
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
