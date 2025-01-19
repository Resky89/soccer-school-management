import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/student_controller.dart';
import '../controllers/team_category_controller.dart';
import '../models/student_model.dart';
import '../models/team_category_model.dart';
import 'package:shimmer/shimmer.dart';

class StudentDetailScreen extends StatefulWidget {
  final String idStudent;

  const StudentDetailScreen({Key? key, required this.idStudent})
      : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  StudentModel? student;

  @override
  void initState() {
    super.initState();
    _loadStudentDetail();
  }

  Future<void> _loadStudentDetail() async {
    try {
      final studentDetail = await context
          .read<StudentController>()
          .getStudentById(widget.idStudent);

      print('Received student detail: $studentDetail');

      if (mounted) {
        setState(() {
          student = studentDetail;
        });
      }
    } catch (e) {
      print('Error loading student detail: $e');
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String getTeamCategoryName(int? idTeamCategory) {
    if (idTeamCategory == null) return '-';
    final teamCategories =
        context.read<TeamCategoryController>().teamCategories;
    final teamCategory = teamCategories.firstWhere(
      (team) => team.idTeamCategory == idTeamCategory,
      orElse: () => TeamCategoryModel(
        idTeamCategory: 0,
        nameTeamCategory: '-',
        status: '0',
      ),
    );
    return teamCategory.nameTeamCategory;
  }

  Widget _buildShimmerDetail() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo Container with Shadow
          Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
                maxWidth: MediaQuery.of(context).size.width - 32,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          // Student Name and Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: 80,
                    height: 28,
                  ),
                ],
              ),
            ),
          ),

          // Student Information
          _buildShimmerSection('Student Information', 5),

          const SizedBox(height: 16),

          // Soccer Information
          _buildShimmerSection('Soccer Information', 6),
        ],
      ),
    );
  }

  Widget _buildShimmerSection(String title, int itemCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 180,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            ...List.generate(
              itemCount,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 20,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom AppBar
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'YOUTH TIGER SOCCER SCHOOL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset(
                        'images/logo.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Consumer<StudentController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF7F50)),
                  );
                }

                if (student == null) {
                  return _buildShimmerDetail();
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Container with Shadow
                      Center(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                            maxWidth: MediaQuery.of(context).size.width - 32,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: (student?.photo?.isNotEmpty ?? false)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    student!.photo!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(Icons.person,
                                            size: 50, color: Colors.grey),
                                      );
                                    },
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.person,
                                      size: 50, color: Colors.grey),
                                ),
                        ),
                      ),

                      // Student Name and Status
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                student?.name ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1B1E),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: student?.status == 1
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                student?.status == 1 ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: student?.status == 1
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Student Information
                      _buildDetailSection('Student Information', [
                        _buildDetailItem('ID', student?.idStudent ?? '',
                            icon: Icons.badge),
                        _buildDetailItem('Email', student?.email ?? '',
                            icon: Icons.email),
                        _buildDetailItem('Phone', student?.nohp ?? '',
                            icon: Icons.phone),
                        _buildDetailItem(
                            'Birth Date', formatDate(student?.dateBirth),
                            icon: Icons.calendar_today),
                        _buildDetailItem('Gender',
                            student?.gender == 'L' ? 'Male' : 'Female',
                            icon: Icons.person),
                      ]),

                      const SizedBox(height: 16),

                      // Soccer Information
                      _buildDetailSection('Soccer Information', [
                        _buildDetailItem('Position', student?.position ?? '-',
                            icon: Icons.sports_soccer),
                        _buildDetailItem(
                            'Dominant Foot', student?.dominantFoot ?? '-',
                            icon: Icons.directions_walk),
                        _buildDetailItem(
                            'Height', '${student?.heightCm ?? 0} cm',
                            icon: Icons.height),
                        _buildDetailItem(
                            'Weight', '${student?.weightKg ?? 0} kg',
                            icon: Icons.monitor_weight),
                        _buildDetailItem(
                            'Shirt Number', student?.shirtNumber ?? '-',
                            icon: Icons.format_list_numbered),
                        _buildDetailItem('Team Category',
                            getTeamCategoryName(student?.idTeamCategory),
                            icon: Icons.group),
                      ]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1B1E),
            ),
          ),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                icon,
                size: 20,
                color: Colors.grey[600],
              ),
            ),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1B1E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
