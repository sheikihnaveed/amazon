import 'package:amazon/views/category_view.dart';
import 'package:amazon/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'home_view.dart';
import 'cart_view.dart';

class MainHomeView extends StatefulWidget {
  const MainHomeView({super.key});

  @override
  State<MainHomeView> createState() => _MainHomeViewState();
}

class _MainHomeViewState extends State<MainHomeView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _lastCartCount = 0;
  AnimationController? _controller;

  // ✅ Navigator keys for nested navigation
  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _screens = const [
    HomeView(),
    CategoryView(),
    CartView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.9,
      upperBound: 1.2,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ✅ Handles back button inside each tab
  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab = !await _navigatorKeys[_currentIndex]
        .currentState!
        .maybePop();
    if (isFirstRouteInCurrentTab && _currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }
    return isFirstRouteInCurrentTab;
  }

  // ✅ Trigger bounce animation when cart count changes
  void _triggerBadgeAnimation() {
    if (_controller == null) return;
    _controller!.forward(from: 0.8).then((_) => _controller!.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    // ✅ Detect cart item count change
    if (cartProvider.cartItems.length != _lastCartCount) {
      _lastCartCount = cartProvider.cartItems.length;
      if (cartProvider.cartItems.isNotEmpty) _triggerBadgeAnimation();
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        // ✅ Persistent nav bar with independent tab navigation
        body: Stack(
          children: List.generate(_screens.length, (index) {
            return Offstage(
              offstage: _currentIndex != index,
              child: Navigator(
                key: _navigatorKeys[index],
                onGenerateRoute: (routeSettings) {
                  return MaterialPageRoute(builder: (_) => _screens[index]);
                },
              ),
            );
          }),
        ),

        // ✅ Amazon-style Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              label: "Category",
            ),

            // 🛒 Cart Item with Animated Badge
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (cartProvider.cartItems.isNotEmpty)
                    Positioned(
                      right: -6,
                      top: -2,
                      child: ScaleTransition(
                        scale: _controller ?? AlwaysStoppedAnimation(1.0),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '${cartProvider.cartItems.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: "Cart",
            ),

            const BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
