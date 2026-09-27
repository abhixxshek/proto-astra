class CropRecommendationRequest {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double temperature;
  final double humidity;
  final double phValue;
  final double rainfall;

  CropRecommendationRequest({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.humidity,
    required this.phValue,
    required this.rainfall,
  });

  Map<String, dynamic> toJson() {
    return {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'temperature': temperature,
      'humidity': humidity,
      'phValue': phValue,
      'rainfall': rainfall,
    };
  }
}

class CropRecommendationResponse {
  final List<String> recommendedCrops;
  final String? message;

  CropRecommendationResponse({
    required this.recommendedCrops,
    this.message,
  });

  factory CropRecommendationResponse.fromJson(Map<String, dynamic> json) {
    var cropsList = json['recommended_crops'] as List? ?? [];
    return CropRecommendationResponse(
      recommendedCrops: cropsList.map((e) => e.toString()).toList(),
      message: json['message'],
    );
  }
}
