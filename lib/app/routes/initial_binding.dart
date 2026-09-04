import 'package:get/get.dart';
import '../core/cache/cache_service.dart';
import '../core/network/api_client.dart';
import '../data/repositories/account_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/checkout_repository.dart';
import '../data/repositories/orders_repository.dart';
import '../data/repositories/payments_repository.dart';
import '../data/repositories/requests_repository.dart';

/// Puts every app-wide singleton in place before the first route builds.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiClient(), permanent: true);
    Get.put(CacheService.instance, permanent: true);

    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => CatalogRepository(), fenix: true);
    Get.lazyPut(() => CartRepository(), fenix: true);
    Get.lazyPut(() => CheckoutRepository(), fenix: true);
    Get.lazyPut(() => OrdersRepository(), fenix: true);
    Get.lazyPut(() => PaymentsRepository(), fenix: true);
    Get.lazyPut(() => RequestsRepository(), fenix: true);
    Get.lazyPut(() => AccountRepository(), fenix: true);
  }
}
