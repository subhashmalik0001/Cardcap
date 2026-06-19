import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _apiService.hasToken;

  /// Check initial authentication state.
  Future<void> checkAuth() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.init();
      if (_apiService.hasToken) {
        // Fetch fresh profile from backend
        try {
          final profileData = await _apiService.getProfile();
          _user = profileData['user'] as Map<String, dynamic>;
        } catch (e) {
          // If profile fetch fails (e.g. invalid/expired token), sign out
          await _apiService.setToken(null);
          _user = null;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new account.
  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.register(email, password, fullName);
      final String token = data['token'];
      _user = data['user'] as Map<String, dynamic>;
      await _apiService.setToken(token);

      // Sync auth session to Supabase client for storage bucket RLS policies
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        print("Failed to sync register session to Supabase client: $e");
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Log in via email/password.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.login(email, password);
      final String token = data['token'];
      _user = data['user'] as Map<String, dynamic>;
      await _apiService.setToken(token);

      // Sync auth session to Supabase client for storage bucket RLS policies
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        print("Failed to sync login session to Supabase client: $e");
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mock Google Sign In for demo (signs in user with a demo Google Account).
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a production app with the native Google SDK configured, we would obtain the actual
      // ID Token and Access Token from the SDK. For local development and demonstration, we
      // pass 'mock_google_id_token' which our backend handles by creating/retrieving a secure
      // demo Google user in the database.
      final idToken = 'mock_google_id_token';
      
      final data = await _apiService.loginWithGoogle(idToken);
      final String token = data['token'];
      _user = data['user'] as Map<String, dynamic>;
      await _apiService.setToken(token);
      return true;
    } catch (e) {
      _error = 'Google Sign In failed: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Invalidate and log out session.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
      _user = null;
      // Sign out from Supabase client
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current auth error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
