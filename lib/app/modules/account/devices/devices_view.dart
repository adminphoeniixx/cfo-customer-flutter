import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/cfo_app_bar.dart';

class DevicesView extends StatefulWidget {
  const DevicesView({super.key});

  @override
  State<DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends State<DevicesView> {
  final _repo = Get.find<AccountRepository>();
  List<dynamic> devices = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = devices.isEmpty);
    try {
      devices = await _repo.devices();
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _revoke(String tokenId) async {
    try {
      await _repo.revokeDevice(tokenId);
      _load();
    } catch (e) {
      CfoToast.error('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CfoAppBar(title: 'Signed-in devices'),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : devices.isEmpty
          ? const EmptyState(
              icon: Icons.devices_other_outlined,
              title: 'No other devices',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpace.md),
              itemCount: devices.length,
              itemBuilder: (context, i) {
                final d = Map<String, dynamic>.from(devices[i]);
                final tokenId = '${d['id'] ?? d['token']}';
                final isCurrent = d['is_current'] == true;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.smartphone_outlined),
                    title: Text(
                      '${d['device_name'] ?? d['name'] ?? 'Unknown device'}',
                    ),
                    subtitle: Text(
                      isCurrent ? 'This device' : '${d['last_used_at'] ?? ''}',
                    ),
                    trailing: isCurrent
                        ? null
                        : IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: AppColors.critical,
                            ),
                            onPressed: () => _revoke(tokenId),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
