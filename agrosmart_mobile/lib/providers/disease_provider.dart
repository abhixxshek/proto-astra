import 'package:flutter/foundation.dart';
import '../data/models/disease_detection_model.dart';
import '../data/services/disease_service.dart';

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

  Future<void> detectDisease({String selectedCrop = '-- All Crops --'}) async {
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
        selectedCrop: selectedCrop,
      );
      if (_result != null && !_result!.success) {
        _errorMessage = _result!.error ?? 'Model prediction was unsuccessful.';
        _result = null;
      }
    } catch (e) {
      _errorMessage = 'Disease detection error: $e';
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDemoData({String selectedCrop = '-- All Crops --'}) async {
    _isLoading = true;
    _errorMessage = null;
    _result = null;
    _selectedFileName = 'sample_leaf_diagnosis.jpg';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    // Generate sample 128x128 green leaf byte array
    final dummyBytes = Uint8List(128 * 128 * 3);
    for (int i = 0; i < dummyBytes.length; i += 3) {
      dummyBytes[i] = 40;     // R
      dummyBytes[i + 1] = 160; // G
      dummyBytes[i + 2] = 50;  // B
    }

    _selectedImageBytes = dummyBytes;

    _result = await _diseaseService.predictDisease(
      dummyBytes,
      filename: 'sample_leaf.jpg',
      selectedCrop: selectedCrop,
    );

    _isLoading = false;
    notifyListeners();
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
