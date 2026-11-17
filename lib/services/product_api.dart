import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductApi {
  ProductApi({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _baseUri = Uri.parse('https://dummyjson.com');
  final http.Client _client;

  Future<List<Product>> getProducts() async {
    final response = await _client.get(_baseUri.replace(
      path: '/products',
      queryParameters: {'limit': '100'},
    ));
    _checkResponse(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final products = body['products'] as List<dynamic>;
    return products
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<String>> getCategories() async {
    final response = await _client.get(
      _baseUri.replace(path: '/products/category-list'),
    );
    _checkResponse(response);
    return (jsonDecode(response.body) as List<dynamic>)
        .whereType<String>()
        .toList(growable: false);
  }

  Future<Product> getProduct(int id) async {
    final response = await _client.get(
      _baseUri.replace(path: '/products/$id'),
    );
    _checkResponse(response);
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'The server returned status ${response.statusCode}.',
      );
    }
  }
}
