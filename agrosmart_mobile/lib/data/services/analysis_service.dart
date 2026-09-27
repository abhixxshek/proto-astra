import '../../core/network/api_client.dart';
import '../models/analysis_model.dart';
import '../../app/config/api_config.dart';

class AnalysisService {
  final ApiClient _apiClient;

  AnalysisService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<String>> getStates() async {
    final response = await _apiClient.get('${ApiConfig.analysisMetadataEndpoint}/states');
    return (response['states'] as List).map((e) => e.toString()).toList();
  }

  Future<AnalysisResponse> getCropAnalysis(String state, int year) async {
    final response = await _apiClient.post(
      ApiConfig.analysisEndpoint,
      body: {
        'state': state,
        'year': year,
      },
    );
    return AnalysisResponse.fromJson(response);
  }
}
