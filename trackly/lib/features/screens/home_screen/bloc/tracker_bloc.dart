import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/data/models/category_model.dart';
import 'package:trackly/data/models/completion_model.dart';
import 'package:trackly/data/models/tracker_model.dart';
import 'package:trackly/data/repositories/category_repository.dart';
import 'package:trackly/data/repositories/tracker_repository.dart';

// MARK: Event

abstract class TrackerEvent {}

class TrackerSubscribed extends TrackerEvent {
  final String uid;
  TrackerSubscribed(this.uid);
}

class TrackerDataUpdated extends TrackerEvent {
  final List<TrackerModel> trackers;
  final List<CompletionModel> completions;
  TrackerDataUpdated(this.trackers, this.completions);
}

class TrackerDateChanged extends TrackerEvent {
  final DateTime date;
  TrackerDateChanged(this.date);
}

class TrackerFilterChanged extends TrackerEvent {
  final TrackerFilter filter;
  TrackerFilterChanged(this.filter);
}

class TrackerMarkToggled extends TrackerEvent {
  final String trackerId;
  final bool isDone;
  TrackerMarkToggled(this.trackerId, {required this.isDone});
}

class TrackerDeleted extends TrackerEvent {
  final String trackerId;
  TrackerDeleted(this.trackerId);
}

class TrackerRetried extends TrackerEvent {}

// MARK: State

abstract class TrackerState {}

class TrackerInitial extends TrackerState {}

class TrackerLoading extends TrackerState {}

class TrackerLoaded extends TrackerState {
  final List<TrackerModel> allTrackers;
  final List<CompletionModel> completions;
  final List<CategoryModel> categories;
  final DateTime selectedDate;
  final TrackerFilter activeFilter;

  TrackerLoaded({
    required this.allTrackers,
    required this.completions,
    required this.categories,
    required this.selectedDate,
    required this.activeFilter,
  });

  String? categoryNameFor(String? categoryId) {
    if (categoryId == null) return null;
    try {
      return categories.firstWhere((c) => c.id == categoryId).name;
    } catch (_) {
      return null;
    }
  }

  List<TrackerModel> get filtered {
    final visible = allTrackers.where((t) {
      if (t.type == TrackerType.habit) {
        return t.isScheduledFor(selectedDate);
      }
      return true;
    }).toList();

    return visible
        .where((t) => t.statusFor(selectedDate, completions) == activeFilter)
        .toList();
  }

  TrackerLoaded copyWith({
    List<TrackerModel>? allTrackers,
    List<CompletionModel>? completions,
    List<CategoryModel>? categories,
    DateTime? selectedDate,
    TrackerFilter? activeFilter,
  }) {
    return TrackerLoaded(
      allTrackers: allTrackers ?? this.allTrackers,
      completions: completions ?? this.completions,
      categories: categories ?? this.categories,
      selectedDate: selectedDate ?? this.selectedDate,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

class TrackerError extends TrackerState {
  final String message;
  TrackerError(this.message);
}

// MARK: Bloc

class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  final TrackerRepository _repo;
  final CategoryRepository _categoryRepo;

  StreamSubscription<List<TrackerModel>>? _trackersSub;
  StreamSubscription<List<CompletionModel>>? _completionsSub;
  StreamSubscription<List<CategoryModel>>? _categoriesSub;

  List<TrackerModel> _trackers = [];
  List<CompletionModel> _completions = [];
  List<CategoryModel> _categories = [];
  String? _uid;

  TrackerBloc(this._repo, this._categoryRepo) : super(TrackerInitial()) {
    on<TrackerSubscribed>(_onSubscribed);
    on<TrackerDataUpdated>(_onDataUpdated);
    on<TrackerDateChanged>(_onDateChanged);
    on<TrackerFilterChanged>(_onFilterChanged);
    on<TrackerMarkToggled>(_onMarkToggled);
    on<TrackerDeleted>(_onDeleted);
    on<TrackerRetried>(_onRetried);
    on<_ErrorOccurred>(_onErrorOccurred);
  }

  void _onSubscribed(TrackerSubscribed event, Emitter<TrackerState> emit) {
    _uid = event.uid;
    emit(TrackerLoading());
    _subscribeStreams(emit);
  }

  void _onRetried(TrackerRetried event, Emitter<TrackerState> emit) {
    if (_uid == null) return;
    emit(TrackerLoading());
    _subscribeStreams(emit);
  }

  void _subscribeStreams(Emitter<TrackerState> emit) {
    _trackersSub?.cancel();
    _completionsSub?.cancel();
    _categoriesSub?.cancel();

    _trackersSub = _repo.watchTrackers(_uid!).listen((trackers) {
      _trackers = trackers;
      add(TrackerDataUpdated(_trackers, _completions));
    }, onError: (_) => add(_ErrorOccurred()));

    _completionsSub = _repo.watchCompletions(_uid!, DateTime.now()).listen((
      completions,
    ) {
      _completions = completions;
      add(TrackerDataUpdated(_trackers, _completions));
    }, onError: (_) => add(_ErrorOccurred()));

    _categoriesSub = _categoryRepo.watchCategories(_uid!).listen((categories) {
      _categories = categories;
      add(TrackerDataUpdated(_trackers, _completions));
    }, onError: (_) => add(_ErrorOccurred()));
  }

  void _onDataUpdated(TrackerDataUpdated event, Emitter<TrackerState> emit) {
    final current = state;
    final selectedDate = current is TrackerLoaded
        ? current.selectedDate
        : DateTime.now();
    final filter = current is TrackerLoaded
        ? current.activeFilter
        : TrackerFilter.active;

    emit(
      TrackerLoaded(
        allTrackers: event.trackers,
        completions: event.completions,
        categories: _categories,
        selectedDate: selectedDate,
        activeFilter: filter,
      ),
    );
  }

  void _onDateChanged(TrackerDateChanged event, Emitter<TrackerState> emit) {
    if (state is TrackerLoaded) {
      emit((state as TrackerLoaded).copyWith(selectedDate: event.date));
    }
  }

  void _onFilterChanged(
    TrackerFilterChanged event,
    Emitter<TrackerState> emit,
  ) {
    if (state is TrackerLoaded) {
      emit((state as TrackerLoaded).copyWith(activeFilter: event.filter));
    }
  }

  void _onErrorOccurred(_ErrorOccurred event, Emitter<TrackerState> emit) {
    if (state is! TrackerError) {
      emit(TrackerError('Не удалось загрузить трекеры'));
    }
  }

  Future<void> _onMarkToggled(
    TrackerMarkToggled event,
    Emitter<TrackerState> emit,
  ) async {
    if (_uid == null || state is! TrackerLoaded) return;
    final date = (state as TrackerLoaded).selectedDate;
    if (event.isDone) {
      await _repo.unmarkDone(_uid!, event.trackerId, date);
    } else {
      await _repo.markDone(_uid!, event.trackerId, date);
    }
  }

  Future<void> _onDeleted(
    TrackerDeleted event,
    Emitter<TrackerState> emit,
  ) async {
    if (_uid == null) return;
    await _repo.deleteTracker(_uid!, event.trackerId);
  }

  @override
  Future<void> close() {
    _trackersSub?.cancel();
    _completionsSub?.cancel();
    _categoriesSub?.cancel();
    return super.close();
  }
}

class _ErrorOccurred extends TrackerEvent {}
