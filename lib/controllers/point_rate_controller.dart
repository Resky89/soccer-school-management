import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/point_rate_model.dart';
import 'auth_controller.dart';

class PointRateController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController authController;

  List<PointRate> _pointRates = [];
  bool _isLoading = false;
  String? _error;

  List<PointRate> get pointRates => _pointRates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PointRateController(this.authController);

  Future<void> fetchPointRates() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/point-rates',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _pointRates = (data['data'] as List)
              .map((json) => PointRate.fromJson(json))
              .toList();
          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load point rates';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Connection error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPointRate(PointRate pointRate) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/point-rates'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(pointRate.toJson()),
      );

      print('Create Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchPointRates();
        return true;
      }
      return false;
    } catch (e) {
      print('Create error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePointRate(int id, PointRate pointRate) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/point-rates/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(pointRate.toJson()),
      );

      print('Update Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        await fetchPointRates();
        return true;
      }
      return false;
    } catch (e) {
      print('Update error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePointRate(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/point-rates/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        await fetchPointRates();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
