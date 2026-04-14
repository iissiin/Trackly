import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/data/repositories/tracker_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

// MARK: State

class CreateTrackerState {
  final String title;
  final String emoji;
  final String colorHex;
  final TrackerType type;
  final String? categoryId;
  final List<Weekday> schedule;
  final DateTime? deadlineDate;
  final bool isSubmitting;
  final String? error;

  const CreateTrackerState({
    this.title = '',
    this.emoji = '✨',
    this.colorHex = '5A7A5E',
    this.type = TrackerType.habit,
    this.categoryId,
    this.schedule = const [],
    this.deadlineDate,
    this.isSubmitting = false,
    this.error,
  });

  /// Валидация формы
  bool get isValid =>
      title.trim().isNotEmpty &&
      (type == TrackerType.irregular || schedule.isNotEmpty);

  CreateTrackerState copyWith({
    String? title,
    String? emoji,
    String? colorHex,
    TrackerType? type,
    String? categoryId,
    List<Weekday>? schedule,
    DateTime? deadlineDate,
    bool? isSubmitting,
    String? error,
  }) {
    return CreateTrackerState(
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      schedule: schedule ?? this.schedule,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

// MARK: Cubit

class CreateTrackerCubit extends Cubit<CreateTrackerState> {
  final TrackerRepository _repo;

  CreateTrackerCubit(this._repo) : super(const CreateTrackerState());

  void setTitle(String v) => emit(state.copyWith(title: v));

  void setEmoji(String v) => emit(state.copyWith(emoji: v));

  void setColor(String hex) => emit(state.copyWith(colorHex: hex));

  void setType(TrackerType v) =>
      emit(state.copyWith(type: v, schedule: [], deadlineDate: null));

  void setCategory(String? id) => emit(state.copyWith(categoryId: id));

  void setDeadline(DateTime? d) => emit(state.copyWith(deadlineDate: d));

  void toggleWeekday(Weekday day) {
    final list = List<Weekday>.from(state.schedule);

    if (list.contains(day)) {
      list.remove(day);
    } else {
      list.add(day);
    }

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
      );

      await _repo.createTracker(tracker);

      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
      return false;
    }
  }
}
