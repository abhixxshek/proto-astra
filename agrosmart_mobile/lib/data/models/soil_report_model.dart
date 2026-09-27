class SoilParameterItem {
  final String key;
  final String displayName;
  final String? rawValue;
  final String detectedUnit;
  dynamic normalizedValue;
  final String normalizedUnit;
  final double confidence;
  String status;
  final String? sourceText;

  SoilParameterItem({
    required this.key,
    required this.displayName,
    this.rawValue,
    required this.detectedUnit,
    this.normalizedValue,
    required this.normalizedUnit,
    required this.confidence,
    required this.status,
    this.sourceText,
  });

  factory SoilParameterItem.fromJson(String key, Map<String, dynamic> json) {
    return SoilParameterItem(
      key: key,
      displayName: _getDisplayName(key),
      rawValue: json['raw_value']?.toString(),
      detectedUnit: json['detected_unit']?.toString() ?? '',
      normalizedValue: json['normalized_value'],
      normalizedUnit: json['normalized_unit']?.toString() ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'NOT_FOUND',
      sourceText: json['source_text']?.toString(),
    );
  }

  static String _getDisplayName(String key) {
    switch (key) {
      case 'ph':
        return 'Soil Reaction (pH)';
      case 'electrical_conductivity':
        return 'Electrical Conductivity (EC)';
      case 'organic_carbon':
        return 'Organic Carbon (OC)';
      case 'nitrogen':
        return 'Available Nitrogen (N)';
      case 'phosphorus':
        return 'Available Phosphorus (P)';
      case 'potassium':
        return 'Available Potassium (K)';
      case 'sulfur':
        return 'Available Sulphur (S)';
      case 'calcium':
        return 'Exchangeable Calcium (Ca)';
      case 'magnesium':
        return 'Exchangeable Magnesium (Mg)';
      case 'zinc':
        return 'Available Zinc (Zn)';
      case 'iron':
        return 'Available Iron (Fe)';
      case 'boron':
        return 'Available Boron (B)';
      case 'copper':
        return 'Available Copper (Cu)';
      case 'manganese':
        return 'Available Manganese (Mn)';
      case 'soil_type':
        return 'Soil Type';
      case 'soil_texture':
        return 'Soil Textural Class';
      case 'soil_moisture':
        return 'Soil Moisture';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }

  bool get isVerified => status == 'VERIFIED';
  bool get isHighConfidence => status == 'HIGH_CONFIDENCE';
  bool get isReviewRequired => status == 'REVIEW_REQUIRED';
  bool get isNotFound => status == 'NOT_FOUND';
  bool get isInvalid => status == 'INVALID_VALUE';
}

class SoilReportMetadata {
  final String? sampleDate;
  final String? laboratory;
  final String? location;

  SoilReportMetadata({this.sampleDate, this.laboratory, this.location});

  factory SoilReportMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SoilReportMetadata();
    return SoilReportMetadata(
      sampleDate: json['sample_date']?.toString(),
      laboratory: json['laboratory']?.toString(),
      location: json['location']?.toString(),
    );
  }
}

class SoilReportUploadData {
  final String reportId;
  final String originalFilename;
  final String uploadedAt;
  final SoilReportMetadata metadata;
  final Map<String, SoilParameterItem> parameters;
  final Map<String, dynamic> canonicalSoilProfile;

  SoilReportUploadData({
    required this.reportId,
    required this.originalFilename,
    required this.uploadedAt,
    required this.metadata,
    required this.parameters,
    required this.canonicalSoilProfile,
  });

