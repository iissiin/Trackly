import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackly/data/models/category_model.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<CategoryModel> createCategory(String name) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final id = const Uuid().v4();
    final category = CategoryModel(id: id, userId: uid, name: name);
    await _categories(uid).doc(id).set(category.toJson());
    return category;
  }

  Future<void> updateCategory(String id, String newName) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _categories(uid).doc(id).update({'name': newName});
  }

  Future<void> deleteCategory(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _categories(uid).doc(id).delete();
  }
}
