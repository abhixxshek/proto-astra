import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../app/config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  List<String> _buildCandidateList() {
    final list = <String>[ApiConfig.baseUrl];
    for (final c in ApiConfig.candidateBaseUrls) {
      if (!list.contains(c)) list.add(c);
    }
    return list;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers, Map<String, String>? queryParams}) async {
    final candidates = _buildCandidateList();
    dynamic lastError;

    for (final base in candidates) {
      try {
        Uri uri = Uri.parse('$base$endpoint');
        if (queryParams != null && queryParams.isNotEmpty) {
          uri = uri.replace(queryParameters: queryParams);
        }

        final response = await _client.get(
          uri,
          headers: {..._defaultHeaders, ...?headers},
        ).timeout(ApiConfig.connectionTimeout);

        final result = _processResponse(response);
        if (base != ApiConfig.baseUrl) {
          ApiConfig.setBaseUrl(base);
        }
        return result;
      } on SocketException catch (e) {
        lastError = e;
      } on http.ClientException catch (e) {
        lastError = e;
      } on TimeoutException catch (e) {
        lastError = e;
      }
    }

    throw ApiException('Unable to connect to AgroSmart server. Please verify backend is running.\nDetails: $lastError');
  }

  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body, Map<String, String>? headers}) async {
    final candidates = _buildCandidateList();
    dynamic lastError;

    for (final base in candidates) {
      try {
        final uri = Uri.parse('$base$endpoint');
        final response = await _client
            .post(
              uri,
              headers: {..._defaultHeaders, ...?headers},
              body: jsonEncode(body),
            )
            .timeout(ApiConfig.connectionTimeout);

        final result = _processResponse(response);
        if (base != ApiConfig.baseUrl) {
          ApiConfig.setBaseUrl(base);
        }
        return result;
      } on SocketException catch (e) {
        lastError = e;
      } on http.ClientException catch (e) {
        lastError = e;
      } on TimeoutException catch (e) {
        lastError = e;
      }
    }

    throw ApiException('Unable to connect to AgroSmart server. Please verify backend is running.\nDetails: $lastError');
  }

  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body, Map<String, String>? headers}) async {
    final candidates = _buildCandidateList();
    dynamic lastError;

    for (final base in candidates) {
      try {
        final uri = Uri.parse('$base$endpoint');
        final response = await _client
            .put(
              uri,
              headers: {..._defaultHeaders, ...?headers},
              body: jsonEncode(body),
            )
            .timeout(ApiConfig.connectionTimeout);

        final result = _processResponse(response);
        if (base != ApiConfig.baseUrl) {
          ApiConfig.setBaseUrl(base);
        }
        return result;
      } on SocketException catch (e) {
        lastError = e;
      } on http.ClientException catch (e) {
        lastError = e;
      } on TimeoutException catch (e) {
        lastError = e;
      }
    }

    throw ApiException('Unable to connect to AgroSmart server. Please verify backend is running.\nDetails: $lastError');
  }

  Future<dynamic> postMultipartBytes(
    String endpoint, {
    required List<int> bytes,
    required String filename,
    String fieldName = 'image',
    Map<String, String>? headers,
  }) async {
    final candidates = _buildCandidateList();
    dynamic lastError;

    for (final base in candidates) {
      try {
        final uri = Uri.parse('$base$endpoint');
        final request = http.MultipartRequest('POST', uri);
        if (headers != null) {
          request.headers.addAll(headers);
        }
        request.files.add(http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
        ));
        final streamedResponse = await request.send().timeout(ApiConfig.connectionTimeout);
        final response = await http.Response.fromStream(streamedResponse);
        final result = _processResponse(response);
        if (base != ApiConfig.baseUrl) {
          ApiConfig.setBaseUrl(base);
        }
        return result;
      } on SocketException catch (e) {
        lastError = e;
      } on http.ClientException catch (e) {
        lastError = e;
      } on TimeoutException catch (e) {
        lastError = e;
      }
    }

    throw ApiException('Unable to upload to AgroSmart server. Please verify backend is running.\nDetails: $lastError');
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return {};
        return jsonDecode(response.body);
      case 400:
        final body = jsonDecode(response.body);
        throw ApiException(body['error'] ?? body['message'] ?? 'Bad Request', statusCode: 400);
      case 401:
        throw ApiException('Unauthorized access. Please login again.', statusCode: 401);
      case 404:
        throw ApiException('Resource not found on server.', statusCode: 404);
      case 500:
        throw ApiException('Internal server error. Please try again later.', statusCode: 500);
      default:
        throw ApiException('Unexpected server response (${response.statusCode})', statusCode: response.statusCode);
    }
  }
}
