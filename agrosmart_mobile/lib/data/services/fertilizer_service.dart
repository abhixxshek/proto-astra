import '../../core/network/api_client.dart';
import '../models/fertilizer_recommendation_model.dart';
import '../../app/config/api_config.dart';

class FertilizerService {
  final ApiClient _apiClient;

  FertilizerService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<FertilizerRecommendationResponse> getFertilizerRecommendation(
      FertilizerRecommendationRequest request) async {
    final response = await _apiClient.post(
      ApiConfig.fertilizerRecommendEndpoint,
      body: request.toJson(),
    );
    return FertilizerRecommendationResponse.fromJson(response);
  }
}
