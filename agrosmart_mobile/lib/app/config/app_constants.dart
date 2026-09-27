class AppConstants {
  static const String appName = 'AgroSmart';
  static const String appTagline = 'ML-Driven Precision Agriculture & Crop Insights';

  // Soil types from fertilizer_recommendation.csv
  static const List<String> soilTypes = [
    'Black',
    'Clayey',
    'Loamy',
    'Red',
    'Sandy',
  ];

  // Crop types from fertilizer_recommendation.csv
  static const List<String> cropTypes = [
    'Barley',
    'Cotton',
    'Ground Nuts',
    'Maize',
    'Millets',
    'Oil seeds',
    'Paddy',
    'Pulses',
    'Sugarcane',
    'Tobacco',
    'Wheat',
  ];

  // Input ranges & validations
  static const double minNitrogen = 0;
  static const double maxNitrogen = 300;

  static const double minPhosphorus = 0;
  static const double maxPhosphorus = 150;

  static const double minPotassium = 0;
  static const double maxPotassium = 250;

  static const double minTemp = 0;
  static const double maxTemp = 45;

  static const double minHumidity = 0;
  static const double maxHumidity = 100;

  static const double minPh = 4.0;
  static const double maxPh = 14.0;

  static const double minRainfall = 0;
  static const double maxRainfall = 2000;
}
