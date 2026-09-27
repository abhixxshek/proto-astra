class YieldPredictionRequest {
  final int year;
  final double averageRainfall;
  final double pesticidesTonnes;
  final double avgTemp;
  final String area;
  final String item;

  YieldPredictionRequest({
    required this.year,
    required this.averageRainfall,
    required this.pesticidesTonnes,
    required this.avgTemp,
    required this.area,
    required this.item,
  });

  Map<String, dynamic> toJson() {
    return {
      'Year': year,
      'average_rain_fall_mm_per_year': averageRainfall,
      'pesticides_tonnes': pesticidesTonnes,
      'avg_temp': avgTemp,
      'Area': area,
      'Item': item,
    };
  }
}

class YieldPredictionResponse {
  final double predictedYield;
  final String unit;

  YieldPredictionResponse({
    required this.predictedYield,
    this.unit = 'hg/ha',
  });

  factory YieldPredictionResponse.fromJson(Map<String, dynamic> json) {
    return YieldPredictionResponse(
      predictedYield: (json['prediction'] as num).toDouble(),
      unit: json['unit'] ?? 'hg/ha',
    );
  }
}
