import 'package:get/get.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/network/app_exception.dart';
import '../../../data/models/order.dart';
import '../../../data/models/request_item.dart';
import '../../../data/repositories/orders_repository.dart';
import '../../../data/repositories/requests_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/utils/cfo_toast.dart';
import '../../cart/cart_controller.dart';

class OrdersListController extends GetxController {
  final OrdersRepository _repo = Get.find<OrdersRepository>();
  final RequestsRepository _requestsRepo = Get.find<RequestsRepository>();
  final AuthService _auth = Get.find<AuthService>();

  final RxBool loading = true.obs;
  final RxList<Order> orders = <Order>[].obs;
  final RxList<RequestItem> requests = <RequestItem>[].obs;
  final RxString filter = 'all'.obs;
  final RxString reorderingNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_auth.isLoggedIn, (_) => load());
    load();
  }

  Future<void> load() async {
    if (!_auth.isLoggedIn.value) {
      orders.clear();
      requests.clear();
      loading.value = false;
      return;
    }
    loading.value = orders.isEmpty && requests.isEmpty;
    try {
      final page = await _repo.list(filter: filter.value);
      orders.assignAll(page.data);
      final requestPage = await _requestsRepo.list();
      requests.assignAll(requestPage.data);
    } catch (_) {
      if (orders.isEmpty && requests.isEmpty) {
        orders.clear();
        requests.clear();
      }
      CfoToast.error('Could not load orders. Please try again.');
    } finally {
      loading.value = false;
    }
  }

  void setFilter(String f) {
    filter.value = f;
    load();
  }

  Future<void> buyAgain(String number) async {
    if (reorderingNumber.value.isNotEmpty) return;
    reorderingNumber.value = number;
    try {
      final result = await _repo.reorder(number);
      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().load();
      }
      CfoToast.success(
        '${result.added.length} item(s) added${result.skipped.isNotEmpty ? ', ${result.skipped.length} skipped' : ''}.',
      );
      Get.toNamed(AppRoutes.cart);
    } on AppException catch (e) {
      CfoToast.error(e.message);
    } finally {
      reorderingNumber.value = '';
    }
  }
}
