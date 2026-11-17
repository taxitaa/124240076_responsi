import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/app_colors.dart';
import '../app/catalog_controller.dart';
import '../app/shopping_controller.dart';
import '../models/product.dart';
import '../widgets/product_widgets.dart';

class HomeScreen extends GetView<ShoppingController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = Get.find<CatalogController>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ShoppingHub',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
            ),
            Obx(
              () => Text(
                'Hello, ${controller.currentUser.value ?? ''}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.mutedBlack,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: () {
              controller.logout();
              Get.offAllNamed('/login');
            },
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) Get.toNamed('/wishlist');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Wishlist',
          ),
        ],
      ),
      body: Obx(() {
        if (catalog.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final loadError = catalog.loadError.value;
        if (loadError != null) {
          return _CatalogError(error: loadError, onRetry: catalog.loadCatalog);
        }

        final products = catalog.filteredProducts;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Text(
                'Discover something you love',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
              child: Text(
                'Great finds for every day.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedBlack,
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  _categoryChip(catalog, 'All', null),
                  ...catalog.categories.map(
                    (category) => _categoryChip(
                      catalog,
                      humanizeCategory(category),
                      category,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 17, 20, 10),
              child: Row(
                children: [
                  Text(
                    catalog.selectedCategory.value == null
                        ? 'All products'
                        : humanizeCategory(catalog.selectedCategory.value!),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${products.length} products',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.mutedBlack,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ProductGrid(
                products: products,
                onProductTap: _openProduct,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _categoryChip(
    CatalogController catalog,
    String label,
    String? category,
  ) {
    final selected = catalog.selectedCategory.value == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => catalog.selectedCategory.value = category,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.black : AppColors.mutedBlack,
        ),
        backgroundColor: AppColors.white,
        selectedColor: AppColors.cream,
        side: BorderSide(
          color: AppColors.creamBorder,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  void _openProduct(Product product) {
    Get.toNamed('/detail/${product.id}');
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppColors.cream,
          ),
          const SizedBox(height: 12),
          const Text(
            'Products could not be loaded',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}
