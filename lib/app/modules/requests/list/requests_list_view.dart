import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/request_item.dart';
import '../../../data/repositories/requests_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/order_status_pill.dart';
import '../../../shared/widgets/pill_badge.dart';
import '../../../shared/widgets/cfo_app_bar.dart';

class RequestsListView extends StatefulWidget {
  const RequestsListView({super.key});

  @override
  State<RequestsListView> createState() => _RequestsListViewState();
}

class _RequestsListViewState extends State<RequestsListView> {
  final _repo = Get.find<RequestsRepository>();
  List<RequestItem> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = items.isEmpty);
    try {
      final page = await _repo.list();
      items = page.data;
    } catch (e) {
      CfoToast.error('$e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CfoAppBar(title: 'Cancellations & Returns'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const EmptyState(
              icon: Icons.assignment_return_outlined,
              title: 'No requests yet',
              message: 'Cancellations and returns you raise will show up here.',
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpace.md),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final r = items[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => Get.toNamed(
                        AppRoutes.requestDetail,
                        arguments: {'number': r.number},
                      )?.then((_) => _load()),
                      title: Row(
                        children: [
                          PillBadge(
                            label: r.isCancellation ? 'Cancellation' : 'Return',
                          ),
                          const SizedBox(width: 6),
                          Text('#${r.number}', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      subtitle: Text(
                        'Order #${r.orderNumber ?? r.orderId} · ${formatDate(r.createdAt)}',
                      ),
                      trailing: OrderStatusPill(
                        status: r.status,
                        label: r.status,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
