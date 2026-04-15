import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/data/repositories/category_repository.dart';
import 'package:trackly/data/repositories/tracker_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

// MARK: State

class CreateTrackerState {
  final Map<String, String> categoryMap;
  final String title;
  final String emoji;
  final String colorHex;
  final TrackerType type;
  final String? categoryId;
  final List<Weekday> schedule;
  final DateTime? deadlineDate;
  final TimeOfDay? reminderTime;
  final bool isSubmitting;
  final String? error;

  const CreateTrackerState({
    this.title = '',
    this.emoji = '🍀',
    this.colorHex = '5A7A5E',
    this.type = TrackerType.habit,
    this.categoryId,
    this.categoryMap = const {},
    this.schedule = const [],
    this.deadlineDate,
    this.reminderTime,
    this.isSubmitting = false,
    this.error,
  });

  bool get isValid =>
      title.trim().isNotEmpty &&
      (type == TrackerType.irregular || schedule.isNotEmpty);

  CreateTrackerState copyWith({
    String? title,
    String? emoji,
    String? colorHex,
    TrackerType? type,
    String? categoryId,
    bool clearCategory = false,
    Map<String, String>? categoryMap,
    List<Weekday>? schedule,
    DateTime? deadlineDate,
    TimeOfDay? reminderTime,
    bool clearReminder = false,
    bool? isSubmitting,
    String? error,
  }) {
    return CreateTrackerState(
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categoryMap: categoryMap ?? this.categoryMap,
      schedule: schedule ?? this.schedule,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

// MARK: Cubit

class CreateTrackerCubit extends Cubit<CreateTrackerState> {
  final TrackerRepository _repo;
  final CategoryRepository _catRepo = CategoryRepository();

  CreateTrackerCubit(this._repo) : super(const CreateTrackerState());

  void setReminderTime(TimeOfDay? t) {
    if (t == null) {
      emit(state.copyWith(clearReminder: true));
    } else {
      emit(state.copyWith(reminderTime: t));
    }
  }

  void setTitle(String v) => emit(state.copyWith(title: v));
  void setEmoji(String v) => emit(state.copyWith(emoji: v));
  void setColor(String hex) => emit(state.copyWith(colorHex: hex));
  void setType(TrackerType v) =>
      emit(state.copyWith(type: v, schedule: [], deadlineDate: null));
  void setDeadline(DateTime? d) => emit(state.copyWith(deadlineDate: d));

  void setCategory(String? id) {
    if (id == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(categoryId: id));
    }
  }

  void loadCategories() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final list = await _catRepo.watchCategories(uid).first;
    final map = {for (var item in list) item.id: item.name};
    emit(state.copyWith(categoryMap: map));
  }

  void addCategoryToMap(String id, String name) {
    final newMap = Map<String, String>.from(state.categoryMap);
    newMap[id] = name;
    emit(state.copyWith(categoryMap: newMap));
  }

  void toggleWeekday(Weekday day) {
    final list = List<Weekday>.from(state.schedule);
    list.contains(day) ? list.remove(day) : list.add(day);
    emit(state.copyWith(schedule: list));
  }

  Future<bool> submit() async {
    if (!state.isValid) return false;
    emit(state.copyWith(isSubmitting: true));
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final tracker = TrackerModel(
        id: const Uuid().v4(),
        userId: uid,
        title: state.title.trim(),
        emoji: state.emoji,
        colorHex: state.colorHex,
        type: state.type,
        categoryId: state.categoryId,
        createdAt: DateTime.now(),
        schedule: state.schedule,
        deadlineDate: state.deadlineDate,
        reminderTime: state.reminderTime,
      );
      await _repo.createTracker(tracker);
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }
}
