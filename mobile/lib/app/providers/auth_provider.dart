import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  static const _tokenKey = 'lumen_auth_token';

  final AuthService _authService;

  User? _user;
  String? _token;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isBootstrapping = true;

  User? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isBootstrapping => _isBootstrapping;
  bool get isLoggedIn => _user != null && _token != null;

  Future<void> bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString(_tokenKey);
      if (storedToken == null || storedToken.isEmpty) {
        return;
      }
      final user = await _authService.me(storedToken);
      _token = storedToken;
      _user = user;
    } catch (_) {
      await _clearSession();
    } finally {
      _isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    return _runAuth(() async {
      final result = await _authService.login(
        phone: Validators.normalizePhone(phone),
        password: password,
      );
      await _persistSession(result);
    });
  }

  Future<bool> signup({
    required String username,
    required String phone,
    required String password,
  }) async {
    return _runAuth(() async {
      final result = await _authService.signup(
        username: username.trim(),
        phone: Validators.normalizePhone(phone),
        password: password,
      );
      await _persistSession(result);
    });
  }

  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAuth(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistSession(AuthResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, result.token);
    _token = result.token;
    _user = result.user;
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _token = null;
    _user = null;
  }
}
