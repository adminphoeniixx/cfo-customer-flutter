import 'package:get/get.dart';

class NavController extends GetxController {
  final RxInt tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['tab'] is int) {
      tabIndex.value = (args['tab'] as int).clamp(0, 4);
    }
  }

  void changeTab(int i) => tabIndex.value = i;
}
