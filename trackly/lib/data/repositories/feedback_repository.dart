import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FeedbackRepository {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> sendFeedback({required String message, File? image}) async {
    final uid = _auth.currentUser?.uid;
    String? imageUrl;

    if (image != null) {
      final ref = _storage.ref().child(
        'feedback/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    }

    await _db.collection('feedback').add({
      'userId': uid,
      'message': message,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
