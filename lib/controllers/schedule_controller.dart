import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/schedule_model.dart';
import 'auth_controller.dart';

class ScheduleController extends ChangeNotifier {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final AuthController authController;

  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MonthlySchedule> _monthlySchedules = [];
  List<MonthlySchedule> get monthlySchedules => _monthlySchedules;

  ScheduleController(this.authController);

  Future<void> fetchDailySchedules(String date) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/schedules/daily?date=$date',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> scheduleList = data['data']['schedules'];
          _schedules =
              scheduleList.map((json) => ScheduleModel.fromJson(json)).toList();
          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load schedules';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error fetching schedules: $e');
      _error = 'Connection error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSchedule(ScheduleModel schedule) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'POST',
        '/schedules',
        formData: {
          'name_schedule': schedule.nameSchedule,
          'date_schedule': schedule.dateSchedule,
          'status_schedule': schedule.statusSchedule.toString(),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchDailySchedules(schedule.dateSchedule);
        return true;
      }
      print('Server response: ${response.body}');
      return false;
    } catch (e) {
      print('Error creating schedule: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSchedule(int id, ScheduleModel schedule) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'PUT',
        '/schedules/$id',
        formData: {
          'name_schedule': schedule.nameSchedule,
          'date_schedule': schedule.dateSchedule,
          'status_schedule': schedule.statusSchedule.toString(),
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        await fetchDailySchedules(schedule.dateSchedule);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating schedule: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSchedule(int id, String date) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'DELETE',
        '/schedules/$id',
      );

      if (response.statusCode == 200) {
        await fetchDailySchedules(date);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlySchedules(DateTime date) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await authController.authorizedRequest(
        'GET',
        '/schedules/monthly?month=${date.month}&year=${date.year}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> scheduleList = data['data'];
          _monthlySchedules = scheduleList
              .map((json) => MonthlySchedule(
                    dateSchedule: json['date_schedule'],
                    totalSchedule: json['total_schedule'],
                  ))
              .toList();

          // Check if there's schedule for today
          final today = DateTime.now();
          final formattedToday =
              "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

          final hasScheduleToday = _monthlySchedules
              .any((schedule) => schedule.dateSchedule == formattedToday);

          if (hasScheduleToday) {
            // Fetch daily schedules for today
            await fetchDailySchedules(formattedToday);
          }

          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load schedules';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error fetching monthly schedules: $e');
      _error = 'Connection error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class MonthlySchedule {
  final String dateSchedule;
  final int totalSchedule;

  MonthlySchedule({
    required this.dateSchedule,
    required this.totalSchedule,
  });
}
