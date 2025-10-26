import 'package:amazon/providers/category_provider.dart';
import 'package:amazon/providers/orders_provider.dart';
import 'package:amazon/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'routes.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/profile_provider.dart';
import 'views/authViews/login_view.dart';
import 'views/main_home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Amazon Clone',
            onGenerateRoute: Routes.generateRoute, // ✅ Correct usage
            home: _buildHome(authProvider),
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    if (authProvider.isInitializing) {
      return const SplashView(); // ⏳ while Firebase restores session
    }

    if (authProvider.user != null) {
      return const MainHomeView(); // ✅ logged in
    }

    return  LoginView(); // 🔒 not logged in
  }
}
