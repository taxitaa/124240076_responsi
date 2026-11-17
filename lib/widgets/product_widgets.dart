import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/app_colors.dart';
import '../app/shopping_controller.dart';
import '../models/product.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    required this.products,
    required this.onProductTap,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext _) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No products found.',
            style: TextStyle(color: AppColors.mutedBlack),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.63,
      ),
      itemCount: products.length,
      itemBuilder: (_, index) {
        final product = products[index];
        final controller = Get.find<ShoppingController>();
        return Obx(
          () => ProductCard(
            product: product,
            isWishlisted: controller.isWishlisted(product.id),
            onTap: () => onProductTap(product),
            onWishlistTap: () async {
              try {
                final added = await controller.toggleWishlist(product);
                Get.snackbar(
                  'Wishlist',
                  added
                      ? 'Product added to wishlist.'
                      : 'Product removed from wishlist.',
                  backgroundColor:
                      added ? AppColors.success : AppColors.danger,
                  colorText: AppColors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(14),
                );
              } catch (error) {
                Get.snackbar(
                  'Wishlist',
                  'Update failed: $error',
                  backgroundColor: AppColors.danger,
                  colorText: AppColors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          ),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistTap,
    super.key,
  });

  final Product product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.creamBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(12),
                    child: Hero(
                      tag: 'product-${product.id}',
                      child: Image.network(
                        product.thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.mutedBlack,
                          size: 38,
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: AppColors.white.withValues(alpha: 0.94),
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: isWishlisted
                            ? 'Remove from wishlist'
                            : 'Add to wishlist',
                        onPressed: onWishlistTap,
                        icon: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isWishlisted
                              ? AppColors.heartRed
                              : AppColors.mutedBlack,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _humanize(product.category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.mutedBlack,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: AppColors.cream,
                        ),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String humanizeCategory(String value) => _humanize(value);

String _humanize(String value) => value
    .split(RegExp(r'[-_\s]+'))
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
