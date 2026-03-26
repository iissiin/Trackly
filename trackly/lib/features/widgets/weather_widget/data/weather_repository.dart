import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:trackly/data/models/weather_model.dart';

class WeatherRepository {
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Геолокация отключена на устройстве');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Разрешение на геолокацию отклонено');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Геолокация запрещена навсегда. Откройте настройки приложения.',
      );
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  }

  Future<String> _getCityName(double lat, double lon) async {
    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat&lon=$lon&format=json&accept-language=ru',
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'TracklyApp/1.0'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      return address?['city'] ??
          address?['town'] ??
          address?['village'] ??
          address?['county'] ??
          'Неизвестно';
    }
    return 'Неизвестно';
  }

  Future<WeatherModel> fetchWeather() async {
    final position = await _determinePosition();
    final lat = position.latitude;
    final lon = position.longitude;

    final results = await Future.wait([
      http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast'
          '?latitude=$lat&longitude=$lon'
          '&current=temperature_2m,weather_code'
          '&temperature_unit=celsius',
        ),
      ),
      _getCityName(lat, lon),
    ]);

    final weatherResponse = results[0] as http.Response;
    final cityName = results[1] as String;

    if (weatherResponse.statusCode != 200) {
      throw Exception('Ошибка получения погоды: ${weatherResponse.statusCode}');
    }

    final json = jsonDecode(weatherResponse.body) as Map<String, dynamic>;
    return WeatherModel.fromOpenMeteo(json: json, city: cityName);
  }
}
