import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app_colors.dart';
import 'app/catalog_controller.dart';
import 'app/shopping_controller.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/wishlist_screen.dart';
import 'services/local_database.dart';
import 'services/product_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;
  try {
    await LocalDatabase.instance.database;
    Get.put(ProductApi(), permanent: true);
    Get.put(ShoppingController(LocalDatabase.instance), permanent: true);
  } catch (error) {
    startupError = error.toString();
  }
  runApp(ShoppingHubApp(startupError: startupError));
}

class ShoppingHubApp extends StatelessWidget {
  const ShoppingHubApp({required this.startupError, super.key});

  final String? startupError;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ShoppingHub',
      debugShowCheckedModeBanner: false,
      initialRoute: startupError == null ? '/login' : '/startup-error',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => CatalogController(Get.find<ProductApi>()));
          }),
        ),
        GetPage(name: '/wishlist', page: () => const WishlistScreen()),
        GetPage(
          name: '/detail/:id',
          page: () => DetailScreen(productId: int.parse(Get.parameters['id']!)),
        ),
        GetPage(
          name: '/startup-error',
          page: () => _StartupError(error: startupError ?? 'Unknown error'),
        ),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.cream,
          primary: AppColors.black,
          onPrimary: AppColors.white,
          secondary: AppColors.cream,
          onSecondary: AppColors.black,
          surface: AppColors.white,
          onSurface: AppColors.black,
          error: AppColors.black,
          onError: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.black,
          contentTextStyle: TextStyle(color: AppColors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.creamBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.creamBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.cream, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storage_rounded, size: 44),
            const SizedBox(height: 12),
            const Text(
              'Unable to open the local database.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
