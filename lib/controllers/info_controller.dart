import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/info_model.dart';
import 'auth_controller.dart';
import 'package:http_parser/http_parser.dart';

class InfoController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController authController;

  List<InfoModel> _infos = [];
  bool _isLoading = false;
  String? _error;

  List<InfoModel> get infos => _infos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  InfoController(this.authController);

  Future<void> fetchInfos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await authController.getAccessToken();
      print('Token: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/informations'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> infoList = data['data']['informations'] as List;
          _infos = infoList.map((json) => InfoModel.fromJson(json)).toList();
          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load information';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in fetchInfos: $e');
      _error = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createInfo(InfoModel info, {String? imagePath}) async {
    try {
      _isLoading = true;
      notifyListeners();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/informations'),
      );

      // Add all form fields
      final formData = info.toFormData();
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
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Create Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchInfos();
        return true;
      }

      final responseData = jsonDecode(response.body);
      _error = responseData['message'] ?? 'Failed to create information';
      return false;
    } catch (e) {
      print('Create error: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateInfo(int id, InfoModel info, {String? imagePath}) async {
    try {
      _isLoading = true;
      notifyListeners();

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/informations/$id'),
      );

      // Add all form fields
      final formData = info.toFormData();
      request.fields.addAll(formData);

      // Debug print to check data being sent
      print('Updating info with ID: $id');
      print('Form data being sent: ${request.fields}');

      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          imagePath,
          contentType:
              MediaType('image', imagePath.split('.').last.toLowerCase()),
        ));
        print('Adding image file: $imagePath');
      }

      final token = await authController.getAccessToken();
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        await fetchInfos();
        return true;
      }

      final responseData = jsonDecode(response.body);
      _error = responseData['message'] ?? 'Failed to update information';
      return false;
    } catch (e) {
      print('Update error: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteInfo(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/informations/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        await fetchInfos();
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

  Future<InfoModel?> getInfoById(int id) async {
    try {
      final token = await authController.getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/informations/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return InfoModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting info detail: $e');
      return null;
    }
  }
}
