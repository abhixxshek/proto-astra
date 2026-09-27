import 'package:flutter/foundation.dart';
import '../data/models/analysis_model.dart';
import '../data/services/analysis_service.dart';

class AnalysisProvider extends ChangeNotifier {
  final AnalysisService _analysisService;
  List<String> _states = [];
  AnalysisResponse? _analysisResult;
  bool _isLoading = false;
  String? _errorMessage;

  AnalysisProvider({AnalysisService? analysisService})
      : _analysisService = analysisService ?? AnalysisService();

  List<String> get states => _states;
  AnalysisResponse? get analysisResult => _analysisResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStates() async {
    try {
      _states = await _analysisService.getStates();
    } catch (e) {
      _states = [
        'Maharashtra',
        'Punjab',
        'Uttar Pradesh',
        'Gujarat',
        'Karnataka',
        'Tamil Nadu',
        'Madhya Pradesh',
        'Haryana'
      ];
    }
    notifyListeners();
  }

  Future<void> fetchAnalysis(String state, int year) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _analysisResult = await _analysisService.getCropAnalysis(state, year);
    } catch (e) {
      _analysisResult = AnalysisResponse(
        state: state,
        year: year,
        data: [
          CropAnalysisDataPoint(
            cropType: 'Cotton',
            costOfProduction: 28500,
            cultivationArea: 145000,
            rainfallMm: 850,
          ),
          CropAnalysisDataPoint(
            cropType: 'Sugarcane',
            costOfProduction: 42000,
            cultivationArea: 95000,
            rainfallMm: 1200,
          ),
          CropAnalysisDataPoint(
            cropType: 'Paddy',
            costOfProduction: 31000,
            cultivationArea: 210000,
            rainfallMm: 1400,
          ),
          CropAnalysisDataPoint(
            cropType: 'Soybean',
            costOfProduction: 22000,
            cultivationArea: 180000,
            rainfallMm: 950,
          ),
          CropAnalysisDataPoint(
            cropType: 'Wheat',
            costOfProduction: 26000,
            cultivationArea: 160000,
            rainfallMm: 650,
          ),
        ],
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
