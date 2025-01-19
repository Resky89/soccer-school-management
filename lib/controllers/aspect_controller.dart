import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/aspect_model.dart';
import 'auth_controller.dart';

class AspectController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController _authController;

  List<AspectModel> _aspects = [];
  bool _isLoading = false;
  String? _error;

  List<AspectModel> get aspects => _aspects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AspectController(this._authController);

  Future<void> fetchAspects() async {
    try {
      setLoading(true);
      final response = await _authController.authorizedRequest(
        'GET',
        '/aspects',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _aspects = (data['data'] as List)
            .map((item) => AspectModel.fromJson(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching aspects: $e');
      _error = 'Connection error occurred';
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createAspect(String nameAspect) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authController.getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/aspects'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name_aspect': nameAspect}),
      );

      if (response.statusCode == 201) {
        await fetchAspects();
        return true;
      }
      _error = 'Failed to create aspect';
      return false;
    } catch (e) {
      _error = 'Connection error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAspect(int id, String nameAspect) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authController.getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/aspects/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name_aspect': nameAspect}),
      );

      if (response.statusCode == 200) {
        await fetchAspects();
        return true;
      }
      _error = 'Failed to update aspect';
      return false;
    } catch (e) {
      _error = 'Connection error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAspect(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _authController.getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/aspects/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchAspects();
        return true;
      }
      _error = 'Failed to delete aspect';
      return false;
    } catch (e) {
      _error = 'Connection error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }
}
