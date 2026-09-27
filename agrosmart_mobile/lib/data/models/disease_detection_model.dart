class DiseaseSupplement {
  final String name;
  final String imageUrl;
  final String buyLink;
  final String amazonBuyLink;
  final String amazonSearchQuery;

  DiseaseSupplement({
    required this.name,
    required this.imageUrl,
    required this.buyLink,
    this.amazonBuyLink = '',
    this.amazonSearchQuery = '',
  });

  factory DiseaseSupplement.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? 'N/A';
    final query = json['amazon_search_query']?.toString() ??
        (name != 'N/A' && name.isNotEmpty ? '$name fungicide' : '');
    final amazonUrl = json['amazon_buy_link']?.toString() ??
        (query.isNotEmpty ? 'https://www.amazon.in/s?k=${Uri.encodeComponent(query)}' : '');

    return DiseaseSupplement(
      name: name,
      imageUrl: json['image_url']?.toString() ?? '',
      buyLink: json['buy_link']?.toString() ?? amazonUrl,
      amazonBuyLink: amazonUrl,
      amazonSearchQuery: query,
    );
  }
}

class TopPrediction {
  final int index;
  final String classLabel;
  final String diseaseName;
  final double confidence;

  TopPrediction({
    required this.index,
    required this.classLabel,
    required this.diseaseName,
    required this.confidence,
  });

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      index: json['index'] as int? ?? 0,
      classLabel: json['class_label']?.toString() ?? '',
      diseaseName: json['disease_name']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DiseasePredictionResponse {
  final bool success;
  final int predictionIndex;
  final String rawClassLabel;
  final String diseaseName;
  final double confidence;
  final String description;
  final String cause;
  final String recommendation;
  final String treatment;
  final String prevention;
  final String diseaseImageUrl;
  final DiseaseSupplement supplement;
  final List<TopPrediction> topPredictions;
  final String? error;

  DiseasePredictionResponse({
    required this.success,
    required this.predictionIndex,
    required this.rawClassLabel,
    required this.diseaseName,
    required this.confidence,
    required this.description,
    this.cause = '',
    this.recommendation = '',
    this.treatment = '',
    required this.prevention,
    required this.diseaseImageUrl,
    required this.supplement,
    required this.topPredictions,
    this.error,
  });

  factory DiseasePredictionResponse.fromJson(Map<String, dynamic> json) {
    var topList = (json['top_predictions'] as List?) ?? [];
    return DiseasePredictionResponse(
      success: json['success'] as bool? ?? false,
      predictionIndex: json['prediction_index'] as int? ?? 0,
      rawClassLabel: json['raw_class_label']?.toString() ?? '',
      diseaseName: json['disease_name']?.toString() ?? 'Healthy / Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      cause: json['cause']?.toString() ?? json['symptoms']?.toString() ?? '',
      recommendation: json['recommendation']?.toString() ?? json['prevention']?.toString() ?? '',
      treatment: json['treatment']?.toString() ?? '',
      prevention: json['prevention']?.toString() ?? '',
      diseaseImageUrl: json['disease_image_url']?.toString() ?? '',
      supplement: DiseaseSupplement.fromJson(json['supplement'] as Map<String, dynamic>? ?? {}),
      topPredictions: topList.map((item) => TopPrediction.fromJson(item as Map<String, dynamic>)).toList(),
      error: json['error']?.toString(),
    );
  }
}

