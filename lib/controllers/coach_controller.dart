import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/coach_model.dart';
import 'auth_controller.dart';

class CoachController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController authController;

  List<CoachModel> _coaches = [];
  bool _isLoading = false;
  String? _error;

  List<CoachModel> get coaches => _coaches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CoachController(this.authController);

  Future<void> fetchCoaches() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Menggunakan authorizedRequest untuk handle auto refresh token
      final response = await authController.authorizedRequest(
        'GET',
        '/coaches',
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          final List<dynamic> coachList = data['data'];
          _coaches =
              coachList.map((json) => CoachModel.fromJson(json)).toList();
          _error = null;
        } else {
          _error = 'No data available';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error fetching coaches: $e');
      _error = 'Connection error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCoach(CoachModel coach) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'POST',
        '/coaches',
        formData:
            coach.toJson().map((key, value) => MapEntry(key, value.toString())),
      );

      print('Create response status: ${response.statusCode}');
      print('Create response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchCoaches();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating coach: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCoach(int id, CoachModel coach) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'PUT',
        '/coaches/$id',
        formData:
            coach.toJson().map((key, value) => MapEntry(key, value.toString())),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        await fetchCoaches();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating coach: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCoach(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'DELETE',
        '/coaches/$id',
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        await fetchCoaches();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting coach: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
