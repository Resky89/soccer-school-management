import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Tambahkan property untuk menyimpan token di memory
  String? _accessToken;
  String? _refreshToken;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add getter for user name
  String get userName => _user?.name ?? 'User';

  Future<bool> login(String email, String birthDate) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Login request - Email: $email, Date: $birthDate');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/management'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'date_birth': birthDate,
        }),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Pastikan data['data'] dan token ada sebelum mengaksesnya
        if (data['data'] != null &&
            data['data']['accessToken'] != null &&
            data['data']['refreshToken'] != null) {
          // Simpan token di memory dan storage
          _accessToken = data['data']['accessToken'];
          _refreshToken = data['data']['refreshToken'];

          await storage.write(key: 'accessToken', value: _accessToken);
          await storage.write(key: 'refreshToken', value: _refreshToken);

          await getProfile();
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _error = data['message'] ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Login error: $e');
      _error = 'Connection error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken =
          _refreshToken ?? await storage.read(key: 'refreshToken');
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          // Update token di memory dan storage
          _accessToken = data['data']['accessToken'];
          await storage.write(key: 'accessToken', value: _accessToken);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  }

  Future<void> getProfile() async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        await logout();
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/management/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _user = UserModel.fromJson(data['data']['management']);
          notifyListeners();
          return;
        }
      }

      if (response.statusCode == 401) {
        // Token expired, coba refresh
        final refreshSuccess = await refreshToken();
        if (refreshSuccess) {
          await getProfile(); // Retry dengan token baru
          return;
        }
      }

      await logout();
    } catch (e) {
      print('GetProfile error: $e');
      await logout();
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    // Clear memory tokens
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    notifyListeners();
  }

  // Modifikasi method getAccessToken
  Future<String?> getAccessToken() async {
    // Cek dulu token di memory
    if (_accessToken != null) {
      return _accessToken;
    }

    // Jika tidak ada di memory, ambil dari storage
    _accessToken = await storage.read(key: 'accessToken');
    return _accessToken;
  }

  // Tambahkan method untuk validasi token
  Future<bool> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/management/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Modifikasi checkAuth untuk menangani expired token
  Future<bool> checkAuth() async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      final refreshTokenStr = await storage.read(key: 'refreshToken');

      // Jika tidak ada token sama sekali
      if (accessToken == null && refreshTokenStr == null) {
        return false;
      }

      // Coba validasi access token jika ada
      if (accessToken != null) {
        final isAccessTokenValid = await validateToken(accessToken);
        if (isAccessTokenValid) {
          await getProfile();
          return true;
        }
      }

      // Jika access token invalid/expired dan ada refresh token, coba refresh
      if (refreshTokenStr != null) {
        final refreshSuccess = await refreshToken();
        if (refreshSuccess) {
          await getProfile();
          return true;
        }
      }

      // Jika refresh gagal, coba koneksi ulang ke database
      try {
        final response =
            await http.get(Uri.parse('$baseUrl/management/profile'));
        if (response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        print('Database connection error: $e');
      }

      return false;
    } catch (e) {
      print('CheckAuth error: $e');
      return false;
    }
  }

  int _getMonthNumber(String monthAbbr) {
    const months = {
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MAY': 5,
      'JUN': 6,
      'JUL': 7,
      'AUG': 8,
      'SEP': 9,
      'OCT': 10,
      'NOV': 11,
      'DEC': 12
    };
    return months[monthAbbr] ?? 1;
  }

  // Method untuk menghandle request API dengan auto refresh
  Future<http.Response> authorizedRequest(
    String method,
    String endpoint, {
    Map<String, String>? formData,
    String? imagePath,
    bool isFormData = false,
  }) async {
    try {
      var token = await getAccessToken();
      if (token == null) {
        throw Exception('No token available');
      }

      http.Response response;

      // Initial request
      if (isFormData) {
        final request =
            http.MultipartRequest(method, Uri.parse('$baseUrl$endpoint'));
        if (formData != null) request.fields.addAll(formData);
        if (imagePath != null) {
          request.files
              .add(await http.MultipartFile.fromPath('photo', imagePath));
        }
        request.headers['Authorization'] = 'Bearer $token';
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        final url = Uri.parse('$baseUrl$endpoint');
        response = await _makeRequest(method, url, token, formData);
      }

      // Handle 401 (Unauthorized)
      if (response.statusCode == 401) {
        print('Token expired, attempting refresh...');
        final refreshSuccess = await refreshToken();

        if (!refreshSuccess) {
          await logout();
          throw Exception('Session expired');
        }

        // Retry with new token
        token = await getAccessToken();
        if (token == null) {
          await logout();
          throw Exception('Token refresh failed');
        }

        // Retry request with new token
        if (isFormData) {
          final request =
              http.MultipartRequest(method, Uri.parse('$baseUrl$endpoint'));
          if (formData != null) request.fields.addAll(formData);
          if (imagePath != null) {
            request.files
                .add(await http.MultipartFile.fromPath('photo', imagePath));
          }
          request.headers['Authorization'] = 'Bearer $token';
          final streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
        } else {
          final url = Uri.parse('$baseUrl$endpoint');
          response = await _makeRequest(method, url, token, formData);
        }
      }

      // Handle 403 (Forbidden)
      if (response.statusCode == 403) {
        print('Access forbidden, logging out...');
        await logout();
        throw Exception('Access forbidden');
      }

      return response;
    } catch (e) {
      print('Authorization request error: $e');
      rethrow;
    }
  }

  // Helper method untuk membuat HTTP request
  Future<http.Response> _makeRequest(
    String method,
    Uri url,
    String token,
    Map<String, String>? formData,
  ) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
      case 'POST':
        return await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: formData != null ? jsonEncode(formData) : null,
        );
      case 'PUT':
        return await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: formData != null ? jsonEncode(formData) : null,
        );
      case 'DELETE':
        return await http.delete(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
}
