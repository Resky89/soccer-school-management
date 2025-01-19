import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/assessment_model.dart';
import 'auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AssessmentController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController authController;
  List<AssessmentModel> _assessments = [];
  bool _isLoading = false;
  String? _error;

  List<AssessmentModel> get assessments => _assessments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AssessmentController(this.authController);

  Future<void> fetchAssessmentsByStudentAndAspect(
      String studentName, String aspectName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.get(
        Uri.parse(
            '$baseUrl/assessments/student?aspect_name=$aspectName&student_name=$studentName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _assessments = (data['data'] as List)
              .map((json) => AssessmentModel.fromJson(json))
              .toList();
          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load assessments';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error: $e');
      _error = 'Connection error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAssessment(AssessmentModel assessment) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/assessments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(assessment.toJson()),
      );

      print('Create response status: ${response.statusCode}');
      print('Create response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error creating assessment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAssessment(String id, AssessmentModel assessment) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/assessments/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(assessment.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating assessment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAssessment(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/assessments/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = data['success'] ?? false;
        if (success) {
          _assessments
              .removeWhere((assessment) => assessment.idAssessment == id);
          notifyListeners();
        }
        return success;
      }
      return false;
    } catch (e) {
      print('Error deleting assessment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAssessments() {
    _assessments = [];
    notifyListeners();
  }
}
