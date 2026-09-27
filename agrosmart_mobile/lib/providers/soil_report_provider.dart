import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/soil_report_model.dart';
import '../data/services/soil_report_service.dart';

enum SoilReportStep {
  upload,
  reviewParameters,
  analysisResults,
}

class SoilReportProvider extends ChangeNotifier {
  final SoilReportService _service;

  SoilReportProvider({SoilReportService? service})
      : _service = service ?? SoilReportService() {
    _loadPersistedSoilProfile();
  }

  SoilReportStep _currentStep = SoilReportStep.upload;
  SoilReportStep get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _loadingMessage = '';
  String get loadingMessage => _loadingMessage;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _selectedFilename;
  String? get selectedFilename => _selectedFilename;

  SoilReportUploadData? _uploadData;
  SoilReportUploadData? get uploadData => _uploadData;

  CombinedIntelligenceData? _analysisResult;
  CombinedIntelligenceData? get analysisResult => _analysisResult;

  // Stores in-progress farmer corrections
  final Map<String, dynamic> _editedValues = {};
  Map<String, dynamic> get editedValues => _editedValues;

  // Persisted state across app sessions
  Map<String, dynamic>? _persistedProfile;
  String? _persistedReportId;
  String? _persistedTopCrop;
  String? _persistedDate;

  // Crop selected for cross-feature navigation (e.g. from Soil Report -> Yield / Fertilizer)
  String? _targetPreselectedCrop;
  String? get targetPreselectedCrop => _targetPreselectedCrop;

  void setTargetPreselectedCrop(String? crop) {
    _targetPreselectedCrop = crop;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // INTEGRATED SOIL PROFILE ACCESSORS (Used by Crop, Fertilizer, Yield screens)
  // --------------------------------------------------------------------------
  bool get hasSoilData =>
      _uploadData != null || (_persistedProfile != null && _persistedProfile!.isNotEmpty);

  Map<String, dynamic>? get effectiveProfile {
    if (_uploadData != null) {
      final map = Map<String, dynamic>.from(_uploadData!.canonicalSoilProfile);
      _editedValues.forEach((k, v) {
        if (v != null) map[k] = v;
      });
      return map;
    }
    return _persistedProfile;
  }

  String? get reportId => _uploadData?.reportId ?? _persistedReportId;
  String? get reportDate => _uploadData?.metadata.sampleDate ?? _persistedDate;

  double? get nitrogen {
    final val = effectiveProfile?['nitrogen'];
    return (val as num?)?.toDouble();
  }

  double? get phosphorus {
    final val = effectiveProfile?['phosphorus'];
    return (val as num?)?.toDouble();
  }

  double? get potassium {
    final val = effectiveProfile?['potassium'];
    return (val as num?)?.toDouble();
  }

  double? get ph {
    final val = effectiveProfile?['ph'];
    return (val as num?)?.toDouble();
  }

  String? get soilType {
    final val = effectiveProfile?['soil_type'];
    return val?.toString();
  }

  double? get soilMoisture {
    final val = effectiveProfile?['soil_moisture'];
    return (val as num?)?.toDouble();
  }

  String? get topRecommendedCrop =>
      _analysisResult?.topCrop ?? _persistedTopCrop;

  double? get temperature {
    final weatherStr = _analysisResult?.weatherConsiderations.temperature;
    if (weatherStr != null) {
      final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(weatherStr);
      if (match != null) return double.tryParse(match.group(0)!);
    }
    return null;
  }

  double? get humidity {
    final weatherStr = _analysisResult?.weatherConsiderations.humidity;
    if (weatherStr != null) {
      final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(weatherStr);
      if (match != null) return double.tryParse(match.group(0)!);
    }
    return null;
  }

  double? get rainfall {
    final weatherStr = _analysisResult?.weatherConsiderations.rainfall;
    if (weatherStr != null) {
      final match = RegExp(r'[-+]?\d*\.?\d+').firstMatch(weatherStr);
      if (match != null) return double.tryParse(match.group(0)!);
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // PERSISTENCE HELPERS
  // --------------------------------------------------------------------------
  Future<void> _loadPersistedSoilProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('cached_soil_profile');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        _persistedProfile = jsonDecode(jsonStr) as Map<String, dynamic>;
        _persistedReportId = prefs.getString('cached_soil_report_id');
        _persistedTopCrop = prefs.getString('cached_soil_top_crop');
        _persistedDate = prefs.getString('cached_soil_report_date');
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _persistSoilProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profile = effectiveProfile;
      if (profile != null) {
        await prefs.setString('cached_soil_profile', jsonEncode(profile));
      }
      if (reportId != null) {
        await prefs.setString('cached_soil_report_id', reportId!);
      }
      if (topRecommendedCrop != null) {
        await prefs.setString('cached_soil_top_crop', topRecommendedCrop!);
      }
      if (reportDate != null) {
        await prefs.setString('cached_soil_report_date', reportDate!);
      }
    } catch (_) {}
  }

  void _setLoading(bool loading, [String message = '']) {
    _isLoading = loading;
    _loadingMessage = message;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Lets farmer pick a PDF file from device and triggers extraction pipeline.
  Future<void> pickAndUploadPdf() async {
    try {
      _setError(null);
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'PDF'],
      );

      if (file == null) return;

      _selectedFilename = file.name;
      _setLoading(true, 'Reading selected file...');

      List<int>? bytes;
      try {
        bytes = await file.readAsBytes();
      } catch (_) {}

      if (bytes == null || bytes.isEmpty) {
        try {
          bytes = await file.xFile.readAsBytes();
        } catch (_) {}
      }

      if ((bytes == null || bytes.isEmpty) && !kIsWeb && file.path != null) {
        try {
          final ioFile = File(file.path!);
          if (await ioFile.exists()) {
            bytes = await ioFile.readAsBytes();
          }
        } catch (_) {}
      }

      if (bytes == null || bytes.isEmpty) {
        _setError('Unable to read selected PDF file. Please ensure storage permissions are granted.');
        return;
      }

      _setLoading(true, 'Extracting soil parameters and verifying lab data...');

      _uploadData = await _service.uploadSoilReportPdf(
        bytes: bytes,
        filename: file.name,
      );

      _editedValues.clear();
      _currentStep = SoilReportStep.reviewParameters;
      _isLoading = false;
      await _persistSoilProfile();
      notifyListeners();
    } catch (e) {
      final cleanMsg = e.toString().replaceFirst('ApiException: ', '');
      _setError(cleanMsg);
    }
  }

