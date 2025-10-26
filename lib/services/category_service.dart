
import '../core/constants.dart';

class CategoryService {
  /// Fetch static categories (you can connect Firestore later)
  Future<List<Map<String, String>>> fetchCategories() async {
    await Future.delayed(const Duration(milliseconds: 200)); // simulate delay
    return List.generate(categoriesList.length, (index) {
      return {
        'name': categoriesList[index],
        'logo': categoryLogos[index],
      };
    });
  }
}
