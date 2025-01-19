import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/aspect_sub_model.dart';
import 'auth_controller.dart';

class AspectSubController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController authController;

  List<AspectSubModel> _aspectSubs = [];
  bool _isLoading = false;
  String? _error;

  List<AspectSubModel> get aspectSubs => _aspectSubs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AspectSubController(this.authController);

  Future<void> fetchAspectSubs() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/aspect-subs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _aspectSubs = (data['data'] as List)
              .map((json) => AspectSubModel.fromJson(json))
              .toList();
        } else {
          _error = data['message'];
        }
      } else {
        _error = 'Failed to load aspect subs';
      }
    } catch (e) {
      _error = 'Connection error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<AspectSubModel>> fetchAspectSubsByAspect(int aspectId) async {
    try {
      final token = await authController.getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/aspect-subs/$aspectId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['data'] as List)
              .map((json) => AspectSubModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createAspectSub(AspectSubModel aspectSub) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/aspect-subs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(aspectSub.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchAspectSubs();
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

  Future<bool> updateAspectSub(int id, AspectSubModel aspectSub) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/aspect-subs/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(aspectSub.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchAspectSubs();
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

  Future<bool> deleteAspectSub(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/aspect-subs/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchAspectSubs();
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
}
