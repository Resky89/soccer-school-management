import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/coach_team_category_model.dart';
import 'auth_controller.dart';

class CoachTeamCategoryController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController authController;
  List<CoachTeamCategoryModel> _coachTeamCategories = [];
  bool _isLoading = false;
  String? _error;

  List<CoachTeamCategoryModel> get coachTeamCategories => _coachTeamCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CoachTeamCategoryController(this.authController);

  Future<void> fetchCoachTeamCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/coach-team-categories',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _coachTeamCategories = (data['data'] as List)
            .map((json) => CoachTeamCategoryModel.fromJson(json))
            .toList();
      } else {
        _error = 'Failed to load coach team categories';
      }
    } catch (e) {
      _error = 'Connection error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCoachTeamCategory(CoachTeamCategoryModel category) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/coach-team-categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchCoachTeamCategories();
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

  Future<bool> updateCoachTeamCategory(
      int id, CoachTeamCategoryModel category) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.put(
        Uri.parse('$baseUrl/coach-team-categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchCoachTeamCategories();
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

  Future<bool> deleteCoachTeamCategory(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await authController.getAccessToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/coach-team-categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchCoachTeamCategories();
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

  Future<CoachTeamCategoryModel?> getCoachTeamCategoryById(int id) async {
    try {
      final response = await authController.authorizedRequest(
        'GET',
        '/coach-team-categories/$id',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CoachTeamCategoryModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Map<String, int> getTotalsByTeamCategory() {
    Map<String, int> totals = {};

    for (var coach in _coachTeamCategories) {
      if (coach.isActive == 1) {
        // Only count active coaches
        totals[coach.nameTeamCategory] =
            (totals[coach.nameTeamCategory] ?? 0) + 1;
      }
    }

    return totals;
  }
}
