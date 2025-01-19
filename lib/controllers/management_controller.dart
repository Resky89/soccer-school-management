import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/management_model.dart';
import 'auth_controller.dart';

class ManagementController extends ChangeNotifier {
  final AuthController authController;
  List<ManagementModel> _managements = [];
  bool _isLoading = false;
  String? _error;
  Map<String, int> _totalsByDepartment = {};

  List<ManagementModel> get managements => _managements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get totalsByDepartment => _totalsByDepartment;

  ManagementController(this.authController);

  Future<void> fetchManagements() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/managements',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _managements = (data['data'] as List)
              .map((json) => ManagementModel.fromJson(json))
              .toList();
          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load managements';
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

  Future<bool> createManagement(ManagementModel management) async {
    try {
      _isLoading = true;
      notifyListeners();

      final Map<String, String> requestBody = {
        'name': management.name,
        'gender': management.gender,
        'date_birth': management.dateBirth,
        'email': management.email,
        'nohp': management.nohp,
        'id_departement': management.idDepartement.toString(),
        'status': management.status.toString(),
      };

      print('Request body: $requestBody'); // Untuk debugging

      final response = await authController.authorizedRequest(
        'POST',
        '/managements',
        formData: requestBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        await fetchManagements();
        return true;
      }
      return false;
    } catch (e) {
      print('Create management error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateManagement(int id, ManagementModel management) async {
    try {
      _isLoading = true;
      notifyListeners();

      final Map<String, String> requestBody = {
        'name': management.name,
        'gender': management.gender,
        'date_birth': management.dateBirth,
        'email': management.email,
        'nohp': management.nohp,
        'id_departement': management.idDepartement.toString(),
        'status': management.status.toString(),
      };

      print('Request body: $requestBody'); // Untuk debugging

      final response = await authController.authorizedRequest(
        'PUT',
        '/managements/$id',
        formData: requestBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        await fetchManagements();
        return true;
      }
      return false;
    } catch (e) {
      print('Update management error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteManagement(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'DELETE',
        '/managements/$id',
      );

      if (response.statusCode == 200) {
        await fetchManagements();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTotalsByDepartment() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/managements/total-by-department',
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];

          _totalsByDepartment = {}; // Clear existing data
          for (var item in data) {
            // Sesuaikan dengan nama field dari API response
            final departmentName =
                item['name_departement']?.toString() ?? 'Unknown';
            final totalEmployees = item['total_employees'] as int? ?? 0;

            _totalsByDepartment[departmentName] = totalEmployees;
          }
          print('Updated totals by department: $_totalsByDepartment');
        }
      }
    } catch (e) {
      print('Error fetching totals: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
