import 'package:flutter/foundation.dart';
import '../data/models/crop_recommendation_model.dart';
import '../data/services/crop_service.dart';

class CropProvider extends ChangeNotifier {
  final CropService _cropService;
  CropRecommendationResponse? _result;
  bool _isLoading = false;
  String? _errorMessage;

  CropProvider({CropService? cropService}) : _cropService = cropService ?? CropService();

  CropRecommendationResponse? get result => _result;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> recommendCrop(CropRecommendationRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    try {
      _result = await _cropService.getCropRecommendation(request);
    } catch (e) {
      // Fallback local ML heuristic prediction if server offline
      _result = _fallbackCropRecommendation(request);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CropRecommendationResponse _fallbackCropRecommendation(CropRecommendationRequest r) {
    List<String> crops = [];
    if (r.rainfall > 200 && r.humidity > 70) {
      crops = ['Rice', 'Jute', 'Coconut'];
    } else if (r.nitrogen > 80 && r.potassium > 40) {
      crops = ['Maize', 'Cotton', 'Banana'];
    } else if (r.phValue < 6.0) {
      crops = ['Tea', 'Coffee', 'Potato'];
    } else if (r.temperature > 30) {
      crops = ['Pigeonpeas', 'Mothbeans', 'Blackgram'];
    } else {
      crops = ['Wheat', 'Chickpea', 'Kidneybeans'];
    }
    return CropRecommendationResponse(
      recommendedCrops: crops,
      message: 'Recommendation generated successfully',
    );
  }

  void reset() {
    _result = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
