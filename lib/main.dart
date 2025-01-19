import 'package:flutter/material.dart';
import 'Layout/splash.dart';
import 'routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controllers/aspect_controller.dart';
import 'controllers/department_controller.dart';
import 'controllers/point_rate_controller.dart';
import 'controllers/info_controller.dart';
import 'controllers/coach_controller.dart';
import 'controllers/management_controller.dart';
import 'controllers/team_category_controller.dart';
import 'controllers/coach_team_category_controller.dart';
import 'controllers/aspect_sub_controller.dart';
import 'controllers/student_controller.dart';
import 'controllers/assessment_controller.dart';
import 'controllers/schedule_controller.dart';
import 'controllers/assessment_setting_controller.dart';


Future<void> main() async {
  // Pastikan Flutter binding diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProxyProvider<AuthController, StudentController>(
          create: (context) =>
              StudentController(context.read<AuthController>()),
          update: (context, auth, previous) => StudentController(auth)
            ..fetchTotalsByCategory()
            ..fetchStudents(),
        ),
        ChangeNotifierProxyProvider<AuthController, ManagementController>(
          create: (context) =>
              ManagementController(context.read<AuthController>()),
          update: (context, auth, previous) => ManagementController(auth)
            ..fetchTotalsByDepartment()
            ..fetchManagements(),
        ),
        ChangeNotifierProxyProvider<AuthController, AspectController>(
          create: (context) => AspectController(context.read<AuthController>()),
          update: (context, auth, previous) =>
              AspectController(auth)..fetchAspects(),
        ),
        ChangeNotifierProxyProvider<AuthController, AspectSubController>(
          create: (context) =>
              AspectSubController(context.read<AuthController>()),
          update: (context, auth, previous) =>
              AspectSubController(auth)..fetchAspectSubs(),
        ),
        ChangeNotifierProxyProvider<AuthController, DepartmentController>(
          create: (context) =>
              DepartmentController(context.read<AuthController>()),
          update: (context, auth, previous) =>
              DepartmentController(auth)..fetchDepartments(),
        ),
        ChangeNotifierProxyProvider<AuthController, PointRateController>(
          create: (context) =>
              PointRateController(context.read<AuthController>()),
          update: (context, auth, previous) =>
              PointRateController(auth)..fetchPointRates(),
        ),
        ChangeNotifierProxyProvider<AuthController, InfoController>(
          create: (context) => InfoController(context.read<AuthController>()),
          update: (context, auth, previous) =>
              InfoController(auth)..fetchInfos(),
        ),
        ChangeNotifierProxyProvider<AuthController, CoachController>(
          create: (context) => CoachController(context.read<AuthController>()),
          update: (context, auth, previous) =>
              CoachController(auth)..fetchCoaches(),
        ),
        ChangeNotifierProxyProvider<AuthController, TeamCategoryController>(
          create: (context) =>
              TeamCategoryController(context.read<AuthController>()),
          update: (context, auth, previous) =>
              TeamCategoryController(auth)..fetchTeamCategories(),
        ),
        ChangeNotifierProxyProvider<AuthController,
            CoachTeamCategoryController>(
          create: (context) =>
              CoachTeamCategoryController(context.read<AuthController>()),
          update: (context, auth, previous) => CoachTeamCategoryController(auth)
            ..fetchCoachTeamCategories()
            ..getTotalsByTeamCategory(),
        ),
        ChangeNotifierProxyProvider<AuthController, AssessmentController>(
          create: (context) =>
              AssessmentController(context.read<AuthController>()),
          update: (context, auth, previous) => AssessmentController(auth)
            ..fetchAssessmentsByStudentAndAspect(
                '', ''),
        ),
        ChangeNotifierProxyProvider<AuthController, ScheduleController>(
          create: (context) => ScheduleController(context.read<AuthController>()),
          update: (context, auth, previous) => ScheduleController(auth)
            ..fetchMonthlySchedules(DateTime.now()),
        ),
        ChangeNotifierProxyProvider<AuthController, AssessmentSettingController>(
          create: (context) => AssessmentSettingController(context.read<AuthController>()),
          update: (context, auth, previous) => AssessmentSettingController(auth)
            ..fetchAssessmentSettings(''),
        ), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soccer School Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF7F50)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: AppRoutes.getRoutes(),
    );
  }
}
