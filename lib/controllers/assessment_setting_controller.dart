import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/assessment_setting_model.dart';
import 'auth_controller.dart';

class AssessmentSettingController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController authController;
  bool _isLoading = false;
  String? _error;
  List<AssessmentSettingResponse> _assessmentSettings = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AssessmentSettingResponse> get assessmentSettings => _assessmentSettings;

  AssessmentSettingController(this.authController);

  Future<void> fetchAssessmentSettings(String nameAspect) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/assessment-settings?name_aspect=$nameAspect'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _assessmentSettings = (data['data'] as List)
              .map((item) => AssessmentSettingResponse.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAssessmentSetting(AssessmentSettingModel setting) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/assessment-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(setting.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchAssessmentSettings(setting.nameAspect);
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating assessment setting: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAssessmentSetting(
      int id, AssessmentSettingModel setting) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/assessment-settings/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(setting.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchAssessmentSettings(setting.nameAspect);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating assessment setting: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAssessmentSetting(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/assessment-settings/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting assessment setting: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
