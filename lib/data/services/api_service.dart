import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // On macOS Simulator/Emulator, localhost points to the host machine
  // Android emulator requires 10.0.2.2.
  static const String _baseUrl = 'http://localhost:5001/api';
  
  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (hasToken) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ── Auth Endpoints ──

  Future<Map<String, dynamic>> register(String email, String password, String fullName) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken, {String? accessToken}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/google'),
      headers: _getHeaders(),
      body: jsonEncode({
        'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
      }),
    );
    return _handleResponse(response);
  }


  Future<void> logout() async {
    try {
      if (hasToken) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: _getHeaders(),
        );
      }
    } catch (_) {
      // Ignore network errors on logout, just proceed with local clearing
    } finally {
      await setToken(null);
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: _getHeaders(),
    );
    return _handleResponse(response);
  }

  // ── Cards Endpoints ──

  Future<List<dynamic>> getCards() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cards'),
      headers: _getHeaders(),
    );
    final data = _handleResponse(response);
    return data['cards'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getCard(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/cards/$id'),
      headers: _getHeaders(),
    );
    final data = _handleResponse(response);
    return data['card'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createCard(Map<String, dynamic> cardData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/cards'),
      headers: _getHeaders(),
      body: jsonEncode(cardData),
    );
    final data = _handleResponse(response);
    return data['card'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCard(String id, Map<String, dynamic> cardData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/cards/$id'),
      headers: _getHeaders(),
      body: jsonEncode(cardData),
    );
    final data = _handleResponse(response);
    return data['card'] as Map<String, dynamic>;
  }

  Future<void> deleteCard(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/cards/$id'),
      headers: _getHeaders(),
    );
    _handleResponse(response);
  }

  // Helper response validation
  Map<String, dynamic> _handleResponse(http.Response response) {
    final String body = response.body;
    final int code = response.statusCode;

    Map<String, dynamic> responseData = {};
    try {
      responseData = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Server returned invalid JSON response: $body');
    }

    if (code >= 200 && code < 300) {
      return responseData;
    } else {
      final errorMsg = responseData['error'] ?? 'Server request failed';
      throw Exception(errorMsg);
    }
  }
}
