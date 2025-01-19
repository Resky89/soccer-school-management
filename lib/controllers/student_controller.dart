import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/student_model.dart';
import 'auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class StudentController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController authController;
  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _error;
  Map<String, int> _totalsByCategory = {};

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get totalsByCategory => _totalsByCategory;

  StudentController(this.authController);

  Future<void> fetchStudents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/students',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _students = (data['data'] as List)
              .map((json) => StudentModel.fromJson(json))
              .toList();
          await fetchTeamCategoriesForStudents();
          notifyListeners();
        } else {
          _error = data['message'] ?? 'Failed to load students';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Connection error occurred';
      print('Error fetching students: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeamCategoriesForStudents() async {
    try {
      final teamCatResponse = await authController.authorizedRequest(
        'GET',
        '/team-categories',
      );

      if (teamCatResponse.statusCode == 200) {
        final teamCatData = jsonDecode(teamCatResponse.body);
        final teamCategoriesList = teamCatData['data'] as List;
        final teamCategories = {
          for (var cat in teamCategoriesList)
            cat['id_team_category'] as int: cat['name_team_category'] as String
        };

        // Update team category names for existing students
        for (var student in _students) {
          if (student.idTeamCategory != null) {
            student.teamCategoryName = teamCategories[student.idTeamCategory];
          }
        }
      }
    } catch (e) {
      print('Error fetching team categories: $e');
    }
  }

  Future<bool> createStudent(StudentModel student, {String? imagePath}) async {
    try {
      _isLoading = true;
      notifyListeners();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/students'),
      );

      // Add all form fields
      final formData = student.toFormData();
      request.fields.addAll(formData);

      // Debug print
      print('Sending form data: ${request.fields}');

      // Add photo if provided
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          imagePath,
          contentType:
              MediaType('image', imagePath.split('.').last.toLowerCase()),
        ));
      }

      final token = await authController.getAccessToken();
      if (token == null) throw Exception('No token available');

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      print('Create Response Status: ${responseData.statusCode}');
      print('Create Response Body: ${responseData.body}');

      if (responseData.statusCode == 201) {
        await fetchStudents();
        return true;
      }
      return false;
    } catch (e) {
      print('Create student error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStudent(String id, StudentModel student,
      {String? imagePath}) async {
    try {
      _isLoading = true;
      notifyListeners();

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/students/$id'),
      );

      // Add all form fields
      final formData = student.toFormData();
      request.fields.addAll(formData);

      // Debug print
      print('Sending form data for update: ${request.fields}');

      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          imagePath,
          contentType:
              MediaType('image', imagePath.split('.').last.toLowerCase()),
        ));
      }

      final token = await authController.getAccessToken();
      if (token == null) throw Exception('No token available');

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      print(
          'Update Response: ${responseData.statusCode} - ${responseData.body}');

      if (responseData.statusCode == 200) {
        await fetchStudents();
        return true;
      }
      return false;
    } catch (e) {
      print('Update student error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteStudent(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'DELETE',
        '/students/$id',
      );

      if (response.statusCode == 200) {
        await fetchStudents();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete student error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTotalsByCategory() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/students/total-by-category',
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];

          _totalsByCategory = {}; // Clear existing data
          for (var item in data) {
            // Sesuaikan dengan nama field dari API response
            final categoryName =
                item['name_team_category']?.toString() ?? 'Unknown';
            final totalPlayers = item['total_active_players'] as int? ?? 0;

            _totalsByCategory[categoryName] = totalPlayers;
          }
          print('Updated totals by category: $_totalsByCategory');
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

  Future<StudentModel?> getStudentById(String idStudent) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/students/$idStudent',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return StudentModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Get student detail error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
