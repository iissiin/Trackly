import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackly/data/models/category_model.dart';

class CategoryRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _categories(String uid) =>
      _db.collection('users').doc(uid).collection('categories');

  Stream<List<CategoryModel>> watchCategories(String uid) {
    return _categories(uid).snapshots().map(
      (snap) =>
          snap.docs.map((d) => CategoryModel.fromJson(d.data(), d.id)).toList(),
    );
  }

  Future<void> createCategory(CategoryModel category) async {
    await _categories(category.userId).doc(category.id).set(category.toJson());
  }

  Future<void> deleteCategory(String uid, String categoryId) async {
    await _categories(uid).doc(categoryId).delete();
  }
}
