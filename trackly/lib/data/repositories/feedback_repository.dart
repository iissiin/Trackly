import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> sendFeedback({required String message}) async {
    final uid = _auth.currentUser?.uid;

    await _db.collection('feedback').add({
      'userId': uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
