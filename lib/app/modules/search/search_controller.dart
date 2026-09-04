import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/product.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../shared/utils/cfo_toast.dart';

class AppSearchController extends GetxController {
  final CatalogRepository _repo = Get.find<CatalogRepository>();

  final RxString query = ''.obs;
  final RxList<ProductCardModel> suggestions = <ProductCardModel>[].obs;
  final RxBool loading = false.obs;
  Timer? _debounce;

  void onQueryChanged(String q) {
    query.value = q;
    _debounce?.cancel();
    if (q.trim().length < 2) {
      suggestions.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      loading.value = true;
      try {
        suggestions.assignAll(await _repo.suggestions(q));
      } catch (e) {
        CfoToast.error('Could not load suggestions.');
      } finally {
        loading.value = false;
      }
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
