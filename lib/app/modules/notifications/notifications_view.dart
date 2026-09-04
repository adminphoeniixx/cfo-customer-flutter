import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/auth/notifications_badge_service.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/notification.dart';
import '../../data/repositories/account_repository.dart';
import '../../shared/utils/cfo_toast.dart';
import '../../shared/widgets/cfo_app_bar.dart';
import '../../shared/widgets/empty_state.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final _repo = Get.find<AccountRepository>();
  List<AppNotification> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = items.isEmpty);
    try {
      final page = await _repo.notifications();
      items = page.data
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      CfoToast.error('$e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CfoAppBar.editForm(
        title: 'Notifications',
        saveLabel: 'Mark all read',
        onSave: () async {
          await _repo.markAllRead();
          _load();
          Get.find<NotificationsBadgeService>().refresh();
          CfoToast.success('Notifications marked read');
        },
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpace.md),
                itemCount: items.length,
                separatorBuilder: (_, index) => const Divider(),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return ListTile(
                    leading: Icon(
                      n.isRead ? Icons.notifications_none : Icons.notifications,
                      color: n.isRead ? Colors.grey : Colors.pink,
                    ),
                    title: Text(
                      n.title ?? 'Notification',
                      style: TextStyle(
                        fontWeight: n.isRead
                            ? FontWeight.normal
                            : FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(n.body ?? ''),
                    trailing: Text(formatDate(n.createdAt)),
                    onTap: () async {
                      if (!n.isRead) {
                        await _repo.markRead(n.id);
                        Get.find<NotificationsBadgeService>().refresh();
                      }
                      _load();
                    },
                  );
                },
              ),
            ),
    );
  }
}
