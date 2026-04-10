import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackly/data/models/weather_model.dart';
import 'package:trackly/features/widgets/weather_widget/data/weather_repository.dart';

abstract class WeatherEvent {}

class WeatherLoadRequested extends WeatherEvent {}

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  WeatherLoaded(this.weather);
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message);
}

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
