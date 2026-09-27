import 'package:flutter/foundation.dart';
import '../data/models/disease_detection_model.dart';

import '../data/services/disease_service.dart';

import '../../app/config/api_config.dart';

class DiseaseProvider extends ChangeNotifier {
  final DiseaseService _diseaseService;
  
  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  DiseasePredictionResponse? _result;
  bool _isLoading = false;
  String? _errorMessage;

  DiseaseProvider({DiseaseService? diseaseService}) : _diseaseService = diseaseService ?? DiseaseService();

  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? get selectedFileName => _selectedFileName;
  DiseasePredictionResponse? get result => _result;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setImage(Uint8List bytes, String filename) {
    _selectedImageBytes = bytes;
    _selectedFileName = filename;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> detectDisease() async {
    if (_selectedImageBytes == null) {
      _errorMessage = 'Please select or capture a plant leaf image first.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    try {
      _result = await _diseaseService.predictDisease(
        _selectedImageBytes!,
        filename: _selectedFileName ?? 'leaf_sample.jpg',
      );
      if (_result != null && !_result!.success) {
        _errorMessage = _result!.error ?? 'Model prediction was unsuccessful.';
        _result = null;
      }
    } catch (e) {
      _errorMessage = 'ML Server connection failed (${ApiConfig.baseUrl}).\nDetails: $e\n\nPlease verify that the Python Flask backend is running on your computer and the Server IP in settings matches your host.';
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void reset() {
    _selectedImageBytes = null;
    _selectedFileName = null;
    _result = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
