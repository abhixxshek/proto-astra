import '../../core/network/api_client.dart';
import '../models/crop_recommendation_model.dart';
import '../../app/config/api_config.dart';

class CropService {
  final ApiClient _apiClient;

  CropService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<CropRecommendationResponse> getCropRecommendation(CropRecommendationRequest request) async {
    final response = await _apiClient.post(
      ApiConfig.cropRecommendEndpoint,
      body: request.toJson(),
    );
    return CropRecommendationResponse.fromJson(response);
  }
}
