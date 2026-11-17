import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/app_colors.dart';
import '../app/shopping_controller.dart';
import '../models/product.dart';
import '../services/product_api.dart';
import '../widgets/product_widgets.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    required this.productId,
    super.key,
  });

  final int productId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Product> _productFuture;

  ShoppingController get _controller => Get.find<ShoppingController>();

  @override
  void initState() {
    super.initState();
    _productFuture = Get.find<ProductApi>().getProduct(widget.productId);
  }

  void _retry() {
    setState(() {
      _productFuture = Get.find<ProductApi>().getProduct(widget.productId);
    });
  }

  Future<void> _toggleWishlist(Product product) async {
    try {
      final added = await _controller.toggleWishlist(product);
      if (!mounted) return;
      Get.snackbar(
        'Wishlist',
        added
            ? 'Product added to wishlist.'
            : 'Product removed from wishlist.',
        backgroundColor: added ? AppColors.success : AppColors.danger,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(14),
      );
    } catch (error) {
      if (!mounted) return;
      Get.snackbar(
        'Wishlist',
        'Update failed: $error',
        backgroundColor: AppColors.danger,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 46),
                    const SizedBox(height: 12),
                    const Text('Failed to load product details.'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retry,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final product = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: Image.network(
                          product.thumbnail,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 58,
                            color: AppColors.mutedBlack,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        _Tag(label: humanizeCategory(product.category)),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.cream,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating.toStringAsFixed(1)} rating',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                    ),
                    if (product.brand != null && product.brand!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Brand: ${product.brand}',
                        style: const TextStyle(color: AppColors.mutedBlack),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(width: 10),
                        _Tag(
                          label:
                              '${product.discountPercentage.toStringAsFixed(1)}% OFF',
                          background: AppColors.paleGold,
                          foreground: AppColors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 18),
                    const Text(
                      'Description',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(
                        color: AppColors.mutedBlack,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 19,
                          color: AppColors.cream,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.stock > 0
                              ? 'In stock: ${product.stock}'
                              : 'Out of stock',
                          style: TextStyle(
                            color: product.stock > 0
                                ? AppColors.mutedBlack
                                : AppColors.cream,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                  child: Obx(() {
                    final isWishlisted = _controller.isWishlisted(product.id);
                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () => _toggleWishlist(product),
                        icon: Icon(
                          isWishlisted
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isWishlisted ? AppColors.heartRed : null,
                        ),
                        label: Text(
                          isWishlisted
                              ? 'Remove from wishlist'
                              : 'Add to wishlist',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: isWishlisted
                              ? AppColors.cream
                              : AppColors.black,
                          foregroundColor: isWishlisted
                              ? AppColors.black
                              : AppColors.white,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    this.background = AppColors.paleGold,
    this.foreground = AppColors.black,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
