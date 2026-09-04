import 'package:get/get.dart';
import '../../data/models/category.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../shared/utils/cfo_toast.dart';

class CategoriesController extends GetxController {
  final CatalogRepository _repo = Get.find<CatalogRepository>();

  final RxBool loading = true.obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = categories.isEmpty;
    try {
      categories.assignAll(await _repo.categories());
    } catch (e) {
      CfoToast.error('Could not load categories. Please try again.');
    } finally {
      loading.value = false;
    }
  }
}
