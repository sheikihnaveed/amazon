import 'package:amazon/views/product_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/category_icon.dart';
import '../core/constants.dart';
import '../widgets/universal_search_bar.dart';
import 'category_products_view.dart'; // 👈 Add this import

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProductProvider>(context, listen: false).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: const UniversalSearchBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟦 Top Location Section
            Container(
              color: const Color(0xFFB8E5E5),
              padding: const EdgeInsets.all(8),
              child: const Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.black54),
                  SizedBox(width: 4),
                  Text(
                    "Deliver to Sheikh – Srinagar 190010",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 18),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🧭 Categories List
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  final categoryName = categoriesList[index];
                  final categoryImage = categoryLogos[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoryProductsView(category: categoryName),
                        ),
                      );
                    },
                    child: CategoryIcon(
                      title: categoryName,
                      imageUrl: categoryImage,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // 🛒 Product List Section
            Expanded(
              child: Container(
                color: Colors.white,
                child: productProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];

                    return ProductCard(
                      product: product,
                      onAddToCart: () {
                        cartProvider.addToCart(product, quantity: 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            Text("${product.name} added to cart"),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailView(product: product),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
