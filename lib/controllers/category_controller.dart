import '../services/category_service.dart';

class CategoryController {
  final CategoryService _service;

  CategoryController(this._service);

  Future<List<Map<String, String>>> getCategories() async {
    return await _service.fetchCategories();
  }
}
