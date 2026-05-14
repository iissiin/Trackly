import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/data/models/completion_model.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/data/repositories/category_repository.dart';
import 'package:trackly/data/repositories/tracker_repository.dart';
import 'package:trackly/data/models/category_model.dart';


abstract class StatisticEvent {}

class StatisticSubscribed extends StatisticEvent {
  final String uid;
  StatisticSubscribed(this.uid);
}

class _StatisticDataUpdated extends StatisticEvent {
  final List<TrackerModel> trackers;
  final List<CompletionModel> completions;
  final List<CategoryModel> categories;
  _StatisticDataUpdated(this.trackers, this.completions, this.categories);
}

class _StatisticError extends StatisticEvent {}


class StatisticState {
  final int totalTrackers;

  final int completedThisWeek;

  final String? topCategory;

  final int completedToday;
  final int totalToday;

  final int activeTrackers;

  final int bestStreak;

  final bool isLoading;
  final bool hasError;

  const StatisticState({
    this.totalTrackers = 0,
    this.completedThisWeek = 0,
    this.topCategory,
    this.completedToday = 0,
    this.totalToday = 0,
    this.activeTrackers = 0,
    this.bestStreak = 0,
    this.isLoading = true,
    this.hasError = false,
  });

  StatisticState copyWith({
    int? totalTrackers,
    int? completedThisWeek,
    String? topCategory,
    bool clearTopCategory = false,
    int? completedToday,
    int? totalToday,
    int? activeTrackers,
    int? bestStreak,
    bool? isLoading,
    bool? hasError,
  }) {
    return StatisticState(
      totalTrackers: totalTrackers ?? this.totalTrackers,
      completedThisWeek: completedThisWeek ?? this.completedThisWeek,
      topCategory: clearTopCategory ? null : (topCategory ?? this.topCategory),
      completedToday: completedToday ?? this.completedToday,
      totalToday: totalToday ?? this.totalToday,
      activeTrackers: activeTrackers ?? this.activeTrackers,
      bestStreak: bestStreak ?? this.bestStreak,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

class StatisticBloc extends Bloc<StatisticEvent, StatisticState> {
  final TrackerRepository _trackerRepo;
  final CategoryRepository _categoryRepo;

  StreamSubscription<List<TrackerModel>>? _trackersSub;
  StreamSubscription<List<CompletionModel>>? _completionsSub;
  StreamSubscription<List<CategoryModel>>? _categoriesSub;

  List<TrackerModel> _trackers = [];
  List<CompletionModel> _completions = [];
  List<CategoryModel> _categories = [];

  StatisticBloc(this._trackerRepo, this._categoryRepo)
      : super(const StatisticState()) {
    on<StatisticSubscribed>(_onSubscribed);
    on<_StatisticDataUpdated>(_onDataUpdated);
    on<_StatisticError>(_onError);
  }

  void _onSubscribed(
    StatisticSubscribed event,
    Emitter<StatisticState> emit,
  ) {
    emit(state.copyWith(isLoading: true, hasError: false));

    _trackersSub?.cancel();
    _completionsSub?.cancel();
    _categoriesSub?.cancel();

    // Слушаем трекеры
    _trackersSub = _trackerRepo.watchTrackers(event.uid).listen(
      (trackers) {
        _trackers = trackers;
        add(_StatisticDataUpdated(_trackers, _completions, _categories));
      },
      onError: (_) => add(_StatisticError()),
    );

    _completionsSub = _trackerRepo
        .watchCompletions(event.uid, DateTime.now())
        .listen(
      (completions) {
        _completions = completions;
        add(_StatisticDataUpdated(_trackers, _completions, _categories));
      },
      onError: (_) => add(_StatisticError()),
    );

    _categoriesSub = _categoryRepo.watchCategories(event.uid).listen(
      (categories) {
        _categories = categories;
        add(_StatisticDataUpdated(_trackers, _completions, _categories));
      },
      onError: (_) => add(_StatisticError()),
    );
  }

  void _onDataUpdated(
    _StatisticDataUpdated event,
    Emitter<StatisticState> emit,
  ) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final totalTrackers = event.trackers.length;

    final weekAgo = todayOnly.subtract(const Duration(days: 6));
    final completedThisWeek = event.completions.where((c) {
      final d = DateTime(c.date.year, c.date.month, c.date.day);
      return !d.isBefore(weekAgo) && !d.isAfter(todayOnly);
    }).length;

    final categoryCount = <String, int>{};
    for (final t in event.trackers) {
      if (t.categoryId != null) {
        categoryCount[t.categoryId!] =
            (categoryCount[t.categoryId!] ?? 0) + 1;
      }
    }
    String? topCategoryName;
    if (categoryCount.isNotEmpty) {
      final topId = categoryCount.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      try {
        topCategoryName =
            event.categories.firstWhere((c) => c.id == topId).name;
      } catch (_) {
        topCategoryName = null;
      }
    }

    final scheduledToday = event.trackers
        .where((t) => t.isScheduledFor(todayOnly))
        .toList();
    final completedToday = event.completions.where((c) {
      final d = DateTime(c.date.year, c.date.month, c.date.day);
      return d == todayOnly;
    }).length;

    final activeTrackers = scheduledToday
        .where(
          (t) =>
              t.statusFor(todayOnly, event.completions) == TrackerFilter.active,
        )
        .length;

    final bestStreak = _calcBestStreak(event.completions, todayOnly);

    emit(
      state.copyWith(
        totalTrackers: totalTrackers,
        completedThisWeek: completedThisWeek,
        topCategory: topCategoryName,
        clearTopCategory: topCategoryName == null,
        completedToday: completedToday,
        totalToday: scheduledToday.length,
        activeTrackers: activeTrackers,
        bestStreak: bestStreak,
        isLoading: false,
        hasError: false,
      ),
    );
  }

  void _onError(_StatisticError event, Emitter<StatisticState> emit) {
    emit(state.copyWith(isLoading: false, hasError: true));
  }

  int _calcBestStreak(List<CompletionModel> completions, DateTime today) {
    if (completions.isEmpty) return 0;

    final days = completions
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet()
        .toList()
      ..sort();

    int best = 1;
    int current = 1;

    for (int i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }

    return best;
  }

  @override
  Future<void> close() {
    _trackersSub?.cancel();
    _completionsSub?.cancel();
    _categoriesSub?.cancel();
    return super.close();
  }
}