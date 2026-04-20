import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackly/data/models/user_model.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    if (!doc.exists || doc.data() == null) return null;

    return UserModel.fromMap(firebaseUser.uid, doc.data()!);
  }
}
