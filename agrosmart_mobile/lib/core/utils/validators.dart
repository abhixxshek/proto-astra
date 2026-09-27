import '../../app/config/app_constants.dart';

class FormValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateRange(String? value, String fieldName, double min, double max, String unit) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Enter a valid number';
    }
    if (number < min || number > max) {
      return '$fieldName must be between $min and $max $unit';
    }
    return null;
  }

  static String? validateNitrogen(String? value) =>
      validateRange(value, 'Nitrogen', AppConstants.minNitrogen, AppConstants.maxNitrogen, 'kg/ha');

  static String? validatePhosphorus(String? value) =>
      validateRange(value, 'Phosphorus', AppConstants.minPhosphorus, AppConstants.maxPhosphorus, 'kg/ha');

  static String? validatePotassium(String? value) =>
      validateRange(value, 'Potassium', AppConstants.minPotassium, AppConstants.maxPotassium, 'kg/ha');

  static String? validateTemperature(String? value) =>
      validateRange(value, 'Temperature', AppConstants.minTemp, AppConstants.maxTemp, '°C');

  static String? validateHumidity(String? value) =>
      validateRange(value, 'Humidity', AppConstants.minHumidity, AppConstants.maxHumidity, '%');

  static String? validatePh(String? value) =>
      validateRange(value, 'pH Value', AppConstants.minPh, AppConstants.maxPh, '');

  static String? validateRainfall(String? value) =>
      validateRange(value, 'Rainfall', AppConstants.minRainfall, AppConstants.maxRainfall, 'mm');
}
