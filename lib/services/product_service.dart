import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final CollectionReference _productsRef =
  FirebaseFirestore.instance.collection('products');

  // ✅ Fetch all products from nested categories
  Future<List<Product>> fetchProducts() async {
    final snapshot = await _productsRef.get();
    List<Product> allProducts = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      for (var key in data.keys) {
        final categoryData = data[key];
        if (categoryData is List) {
          for (var item in categoryData) {
            if (item is Map<String, dynamic>) {
              allProducts.add(Product.fromMap(item, doc.id));
            }
          }
        }
      }
    }
    return allProducts;
  }

  // ✅ Fetch single product by name or ID
  Future<Product?> fetchProductById(String id) async {
    final snapshot = await _productsRef.get();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      for (var key in data.keys) {
        final categoryData = data[key];
        if (categoryData is List) {
          for (var item in categoryData) {
            if (item is Map<String, dynamic>) {
              // Check match by id or name
              if (item['id'] == id || item['name'] == id) {
                return Product.fromMap(item, doc.id);
              }
            }
          }
        }
      }
    }
    return null;
  }

  // ✅ Local search
  Future<List<Product>> searchProducts(String query) async {
    final allProducts = await fetchProducts();
    final lowerQuery = query.toLowerCase();

    return allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