  factory SoilReportUploadData.fromJson(Map<String, dynamic> json) {
    final rawParams = (json['extracted_parameters'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, SoilParameterItem> paramsMap = {};
    rawParams.forEach((k, v) {
      if (v is Map) {
        paramsMap[k] = SoilParameterItem.fromJson(k, Map<String, dynamic>.from(v));
      }
    });

    final metaMap = json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata'] as Map) : null;
    final profileMap = (json['canonical_soil_profile'] as Map?)?.cast<String, dynamic>() ?? {};

    return SoilReportUploadData(
      reportId: json['report_id']?.toString() ?? '',
      originalFilename: json['original_filename']?.toString() ?? 'soil_report.pdf',
      uploadedAt: json['uploaded_at']?.toString() ?? '',
      metadata: SoilReportMetadata.fromJson(metaMap),
      parameters: paramsMap,
      canonicalSoilProfile: profileMap,
    );
  }
}

class NutrientDeficiency {
  final String nutrient;
  final String level;
  final String symptom;
  final String product;
  final String amazonQuery;
  final String amazonBuyLink;

  NutrientDeficiency({
    required this.nutrient,
    required this.level,
    required this.symptom,
    required this.product,
    required this.amazonQuery,
    required this.amazonBuyLink,
  });

  factory NutrientDeficiency.fromJson(Map<String, dynamic> json) {
    return NutrientDeficiency(
      nutrient: json['nutrient']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      symptom: json['symptom']?.toString() ?? '',
      product: json['product']?.toString() ?? '',
      amazonQuery: json['amazon_query']?.toString() ?? '',
      amazonBuyLink: json['amazon_buy_link']?.toString() ?? '',
    );
  }
}

class SoilHealthSummary {
  final double? phValue;
  final String phStatus;
  final String? phAlert;
  final String? phAmendment;
  final String nitrogenStatus;
  final double? nitrogenValue;
  final String phosphorusStatus;
  final double? phosphorusValue;
  final String potassiumStatus;
  final double? potassiumValue;
  final String ocStatus;
  final double? ocValue;
  final String ecStatus;
  final double? ecValue;
  final List<NutrientDeficiency> deficiencies;

  SoilHealthSummary({
    this.phValue,
    required this.phStatus,
    this.phAlert,
    this.phAmendment,
    required this.nitrogenStatus,
    this.nitrogenValue,
    required this.phosphorusStatus,
    this.phosphorusValue,
    required this.potassiumStatus,
    this.potassiumValue,
    required this.ocStatus,
    this.ocValue,
    required this.ecStatus,
    this.ecValue,
    required this.deficiencies,
  });

  factory SoilHealthSummary.fromJson(Map<String, dynamic> json) {
    final phData = json['ph'] as Map<String, dynamic>? ?? {};
    final nData = json['nitrogen'] as Map<String, dynamic>? ?? {};
    final pData = json['phosphorus'] as Map<String, dynamic>? ?? {};
    final kData = json['potassium'] as Map<String, dynamic>? ?? {};
    final ocData = json['organic_carbon'] as Map<String, dynamic>? ?? {};
    final ecData = json['electrical_conductivity'] as Map<String, dynamic>? ?? {};

    final rawDefs = json['deficiencies'] as List<dynamic>? ?? [];
    final defs = rawDefs.map((d) => NutrientDeficiency.fromJson(d as Map<String, dynamic>)).toList();

    return SoilHealthSummary(
      phValue: (phData['value'] as num?)?.toDouble(),
      phStatus: phData['status']?.toString() ?? json['ph_status']?.toString() ?? 'Neutral',
      phAlert: phData['alert']?.toString(),
      phAmendment: phData['amendment']?.toString(),
      nitrogenStatus: nData['status']?.toString() ?? json['nitrogen_status']?.toString() ?? 'Medium',
      nitrogenValue: (nData['value'] as num?)?.toDouble(),
      phosphorusStatus: pData['status']?.toString() ?? json['phosphorus_status']?.toString() ?? 'Medium',
      phosphorusValue: (pData['value'] as num?)?.toDouble(),
      potassiumStatus: kData['status']?.toString() ?? json['potassium_status']?.toString() ?? 'Medium',
      potassiumValue: (kData['value'] as num?)?.toDouble(),
      ocStatus: ocData['status']?.toString() ?? 'Medium',
      ocValue: (ocData['value'] as num?)?.toDouble(),
      ecStatus: ecData['status']?.toString() ?? 'Non-Saline',
      ecValue: (ecData['value'] as num?)?.toDouble(),
      deficiencies: defs,
    );
  }
}

class CropCandidate {
  final int rank;
  final String cropName;
  final double suitabilityScore;
  final String suitabilityRating;
  final String reasons;
  final String limitations;

  CropCandidate({
    required this.rank,
    required this.cropName,
    required this.suitabilityScore,
    required this.suitabilityRating,
    required this.reasons,
    required this.limitations,
  });

  factory CropCandidate.fromJson(Map<String, dynamic> json) {
    return CropCandidate(
      rank: (json['rank'] as num?)?.toInt() ?? 1,
      cropName: json['crop_name']?.toString() ?? '',
      suitabilityScore: (json['suitability_score'] as num?)?.toDouble() ?? 0.0,
      suitabilityRating: json['suitability_rating']?.toString() ?? 'Recommended',
      reasons: json['reasons']?.toString() ?? '',
      limitations: json['limitations']?.toString() ?? '',
    );
  }
}

class FertilizerPrescription {
  final String targetCrop;
  final String recommendedFertilizer;
  final String amazonSearchQuery;
  final String amazonBuyLink;
  final String dosageGuidance;
  final String cautions;

  FertilizerPrescription({
    required this.targetCrop,
    required this.recommendedFertilizer,
    required this.amazonSearchQuery,
    required this.amazonBuyLink,
    required this.dosageGuidance,
    required this.cautions,
  });

  factory FertilizerPrescription.fromJson(Map<String, dynamic> json) {
    return FertilizerPrescription(
      targetCrop: json['target_crop']?.toString() ?? '',
      recommendedFertilizer: json['recommended_fertilizer']?.toString() ?? 'Urea',
      amazonSearchQuery: json['amazon_search_query']?.toString() ?? '',
      amazonBuyLink: json['amazon_buy_link']?.toString() ?? '',
      dosageGuidance: json['dosage_guidance']?.toString() ?? '',
      cautions: json['cautions']?.toString() ?? '',
    );
  }
}

class YieldPredictionResult {
  final String crop;
  final double predictedYieldHgHa;
  final double predictedYieldTonnesHa;
  final String unit;
  final List<String> keyInfluencingFactors;

  YieldPredictionResult({
    required this.crop,
    required this.predictedYieldHgHa,
    required this.predictedYieldTonnesHa,
    required this.unit,
    required this.keyInfluencingFactors,
  });

  factory YieldPredictionResult.fromJson(Map<String, dynamic> json) {
    final factors = (json['key_influencing_factors'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return YieldPredictionResult(
      crop: json['crop']?.toString() ?? '',
      predictedYieldHgHa: (json['predicted_yield_hg_ha'] as num?)?.toDouble() ??
          (json['predicted_yield'] as num?)?.toDouble() ??
          0.0,
      predictedYieldTonnesHa: (json['predicted_yield_tonnes_ha'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'hg/ha',
      keyInfluencingFactors: factors,
    );
  }
}

class WeatherConsiderations {
  final String temperature;
  final String humidity;
  final String rainfall;
  final String note;

  WeatherConsiderations({
    required this.temperature,
    required this.humidity,
    required this.rainfall,
    required this.note,
  });

  factory WeatherConsiderations.fromJson(Map<String, dynamic> json) {
    return WeatherConsiderations(
      temperature: json['temperature']?.toString() ?? '',
      humidity: json['humidity']?.toString() ?? '',
      rainfall: json['rainfall']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
    );
  }
}

class CombinedIntelligenceData {
  final String reportId;
  final String generatedAt;
  final String provenance;
  final SoilHealthSummary soilHealthSummary;
  final List<CropCandidate> cropCandidates;
  final String topCrop;
  final FertilizerPrescription fertilizerPrescription;
  final YieldPredictionResult yieldPrediction;
  final WeatherConsiderations weatherConsiderations;
  final Map<String, dynamic> auditability;

  CombinedIntelligenceData({
    required this.reportId,
    required this.generatedAt,
    required this.provenance,
    required this.soilHealthSummary,
    required this.cropCandidates,
    required this.topCrop,
    required this.fertilizerPrescription,
    required this.yieldPrediction,
    required this.weatherConsiderations,
    required this.auditability,
  });

  factory CombinedIntelligenceData.fromJson(Map<String, dynamic> json) {
    final cropData = json['crop_suitability'] as Map<String, dynamic>? ?? {};
    final rawCandidates = (cropData['recommended_crops'] as List<dynamic>?) ??
        (cropData['candidates'] as List<dynamic>?) ??
        [];
    final candidates = rawCandidates
        .map((c) => CropCandidate.fromJson(c as Map<String, dynamic>))
        .toList();

    return CombinedIntelligenceData(
      reportId: json['report_id']?.toString() ?? '',
      generatedAt: json['generated_at']?.toString() ?? '',
      provenance: json['provenance']?.toString() ?? 'Based on your uploaded and verified soil report profile.',
      soilHealthSummary: SoilHealthSummary.fromJson(json['soil_health_summary'] as Map<String, dynamic>? ?? {}),
      cropCandidates: candidates,
      topCrop: cropData['top_crop']?.toString() ?? (candidates.isNotEmpty ? candidates.first.cropName : 'Maize'),
      fertilizerPrescription: FertilizerPrescription.fromJson(json['fertilizer_recommendation'] as Map<String, dynamic>? ?? {}),
      yieldPrediction: YieldPredictionResult.fromJson(json['yield_prediction'] as Map<String, dynamic>? ?? {}),
      weatherConsiderations: WeatherConsiderations.fromJson(json['weather_considerations'] as Map<String, dynamic>? ?? {}),
      auditability: json['auditability'] as Map<String, dynamic>? ?? {},
    );
  }
}
