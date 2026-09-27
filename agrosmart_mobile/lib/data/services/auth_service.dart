import '../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../../app/config/api_config.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<UserModel> login(String username, String password) async {
    final response = await _apiClient.post(
      ApiConfig.loginEndpoint,
      body: {'username': username, 'password': password},
    );
    return UserModel.fromJson(response['user']);
  }

  Future<void> signup(String username, String email, String password) async {
    await _apiClient.post(
      ApiConfig.signupEndpoint,
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
  }

  Future<UserModel> updateProfile(UserModel user) async {
    final response = await _apiClient.post(
      ApiConfig.profileEndpoint,
      body: user.toJson(),
    );
    return UserModel.fromJson(response['user']);
  }
}
