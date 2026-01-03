import '../models/category.dart';

abstract class ICategoriesRepository {
  Stream<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);

  Future<Category> addCategory(Category category);

  Future<void> deleteCategory(int id);
  Future<void> updateCategory(Category category);

  Future<void> incFlashcardCount(int categoryId);
  Future<void> decFlashcardCount(int categoryId);
}