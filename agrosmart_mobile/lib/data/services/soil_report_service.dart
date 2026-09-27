import '../../core/network/api_client.dart';
import '../../app/config/api_config.dart';
import '../models/soil_report_model.dart';

class SoilReportService {
  final ApiClient _apiClient;

  SoilReportService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Uploads a Soil Report PDF document and triggers the extraction pipeline.
  Future<SoilReportUploadData> uploadSoilReportPdf({
    required List<int> bytes,
    required String filename,
    String? userId,
  }) async {
    final response = await _apiClient.postMultipartBytes(
      ApiConfig.soilReportUploadEndpoint,
      bytes: bytes,
      filename: filename,
      fieldName: 'file',
    );
    final data = response['data'] as Map<String, dynamic>;
    return SoilReportUploadData.fromJson(data);
  }

  /// Human-in-the-loop: Updates or confirms corrected soil parameters before ML inference.
  Future<Map<String, dynamic>> updateReportParameters({
    required String reportId,
    required Map<String, dynamic> updatedParams,
  }) async {
    final response = await _apiClient.put(
      ApiConfig.soilReportUpdateEndpoint(reportId),
      body: updatedParams,
    );
    return response['data'] as Map<String, dynamic>? ?? {};
  }

  /// Triggers the 3 AI/ML modules using the verified Canonical Soil Profile.
  Future<CombinedIntelligenceData> analyzeSoilReport({
    required String reportId,
    Map<String, dynamic>? context,
  }) async {
    final response = await _apiClient.post(
      ApiConfig.soilReportAnalyzeEndpoint(reportId),
      body: context ?? {},
    );
    final data = response['data'] as Map<String, dynamic>;
    return CombinedIntelligenceData.fromJson(data);
  }

  /// Runs an instant realistic ICAR Soil Health Card demonstration report.
  Future<SoilReportUploadData> runSampleDemoReport({String? userId}) async {
    final endpoint = userId != null
        ? '${ApiConfig.soilReportSampleDemoEndpoint}?user_id=$userId'
        : ApiConfig.soilReportSampleDemoEndpoint;
    final response = await _apiClient.post(endpoint, body: {});
    final data = response['data'] as Map<String, dynamic>;
    return SoilReportUploadData.fromJson(data);
  }

  /// Retrieves previously analyzed reports history.
  Future<List<Map<String, dynamic>>> getReportHistory({String? userId}) async {
    final query = userId != null ? {'user_id': userId} : null;
    final response = await _apiClient.get(
      ApiConfig.soilReportHistoryEndpoint,
      queryParams: query,
    );
    final rawList = response['reports'] as List<dynamic>? ?? [];
    return rawList.map((e) => e as Map<String, dynamic>).toList();
  }
}
