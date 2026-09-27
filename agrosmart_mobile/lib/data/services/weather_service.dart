import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../app/config/api_config.dart';
import '../../core/network/api_exception.dart';
import '../models/weather_model.dart';

class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<WeatherForecastItem>> fetchWeatherForecast(String city) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=9.85&longitude=76.9667&daily=sunrise,sunset,rain_sum&hourly=temperature_2m,relative_humidity_2m,dew_point_2m,rain&current=wind_speed_10m&timezone=auto';

    try {
      final response = await _client.get(Uri.parse(url)).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _extractWeatherInfo(data);
      } else if (response.statusCode == 404) {
        throw ApiException('City not found. Please check spelling.');
      } else {
        throw ApiException('Failed to fetch weather forecast.');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error fetching weather data.');
    }
  }

  List<WeatherForecastItem> _extractWeatherInfo(Map<String, dynamic> data) {
    List<WeatherForecastItem> forecast = [];
    
    final hourly = data['hourly'];
    if (hourly == null) return forecast;

    final times = hourly['time'] as List;
    final temps = hourly['temperature_2m'] as List;
    final hums = hourly['relative_humidity_2m'] as List;
    final rains = hourly['rain'] as List;

    // Get a few points, e.g. current time, +8h, +16h
    for (int i = 0; i < 3 && (i * 8) < times.length; i++) {
      int index = i * 8;
      DateTime dt = DateTime.parse(times[index]);
      String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(dt);

      bool hasRain = (rains[index] as num) > 0;
      String weatherDesc = hasRain ? 'Rainy' : 'Clear / Cloudy';

      forecast.add(
        WeatherForecastItem(
          dateTime: formattedDate,
          weather: weatherDesc,
          temperature: (temps[index] as num).toDouble(),
          humidity: (hums[index] as num).toInt(),
          rainfallExpected: hasRain,
        ),
      );
    }
    return forecast;
  }
}
