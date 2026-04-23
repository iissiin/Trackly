class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final int weatherCode;

  const WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.weatherCode,
  });

  String get emoji => _codeToEmoji(weatherCode);

  static String _codeToEmoji(int code) {
    if (code == 0) return '☀️';
    if (code <= 2) return '⛅';
    if (code == 3) return '☁️';
    if (code <= 49) return '🌫️';
    if (code <= 59) return '🌦️';
    if (code <= 69) return '🌧️';
    if (code <= 79) return '❄️';
    if (code <= 82) return '🌧️';
    if (code <= 84) return '🌨️';
    if (code <= 99) return '⛈️';
    return '🌡️';
  }

  static String codeToDescription(int code) {
    if (code == 0) return 'Ясно';
    if (code == 1) return 'Преимущественно ясно';
    if (code == 2) return 'Переменная облачность';
    if (code == 3) return 'Пасмурно';
    if (code <= 49) return 'Туман';
    if (code <= 59) return 'Морось';
    if (code <= 69) return 'Дождь';
    if (code <= 79) return 'Снег';
    if (code <= 82) return 'Ливень';
    if (code <= 84) return 'Снегопад';
    if (code <= 99) return 'Гроза';
    return 'Неизвестно';
  }

  factory WeatherModel.fromOpenMeteo({
    required Map<String, dynamic> json,
    required String city,
  }) {
    final current = json['current'] as Map<String, dynamic>;
    final code = (current['weather_code'] as num).toInt();
    return WeatherModel(
      cityName: city,
      temperature: (current['temperature_2m'] as num).toDouble(),
      description: codeToDescription(code),
      weatherCode: code,
    );
  }
}
