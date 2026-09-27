import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String defaultEmulatorUrl = 'http://10.0.2.2:5000/api/v1';
  static const String defaultLocalhostUrl = 'http://127.0.0.1:5000/api/v1';
  static const String defaultLanUrl = 'http://10.83.121.231:5000/api/v1';

  static final List<String> candidateBaseUrls = [
    defaultLocalhostUrl,
    defaultLanUrl,
    defaultEmulatorUrl,
  ];

  static String _baseUrl = defaultLocalhostUrl;

  static String get baseUrl => _baseUrl;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('custom_backend_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _baseUrl = savedUrl;
        return;
      }
    } catch (_) {}

    // Auto-detect reachable backend: 127.0.0.1 (ADB reverse/desktop) -> LAN Wi-Fi -> Emulator
    try {
      final client = http.Client();
      for (final candidate in candidateBaseUrls) {
        try {
          final testUri = Uri.parse(candidate.replaceAll('/api/v1', '/api/v1/health'));
          final res = await client.get(testUri).timeout(const Duration(milliseconds: 1200));
          if (res.statusCode == 200) {
            _baseUrl = candidate;
            return;
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  static Future<void> setBaseUrl(String newUrl) async {
    var url = newUrl.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.endsWith('/api/v1')) {
      if (url.endsWith('/api')) {
        url = '$url/v1';
      } else {
        url = '$url/api/v1';
      }
    }
    _baseUrl = url;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_backend_url', _baseUrl);
    } catch (_) {}
  }

  static const String openWeatherApiKey = '9736d84f2b387d052f9dfbfaea880970';
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';


  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String profileEndpoint = '/auth/profile';

  // ML & Recommendation endpoints
  static const String cropRecommendEndpoint = '/ml/crop-recommend';
  static const String fertilizerRecommendEndpoint = '/ml/fertilizer-recommend';
  static const String yieldPredictEndpoint = '/ml/yield-predict';
  static const String diseasePredictEndpoint = '/ml/disease-predict';


  // Soil Report Intelligence endpoints
  static const String soilReportUploadEndpoint = '/soil-reports/upload';
  static const String soilReportHistoryEndpoint = '/soil-reports/history';
  static const String soilReportSampleDemoEndpoint = '/soil-reports/sample-demo';
  static String soilReportUpdateEndpoint(String id) => '/soil-reports/$id/extracted-data';
  static String soilReportAnalyzeEndpoint(String id) => '/soil-reports/$id/analyze';
  static String soilReportDetailsEndpoint(String id) => '/soil-reports/$id';

  // Analytics & Metadata endpoints
  static const String analysisEndpoint = '/analytics/crop-analysis';
  static const String yieldMetadataEndpoint = '/metadata/yield-options';
  static const String analysisMetadataEndpoint = '/metadata/analysis-options';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
