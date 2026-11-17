import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/app_colors.dart';
import '../app/shopping_controller.dart';
import '../widgets/product_widgets.dart';

class WishlistScreen extends GetView<ShoppingController> {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Wishlist',
            style: TextStyle(fontWeight: FontWeight.w700),
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
          selectedIndex: 1,
          onDestinationSelected: (index) {
            if (index == 0) Get.back();
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
          final products = controller.wishlist.toList(growable: false);
          if (products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 84,
                      width: 84,
                      decoration: const BoxDecoration(
                        color: AppColors.paleGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 38,
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Your wishlist is empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Save products you like to find them again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mutedBlack),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: () => Get.back(),
                      child: const Text('Browse products'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ProductGrid(
            products: products,
            onProductTap: (product) => Get.toNamed('/detail/${product.id}'),
          );
        }),
      );
}
