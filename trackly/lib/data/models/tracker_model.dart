import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trackly/data/models/completion_model.dart';

enum TrackerType { habit, irregular }

enum TrackerFilter { active, completed, missed }

enum Weekday { mon, tue, wed, thu, fri, sat, sun }

class TrackerModel {
  final String id;
  final String userId;
  final String title;
  final String emoji;
  final String colorHex;
  final TrackerType type;
  final String? categoryId;
  final DateTime createdAt;
  final List<Weekday> schedule;
  final DateTime? deadlineDate;
  final TimeOfDay? reminderTime;

  const TrackerModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.emoji,
    required this.colorHex,
    required this.type,
    required this.createdAt,
    this.categoryId,
    this.schedule = const [],
    this.deadlineDate,
    this.reminderTime,
  });

  factory TrackerModel.fromJson(Map<String, dynamic> json, String id) {
    TimeOfDay? reminderTime;
    if (json['reminderHour'] != null && json['reminderMinute'] != null) {
      reminderTime = TimeOfDay(
        hour: json['reminderHour'] as int,
        minute: json['reminderMinute'] as int,
      );
    }

    return TrackerModel(
      id: id,
      userId: json['userId'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      colorHex: json['colorHex'] as String,
      type: TrackerType.values.byName(json['type'] as String),
      categoryId: json['categoryId'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      schedule: (json['schedule'] as List<dynamic>? ?? [])
          .map((e) => Weekday.values.byName(e as String))
          .toList(),
      deadlineDate: json['deadlineDate'] != null
          ? (json['deadlineDate'] as Timestamp).toDate()
          : null,
      reminderTime: reminderTime,
    );
  }

  Null get name => null;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'title': title,
    'emoji': emoji,
    'colorHex': colorHex,
    'type': type.name,
    'categoryId': categoryId,
    'createdAt': Timestamp.fromDate(createdAt),
    'schedule': schedule.map((e) => e.name).toList(),
    'deadlineDate': deadlineDate != null
        ? Timestamp.fromDate(deadlineDate!)
        : null,
    'reminderHour': reminderTime?.hour,
    'reminderMinute': reminderTime?.minute,
  };

  TrackerModel copyWith({
    String? title,
    String? emoji,
    String? colorHex,
    String? categoryId,
    List<Weekday>? schedule,
    DateTime? deadlineDate,
    TimeOfDay? reminderTime,
    bool clearReminder = false,
  }) {
    return TrackerModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      type: type,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt,
      schedule: schedule ?? this.schedule,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      reminderTime: clearReminder ? null : reminderTime ?? this.reminderTime,
    );
  }

  bool isScheduledFor(DateTime date) {
    if (type == TrackerType.irregular) return true;
    final weekday = Weekday.values[date.weekday - 1];
    return schedule.contains(weekday);
  }

  TrackerFilter statusFor(DateTime date, List<CompletionModel> completions) {
    final done = completions.any(
      (c) =>
          c.trackerId == id &&
          c.date.year == date.year &&
          c.date.month == date.month &&
          c.date.day == date.day,
    );
    if (done) return TrackerFilter.completed;

    if (type == TrackerType.habit) {
      final scheduled = isScheduledFor(date);
      final isPast = date.isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );
      if (scheduled && isPast) return TrackerFilter.missed;
      return TrackerFilter.active;
    } else {
      if (deadlineDate != null && deadlineDate!.isBefore(DateTime.now())) {
        return TrackerFilter.missed;
      }
      return TrackerFilter.active;
    }
  }
}
