import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/team_category_model.dart';
import 'auth_controller.dart';

class TeamCategoryController extends ChangeNotifier {
  final AuthController authController;
  List<TeamCategoryModel> _teamCategories = [];
  bool _isLoading = false;
  String? _error;

  List<TeamCategoryModel> get teamCategories => _teamCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TeamCategoryController(this.authController);

  Future<void> fetchTeamCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/team-categories',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _teamCategories = (data['data'] as List)
              .map((json) => TeamCategoryModel.fromJson(json))
              .toList();
          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load team categories';
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

  Future<bool> createTeamCategory(TeamCategoryModel category) async {
    try {
      _isLoading = true;
      notifyListeners();

      final Map<String, String> requestBody = {
        'name_team_category': category.nameTeamCategory,
        'status': category.status,
      };

      final response = await authController.authorizedRequest(
        'POST',
        '/team-categories',
        formData: requestBody,
      );

      if (response.statusCode == 201) {
        await fetchTeamCategories();
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

  Future<bool> updateTeamCategory(int id, TeamCategoryModel category) async {
    try {
      _isLoading = true;
      notifyListeners();

      final Map<String, String> requestBody = {
        'name_team_category': category.nameTeamCategory,
        'status': category.status,
      };

      final response = await authController.authorizedRequest(
        'PUT',
        '/team-categories/$id',
        formData: requestBody,
      );

      if (response.statusCode == 200) {
        await fetchTeamCategories();
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

  Future<bool> deleteTeamCategory(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'DELETE',
        '/team-categories/$id',
      );

      if (response.statusCode == 200) {
        await fetchTeamCategories();
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
