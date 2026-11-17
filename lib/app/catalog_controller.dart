import 'package:get/get.dart';

import '../models/product.dart';
import '../services/product_api.dart';

class CatalogController extends GetxController {
  CatalogController(this._api);

  final ProductApi _api;
  final RxList<Product> products = <Product>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxnString selectedCategory = RxnString();
  final RxnString loadError = RxnString();
  final RxBool isLoading = true.obs;

  List<Product> get filteredProducts => products
      .where((product) {
        final category = selectedCategory.value;
        return category == null || product.category == category;
      })
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    loadCatalog();
  }

  Future<void> loadCatalog() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final loadedProducts = await _api.getProducts();
      final loadedCategories = await _api.getCategories();
      products.assignAll(loadedProducts);
      categories.assignAll(loadedCategories);
    } catch (error) {
      loadError.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
