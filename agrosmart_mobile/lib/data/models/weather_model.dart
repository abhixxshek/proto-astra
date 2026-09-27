class WeatherForecastItem {
  final String dateTime;
  final String weather;
  final double temperature;
  final int humidity;
  final bool rainfallExpected;

  WeatherForecastItem({
    required this.dateTime,
    required this.weather,
    required this.temperature,
    required this.humidity,
    required this.rainfallExpected,
  });

  factory WeatherForecastItem.fromJson(Map<String, dynamic> json) {
    return WeatherForecastItem(
      dateTime: json['dateTime'] ?? '',
      weather: json['weather'] ?? '',
      temperature: (json['temperature'] as num).toDouble(),
      humidity: json['humidity'] ?? 0,
      rainfallExpected: json['rainfall'] ?? false,
    );
  }
}
