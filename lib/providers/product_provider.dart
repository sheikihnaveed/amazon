import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<Product> _products = [];
  List<Product> get products => _products;

  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;

  bool isLoading = false;

  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    _products = await _service.fetchProducts();

    isLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await fetchProducts();
      return;
    }

    isLoading = true;
    notifyListeners();

    _products = await _service.searchProducts(query);

    isLoading = false;
    notifyListeners();
  }

  // ✅ Fetch single product by ID or name
  Future<void> fetchProductById(String id) async {
    isLoading = true;
    notifyListeners();

    _selectedProduct = await _service.fetchProductById(id);

    isLoading = false;
    notifyListeners();
  }

  // ✅ Fetch all products for a given category
  Future<void> fetchProductsByCategory(String category) async {
    isLoading = true;
    notifyListeners();

    try {
      print("Fetching products for category: $category");
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(category.toLowerCase())
          .get();

      if (!doc.exists) {
        print("No document found for $category");
        _products = [];
      } else {
        final data = doc.data()!;
        List<Product> loadedProducts = [];

        // 🔹 Loop through all fields in the document
        data.forEach((key, value) {
          if (value is List) {
            for (var item in value) {
              loadedProducts.add(Product(
                id: key,
                name: item['name'] ?? '',
                description: item['description'] ?? '',
                imageUrl: item['imageUrl'] ?? '',
                price: (item['price'] ?? 0).toDouble(),
              ));
            }
          }
        });

        _products = loadedProducts;
        print("Loaded ${_products.length} products from $category");
      }
    } catch (e) {
      print("Error fetching products for $category: $e");
      _products = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}
