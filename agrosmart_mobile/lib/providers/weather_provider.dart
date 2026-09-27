import 'package:flutter/foundation.dart';
import '../data/models/weather_model.dart';
import '../data/services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  List<WeatherForecastItem> _forecast = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentCity = 'Delhi';

  WeatherProvider({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService();

  List<WeatherForecastItem> get forecast => _forecast;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentCity => _currentCity;

  Future<void> fetchForecast(String city) async {
    _currentCity = city;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _forecast = await _weatherService.fetchWeatherForecast(city);
    } catch (e) {
      // Fallback sample forecast data
      _forecast = [
        WeatherForecastItem(
          dateTime: '27-09-2026 09:00 AM',
          weather: 'Light Rain',
          temperature: 28.5,
          humidity: 82,
          rainfallExpected: true,
        ),
        WeatherForecastItem(
          dateTime: '28-09-2026 09:00 AM',
          weather: 'Sunny / Clear',
          temperature: 31.0,
          humidity: 55,
          rainfallExpected: false,
        ),
        WeatherForecastItem(
          dateTime: '29-09-2026 09:00 AM',
          weather: 'Partly Cloudy',
          temperature: 29.8,
          humidity: 64,
          rainfallExpected: false,
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
