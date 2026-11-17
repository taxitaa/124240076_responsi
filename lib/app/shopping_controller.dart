import 'package:get/get.dart';

import '../models/product.dart';
import '../services/local_database.dart';

class ShoppingController extends GetxController {
  ShoppingController(this._database);

  final LocalDatabase _database;
  final RxnString currentUser = RxnString();
  final RxList<Product> wishlist = <Product>[].obs;

  bool isWishlisted(int productId) =>
      wishlist.any((product) => product.id == productId);

  Future<bool> login(String username, String password) async {
    final normalizedUsername = username.trim();
    if (!await _database.authenticate(normalizedUsername, password)) {
      return false;
    }
    await _setCurrentUser(normalizedUsername);
    return true;
  }

  Future<bool> createAccount(String username, String password) async {
    final normalizedUsername = username.trim();
    return _database.createAccount(normalizedUsername, password);
  }

  Future<void> _setCurrentUser(String username) async {
    final savedWishlist = await _database.getWishlist(username);
    wishlist.assignAll(savedWishlist);
    currentUser.value = username;
  }

  Future<bool> toggleWishlist(Product product) async {
    final username = currentUser.value;
    if (username == null) return false;

    if (isWishlisted(product.id)) {
      await _database.removeFromWishlist(username, product.id);
      wishlist.removeWhere((item) => item.id == product.id);
      return false;
    }

    await _database.addToWishlist(username, product);
    wishlist.add(product);
    return true;
  }

  Future<void> logout() async {
    currentUser.value = null;
    wishlist.clear();
  }
}