  /// One-tap demo: Generates realistic ICAR Soil Health Card PDF on server and parses it.
  Future<void> loadSampleDemoReport() async {
    try {
      _setError(null);
      _setLoading(true, 'Generating ICAR Soil Health Card Demo Report...');
      _selectedFilename = 'ICAR_Soil_Health_Card_Demo.pdf';

      _uploadData = await _service.runSampleDemoReport();
      _editedValues.clear();
      _currentStep = SoilReportStep.reviewParameters;
      _isLoading = false;
      await _persistSoilProfile();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load demo report: ${e.toString()}');
    }
  }

  /// Human-in-the-loop: Updates a parameter value locally before sending to server.
  void updateParameterValue(String key, dynamic value) {
    _editedValues[key] = value;
    if (_uploadData != null && _uploadData!.parameters.containsKey(key)) {
      final param = _uploadData!.parameters[key]!;
      param.normalizedValue = value;
      param.status = 'VERIFIED';
    }
    _persistSoilProfile();
    notifyListeners();
  }

  /// Submits farmer reviews, creates the Canonical Soil Profile, and runs all 3 AI models.
  Future<void> confirmAndRunIntelligence({
    String? selectedCrop,
    double? temperature,
    double? humidity,
    double? rainfall,
  }) async {
    if (_uploadData == null) return;

    try {
      _setError(null);
      _setLoading(true, 'Verifying canonical soil profile with AI modules...');

      // 1. Sync any farmer edits to backend
      if (_editedValues.isNotEmpty) {
        await _service.updateReportParameters(
          reportId: _uploadData!.reportId,
          updatedParams: _editedValues,
        );
      }

      // 2. Generate combined intelligence
      _loadingMessage = 'Running Crop, Yield, and Fertilizer ML Models...';
      notifyListeners();

      final context = <String, dynamic>{};
      if (selectedCrop != null && selectedCrop.isNotEmpty) {
        context['selected_crop'] = selectedCrop;
      }
      if (temperature != null) context['temperature'] = temperature;
      if (humidity != null) context['humidity'] = humidity;
      if (rainfall != null) context['rainfall'] = rainfall;

      _analysisResult = await _service.analyzeSoilReport(
        reportId: _uploadData!.reportId,
        context: context,
      );

      _currentStep = SoilReportStep.analysisResults;
      _isLoading = false;
      await _persistSoilProfile();
      notifyListeners();
    } catch (e) {
      _setError('Intelligence generation failed: ${e.toString()}');
    }
  }

  void goToStep(SoilReportStep step) {
    _currentStep = step;
    notifyListeners();
  }

  void reset() {
    _currentStep = SoilReportStep.upload;
    _selectedFilename = null;
    _uploadData = null;
    _analysisResult = null;
    _editedValues.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
