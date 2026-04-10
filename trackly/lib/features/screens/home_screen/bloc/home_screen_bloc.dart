import 'package:flutter_bloc/flutter_bloc.dart';

abstract class TrackersEvent {}

class TrackersLoadRequested extends TrackersEvent {}

class TrackerAdded extends TrackersEvent {}

class TrackerRemoved extends TrackersEvent {}

abstract class TrackersState {}

class TrackersInitial extends TrackersState {}

class TrackersLoading extends TrackersState {}

class TrackersLoaded extends TrackersState {
  final int activeTrackersCount;

  TrackersLoaded(this.activeTrackersCount);
}

class TrackersError extends TrackersState {}

class TrackersBloc extends Bloc<TrackersEvent, TrackersState> {
  TrackersBloc() : super(TrackersInitial()) {
    on<TrackersLoadRequested>(_onLoadRequested);
    on<TrackerAdded>(_onTrackerAdded);
    on<TrackerRemoved>(_onTrackerRemoved);
  }

  int _activeTrackersCount =
      0; // Симуляция количества (замените на реальные данные из репозитория)

  void _onLoadRequested(
    TrackersLoadRequested event,
    Emitter<TrackersState> emit,
  ) async {
    emit(TrackersLoading());
    // TODO: Загрузка реальных данных из репозитория/Firestore
    await Future.delayed(const Duration(milliseconds: 500)); // Симуляция
    emit(TrackersLoaded(_activeTrackersCount));
  }

  void _onTrackerAdded(TrackerAdded event, Emitter<TrackersState> emit) {
    _activeTrackersCount++;
    emit(TrackersLoaded(_activeTrackersCount));
  }

  void _onTrackerRemoved(TrackerRemoved event, Emitter<TrackersState> emit) {
    if (_activeTrackersCount > 0) {
      _activeTrackersCount--;
      emit(TrackersLoaded(_activeTrackersCount));
    }
  }
}
