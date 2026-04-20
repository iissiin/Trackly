import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackly/data/models/completion_model.dart';
import 'package:trackly/data/models/tracker_model.dart';

class TrackerRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _trackers(String uid) =>
      _db.collection('users').doc(uid).collection('trackers');

  CollectionReference<Map<String, dynamic>> _completions(String uid) =>
      _db.collection('users').doc(uid).collection('completions');

  Stream<List<TrackerModel>> watchTrackers(String uid) {
    return _trackers(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => TrackerModel.fromJson(d.data(), d.id))
              .toList(),
        );
  }

  Future<void> createTracker(TrackerModel tracker) async {
    await _trackers(tracker.userId).doc(tracker.id).set(tracker.toJson());
  }

  Future<void> updateTracker(TrackerModel tracker) async {
    await _trackers(tracker.userId).doc(tracker.id).update(tracker.toJson());
  }

  Future<void> deleteTracker(String uid, String trackerId) async {
    await _trackers(uid).doc(trackerId).delete();
    final completions = await _completions(
      uid,
    ).where('trackerId', isEqualTo: trackerId).get();
    for (final doc in completions.docs) {
      await doc.reference.delete();
    }
  }

  Stream<List<CompletionModel>> watchCompletions(String uid, DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return _completions(uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => CompletionModel.fromJson(d.data(), d.id))
              .toList(),
        );
  }

  Future<void> markDone(String uid, String trackerId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final id = '${trackerId}_${dateOnly.toIso8601String()}';
    final model = CompletionModel(
      id: id,
      trackerId: trackerId,
      userId: uid,
      date: dateOnly,
    );
    await _completions(uid).doc(id).set(model.toJson());
  }

  Future<void> unmarkDone(String uid, String trackerId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final id = '${trackerId}_${dateOnly.toIso8601String()}';
    await _completions(uid).doc(id).delete();
  }
}
