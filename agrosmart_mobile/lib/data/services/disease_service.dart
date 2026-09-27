import 'dart:typed_data';
import '../../app/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/disease_detection_model.dart';

class DiseaseService {
  final ApiClient _apiClient;

  DiseaseService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<DiseasePredictionResponse> predictDisease(Uint8List imageBytes, {String filename = 'leaf_sample.jpg'}) async {
    final response = await _apiClient.postMultipartBytes(
      ApiConfig.diseasePredictEndpoint,
      bytes: imageBytes,
      filename: filename,
      fieldName: 'image',
    );
    return DiseasePredictionResponse.fromJson(response);
  }
}
