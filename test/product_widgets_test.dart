import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:responsi/app/app_colors.dart';
import 'package:responsi/app/shopping_controller.dart';
import 'package:responsi/models/product.dart';
import 'package:responsi/services/local_database.dart';
import 'package:responsi/widgets/product_widgets.dart';

void main() {
  testWidgets('product cards react to wishlist changes without Obx errors', (
    tester,
  ) async {
    Get.put(ShoppingController(LocalDatabase.instance));
    addTearDown(Get.reset);
    const product = Product(
      id: 1,
      title: 'Produk uji',
      category: 'beauty',
      price: 10,
      rating: 4.5,
      description: '',
      discountPercentage: 0,
      stock: 1,
      thumbnail: 'https://example.com/product.png',
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: ProductGrid(products: const [product], onProductTap: (_) {}),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Add to wishlist'), findsOneWidget);

    Get.find<ShoppingController>().wishlist.add(product);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Remove from wishlist'), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.favorite_rounded)).color,
      AppColors.heartRed,
    );

    Get.find<ShoppingController>().wishlist.remove(product);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Add to wishlist'), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.favorite_border_rounded)).color,
      AppColors.mutedBlack,
    );
  });
}
