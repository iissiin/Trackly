import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/data/models/weather_model.dart';
import 'package:trackly/features/widgets/weather_widget/data/weather_repository.dart';

// ─── Events ───────────────────────────────────────────

abstract class WeatherEvent {}

/// Запустить загрузку погоды (вызывается при старте виджета или при обновлении)
class WeatherLoadRequested extends WeatherEvent {}

// ─── States ───────────────────────────────────────────

abstract class WeatherState {}

/// Начальное состояние — ещё ничего не запрашивали
class WeatherInitial extends WeatherState {}

/// Идёт загрузка
class WeatherLoading extends WeatherState {}

/// Данные успешно получены
class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  WeatherLoaded(this.weather);
}

/// Произошла ошибка
class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

// ─── Bloc ─────────────────────────────────────────────

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository _repository;

  WeatherBloc({WeatherRepository? repository})
    : _repository = repository ?? WeatherRepository(),
      super(WeatherInitial()) {
    on<WeatherLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    WeatherLoadRequested event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    try {
      final weather = await _repository.fetchWeather();
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}
