class CropAnalysisDataPoint {
  final String cropType;
  final double costOfProduction;
  final double cultivationArea;
  final double rainfallMm;

  CropAnalysisDataPoint({
    required this.cropType,
    required this.costOfProduction,
    required this.cultivationArea,
    required this.rainfallMm,
  });

  factory CropAnalysisDataPoint.fromJson(Map<String, dynamic> json) {
    return CropAnalysisDataPoint(
      cropType: json['crop_type'] ?? '',
      costOfProduction: (json['cost_of_production_per_hectare'] as num).toDouble(),
      cultivationArea: (json['cultivation_area_hectares'] as num).toDouble(),
      rainfallMm: (json['rainfall_mm'] as num).toDouble(),
    );
  }
}

class AnalysisResponse {
  final String state;
  final int year;
  final List<CropAnalysisDataPoint> data;

  AnalysisResponse({
    required this.state,
    required this.year,
    required this.data,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'] as List? ?? [];
    return AnalysisResponse(
      state: json['state'] ?? '',
      year: json['year'] ?? 0,
      data: rawList.map((item) => CropAnalysisDataPoint.fromJson(item)).toList(),
    );
  }
}
