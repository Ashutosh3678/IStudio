import '../models/user.dart';
import 'api_service.dart';

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final User user;
}

class AuthService {
  AuthService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<AuthResult> signup({
    required String username,
    required String phone,
    required String password,
  }) async {
    final payload = await _api.post('/auth/signup', {
      'username': username.trim(),
      'phone': phone,
      'password': password,
    });
    return _parseAuth(payload);
  }

  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    final payload = await _api.post('/auth/login', {
      'phone': phone,
      'password': password,
    });
    return _parseAuth(payload);
  }

  Future<User> me(String token) async {
    final payload = await _api.get('/auth/me', token: token);
    final userJson = payload['user'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw const ApiException('Session could not be restored.');
    }
    return User.fromJson(userJson);
  }

  AuthResult _parseAuth(Map<String, dynamic> payload) {
    final token = payload['token'] as String?;
    final userJson = payload['user'] as Map<String, dynamic>?;
    if (token == null || userJson == null) {
      throw const ApiException('Invalid authentication response.');
    }
    return AuthResult(token: token, user: User.fromJson(userJson));
  }
}
