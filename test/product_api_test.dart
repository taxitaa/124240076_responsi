import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:responsi/models/product.dart';
import 'package:responsi/services/product_api.dart';

void main() {
  group('ProductApi', () {
    test('requests the product catalog with a 100 product limit', () async {
      final api = ProductApi(
        client: MockClient((request) async {
          expect(request.url.path, '/products');
          expect(request.url.queryParameters['limit'], '100');
          return http.Response(
            jsonEncode({
              'products': [
                {
                  'id': 8,
                  'title': 'Satu produk',
                  'category': 'beauty',
                  'price': 12.5,
                  'thumbnail': 'https://example.com/product.png',
                },
              ],
            }),
            200,
          );
        }),
      );

      final products = await api.getProducts();

      expect(products, hasLength(1));
      expect(products.single.id, 8);
      expect(products.single.price, 12.5);
    });

    test('loads categories from the category list endpoint', () async {
      final api = ProductApi(
        client: MockClient((request) async {
          expect(request.url.path, '/products/category-list');
          return http.Response(jsonEncode(['beauty', 'fragrances']), 200);
        }),
      );

      expect(await api.getCategories(), ['beauty', 'fragrances']);
    });

    test('loads a product by ID and reports unsuccessful responses', () async {
      final api = ProductApi(
        client: MockClient((request) async {
          expect(request.url.path, '/products/42');
          return http.Response(
            jsonEncode({
              'id': 42,
              'title': 'Detail',
              'category': 'beauty',
              'brand': 'Acme',
              'price': 24,
              'rating': 4.5,
              'description': 'Deskripsi',
              'discountPercentage': 10,
              'stock': 6,
              'thumbnail': 'https://example.com/detail.png',
            }),
            200,
          );
        }),
      );

      final product = await api.getProduct(42);

      expect(product.id, 42);
      expect(product.brand, 'Acme');
      expect(product.discountPercentage, 10);
      expect(product.stock, 6);

      final failingApi = ProductApi(
        client: MockClient((_) async => http.Response('not found', 404)),
      );
      await expectLater(
        failingApi.getProduct(42),
        throwsA(isA<http.ClientException>()),
      );
    });
  });

  test('product data survives JSON conversion for local wishlist storage', () {
    final product = Product.fromJson({
      'id': 3,
      'title': 'Saved',
      'category': 'home-decoration',
      'price': 9.99,
      'rating': 4.2,
      'description': 'Local copy',
      'discountPercentage': 2.5,
      'stock': 4,
      'thumbnail': 'https://example.com/saved.png',
      'brand': 'Store',
      'images': ['https://example.com/large.png'],
    });

    final restored = Product.fromJson(product.toJson());

    expect(restored.id, product.id);
    expect(restored.title, product.title);
    expect(restored.category, product.category);
    expect(restored.images, product.images);
    expect(restored.brand, product.brand);
  });
}
