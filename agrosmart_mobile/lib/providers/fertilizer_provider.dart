import 'package:flutter/foundation.dart';
import '../data/models/fertilizer_recommendation_model.dart';
import '../data/services/fertilizer_service.dart';

class FertilizerProvider extends ChangeNotifier {
  final FertilizerService _fertilizerService;
  FertilizerRecommendationResponse? _result;
  bool _isLoading = false;
  String? _errorMessage;

  FertilizerProvider({FertilizerService? fertilizerService})
      : _fertilizerService = fertilizerService ?? FertilizerService();

  FertilizerRecommendationResponse? get result => _result;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> recommendFertilizer(FertilizerRecommendationRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    try {
      _result = await _fertilizerService.getFertilizerRecommendation(request);
    } catch (e) {
      _result = _fallbackFertilizerRecommendation(request);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  FertilizerRecommendationResponse _fallbackFertilizerRecommendation(FertilizerRecommendationRequest r) {
    String fertilizer;
    if (r.nitrogen < 20) {
      fertilizer = 'Urea';
    } else if (r.phosphorous < 20) {
      fertilizer = 'DAP (Di-ammonium Phosphate)';
    } else if (r.potassium < 20) {
      fertilizer = 'MOP (Muriate of Potash)';
    } else if (r.soilType == 'Black' || r.soilType == 'Clayey') {
      fertilizer = '14-35-14 NPK Complex';
    } else {
      fertilizer = '28-28-0 NPK Fertilizer';
    }
    return FertilizerRecommendationResponse.fromJson({'recommended_fertilizer': fertilizer});
  }


  void reset() {
    _result = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
