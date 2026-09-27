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
        '${ApiConfig.openWeatherBaseUrl}/forecast?q=$city&appid=${ApiConfig.openWeatherApiKey}&units=metric';

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
    var list = data['list'] as List;

    for (int i = 0; i < 3 && (i * 8) < list.length; i++) {
      var entry = list[i * 8];
      DateTime dt = DateTime.parse(entry['dt_txt']);
      String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(dt);

      bool hasRain = false;
      if (entry['rain'] != null && entry['rain']['3h'] != null) {
        hasRain = (entry['rain']['3h'] as num) > 0;
      }

      forecast.add(
        WeatherForecastItem(
          dateTime: formattedDate,
          weather: entry['weather'][0]['description'] ?? '',
          temperature: (entry['main']['temp'] as num).toDouble(),
          humidity: (entry['main']['humidity'] as num).toInt(),
          rainfallExpected: hasRain,
        ),
      );
    }
    return forecast;
  }
}
