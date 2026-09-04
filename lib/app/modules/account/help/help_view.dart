import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_content.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/cfo_app_bar.dart';
import '../../../shared/widgets/prototype_image.dart';
import 'package:get/get.dart';

class HelpView extends StatefulWidget {
  const HelpView({super.key});

  @override
  State<HelpView> createState() => _HelpViewState();
}

class _HelpViewState extends State<HelpView> {
  final _repo = Get.find<AccountRepository>();
  SupportConfig? config;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final next = await _repo.supportConfig();
      if (!mounted) return;
      setState(() {
        config = next;
        loading = false;
      });
    } catch (e) {
      CfoToast.error('$e');
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: const CfoAppBar(title: 'Help centre'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        children: [
          _FlatCard(
            children: [
              if (config?.chatEnabled == true)
                _HelpRow(
                  icon: '💬',
                  title: 'Chat with us',
                  subtitle: 'Usually answers in under 2 minutes',
                  onTap: () => CfoToast.show(config!.chatSessionUrl ?? ''),
                ),
              if ((config?.phone ?? '').isNotEmpty)
                _HelpRow(
                  icon: '📞',
                  title: 'Call support',
                  subtitle: [
                    config?.phone,
                    config?.hours,
                  ].where((e) => e != null && e.isNotEmpty).join(' · '),
                  onTap: () => CfoToast.show('Calling ${config!.phone}...'),
                ),
            ],
          ),
          const SizedBox(height: 9),
          const _SectionTitle('Common questions'),
          const SizedBox(height: 9),
          _FlatCard(
            children: [
              for (final faq in config?.faqs ?? <SupportFaq>[])
                _FaqRow(title: faq.question, subtitle: faq.answer),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlatCard extends StatelessWidget {
  final List<Widget> children;

  const _FlatCard({required this.children});

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

class _HelpRow extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            PrototypeImage(source: icon, size: 44, fontSize: 20),
            const SizedBox(width: 11),
            Expanded(
              child: _RowText(title: title, subtitle: subtitle),
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

class _FaqRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FaqRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _RowText(title: title, subtitle: subtitle, wrapSubtitle: true),
    );
  }
}

class _RowText extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool wrapSubtitle;

  const _RowText({
    required this.title,
    required this.subtitle,
    this.wrapSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.5, height: 1.2),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: wrapSubtitle ? 3 : 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(fontSize: 11.5, height: 1.45),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
