class WeatherInfo {
  final String main;
  final String description;
  final double? temperatureCelsius;
  final Map<String, dynamic>? raw;

  WeatherInfo({required this.main, required this.description, this.temperatureCelsius, this.raw});

  @override
  String toString() => 'WeatherInfo(main: $main, description: $description, temp: $temperatureCelsius)';

  factory WeatherInfo.fromMap(Map<String, dynamic> m) {
    return WeatherInfo(
      main: m['main'] ?? 'Unknown',
      description: m['description'] ?? 'Unknown',
      temperatureCelsius: m['temp'] != null ? (m['temp'] as num).toDouble() : null,
      raw: m,
    );
  }
}

