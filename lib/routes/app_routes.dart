import 'package:flutter/material.dart';
import '../views/home.dart';
import '../views/login.dart';
import '../views/info.dart';
import '../views/info_detail.dart';
import '../views/schedule.dart';
import '../views/students.dart';
import '../views/coach.dart';
import '../views/profile.dart';
import '../views/management.dart';
import '../views/departement.dart';
import '../views/aspek.dart';
import '../views/assessment.dart';
import '../views/assessment_setting.dart';
import '../views/point_rate.dart';
import '../views/aspek_sub.dart';
import '../views/team_category.dart';
import '../views/coach_team_category.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String info = '/info';
  static const String infoDetail = '/info-detail';
  static const String schedule = '/schedule';
  static const String students = '/students';
  static const String coach = '/coach';
  static const String profile = '/profile';
  static const String management = '/management';
  static const String departement = '/departement';
  static const String aspek = '/aspek';
  static const String aspekSub = '/aspek-sub';
  static const String asessment = '/asessment';
  static const String asessmentSetting = '/asessment-setting';
  static const String pointRate = '/point-rate';
  static const String teamCategory = '/team-category';
  static const String coachTeamCategory = '/coach-team-category';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
      info: (context) => const InfoScreen(),
      infoDetail: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as int;
        return InfoDetail(
          idInformation: args,
        );
      },
      schedule: (context) => const ScheduleScreen(),
      students: (context) => const StudentsScreen(),
      coach: (context) => const CoachScreen(),
      management: (context) => const ManagementScreen(),
      departement: (context) => const DepartementScreen(),
      aspekSub: (context) => const AspekSubScreen(),
      asessment: (context) => const AssessmentScreen(),
      asessmentSetting: (context) => const AssessmentSettingScreen(),
      profile: (context) => const ProfileScreen(),
      pointRate: (context) => const PointRateScreen(),
      aspek: (context) => const AspekScreen(),
      teamCategory: (context) => const TeamCategoryScreen(),
      coachTeamCategory: (context) => const CoachTeamCategoryScreen(),
    };
  }
}
