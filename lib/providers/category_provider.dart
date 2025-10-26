import 'package:flutter/material.dart';
import '../controllers/category_controller.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryController _controller = CategoryController(CategoryService());

  List<Map<String, String>> categories = [];
  bool isLoading = false;

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      categories = await _controller.getCategories();
    } catch (e) {
      debugPrint("Error loading categories: $e");
      categories = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
