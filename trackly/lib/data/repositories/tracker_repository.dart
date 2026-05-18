import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackly/core/services/notification/notification_service.dart';
import 'package:trackly/data/models/completion_model.dart';
import 'package:trackly/data/models/tracker_model.dart';

class TrackerRepository {
  final _db = FirebaseFirestore.instance;
  final _notificationService = NotificationService();

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
    await _scheduleNotifications(tracker);
  }

  Future<void> updateTracker(TrackerModel tracker) async {
    await _trackers(tracker.userId).doc(tracker.id).update(tracker.toJson());
    await _notificationService.cancelTrackerNotifications(tracker.id);
    await _scheduleNotifications(tracker);
  }

  Future<void> deleteTracker(String uid, String trackerId) async {
    await _trackers(uid).doc(trackerId).delete();
    await _notificationService.cancelTrackerNotifications(trackerId);

    final completions = await _completions(
      uid,
    ).where('trackerId', isEqualTo: trackerId).get();
    for (final doc in completions.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _scheduleNotifications(TrackerModel tracker) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await _db.collection('users').doc(uid).get();
    final notificationsEnabled =
        userDoc.data()?['notificationsEnabled'] ?? true;

    if (!notificationsEnabled) {
      return;
    }

    if (tracker.reminderTime != null && tracker.type == TrackerType.habit) {
      final weekdays = tracker.schedule.map((day) => day.index + 1).toList();

      await _notificationService.scheduleTrackerReminder(
        trackerId: tracker.id,
        title: tracker.title,
        emoji: tracker.emoji,
        time: tracker.reminderTime!,
        weekdays: weekdays,
      );
    }

    if (tracker.deadlineDate != null && tracker.type == TrackerType.irregular) {
      await _notificationService.scheduleDeadlineReminder(
        trackerId: tracker.id,
        title: tracker.title,
        emoji: tracker.emoji,
        deadline: tracker.deadlineDate!,
      );
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
