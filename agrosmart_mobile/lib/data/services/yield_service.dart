import '../../core/network/api_client.dart';
import '../models/yield_prediction_model.dart';
import '../../app/config/api_config.dart';

class YieldService {
  final ApiClient _apiClient;

  YieldService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, List<String>>> getYieldDropdownOptions() async {
    final response = await _apiClient.get(ApiConfig.yieldMetadataEndpoint);
    return {
      'areas': (response['areas'] as List).map((e) => e.toString()).toList(),
      'items': (response['items'] as List).map((e) => e.toString()).toList(),
    };
  }

  Future<YieldPredictionResponse> predictYield(YieldPredictionRequest request) async {
    final response = await _apiClient.post(
      ApiConfig.yieldPredictEndpoint,
      body: request.toJson(),
    );
    return YieldPredictionResponse.fromJson(response);
  }
}
