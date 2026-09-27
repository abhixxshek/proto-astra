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


  Future<void> loadDemoData() async {
    _isLoading = true;
    _errorMessage = null;
    _result = null;
    _selectedFileName = 'sample_potato_late_blight_leaf.jpg';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _result = DiseasePredictionResponse.fromJson({
      'success': true,
      'prediction_index': 12,
      'raw_class_label': 'Potato___Late_blight',
      'disease_name': 'Potato Late Blight (Phytophthora infestans)',
      'confidence': 97.4,
      'description': 'Dark, water-soaked irregular lesions appearing on leaf tips and margins. Leaves quickly brown, shrivel, and die during humid conditions.',
      'prevention': '1. Use certified disease-free seed tubers.\n2. Ensure proper row spacing and drainage.\n3. Apply protective fungicide before canopy closure.\n4. Destroy infected crop residue immediately post-harvest.',
      'disease_image_url': 'https://images.unsplash.com/photo-1592417817098-8f3d6ef23a8d?w=600',
      'supplement': {
        'name': 'Mancozeb 75% WP Protective Fungicide (Ridomil Gold)',
        'image_url': 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?w=300',
        'buy_link': 'https://www.amazon.in/s?k=Mancozeb+75+WP+Fungicide',
        'amazon_buy_link': 'https://www.amazon.in/s?k=Mancozeb+75+WP+Fungicide',
        'amazon_search_query': 'Mancozeb 75 WP Fungicide'
      },
      'top_predictions': [
        {
          'index': 12,
          'class_label': 'Potato___Late_blight',
          'disease_name': 'Potato Late Blight',
          'confidence': 97.4
        },
        {
          'index': 11,
          'class_label': 'Potato___Early_blight',
          'disease_name': 'Potato Early Blight',
          'confidence': 2.1
        },
        {
          'index': 13,
          'class_label': 'Potato___healthy',
          'disease_name': 'Healthy Potato Leaf',
          'confidence': 0.5
        }
      ]
    });

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
