import 'package:flutter/material.dart';
import '../Layout/sidebar.dart';
import 'package:provider/provider.dart';
import '../controllers/aspect_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/assessment_controller.dart';
import '../controllers/aspect_sub_controller.dart';
import '../models/assessment_model.dart';
import '../controllers/coach_controller.dart';
import 'package:shimmer/shimmer.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({Key? key}) : super(key: key);

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedAspect = 'Aspek Teknis';
  String? selectedStudent;
  String? selectedStudentName;
  late String selectedYearAcademic;
  late String selectedYearAssessment;

  // Define year options at class level
  final List<String> yearAcademicOptions = [
    '2024/2025',
    '2025/2026',
    '2026/2027',
  ];

  final List<String> yearAssessmentOptions = [
    '2024',
    '2025',
    '2026',
  ];

  @override
  void initState() {
    super.initState();
    selectedYearAcademic = yearAcademicOptions.first;
    selectedYearAssessment = yearAssessmentOptions.first;
    context.read<StudentController>().fetchStudents();
    context.read<CoachController>().fetchCoaches();
    context.read<AspectSubController>().fetchAspectSubs();
  }

  void _onAspectSelected(String aspectName) {
    setState(() {
      selectedAspect = aspectName;
    });
    if (selectedStudentName != null) {
      context.read<AssessmentController>().fetchAssessmentsByStudentAndAspect(
            selectedStudentName!,
            selectedAspect,
          );
    }
  }

  void _onStudentSelected(String? studentId, String studentName) {
    setState(() {
      selectedStudent = studentId;
      selectedStudentName = studentName;
    });
    // Clear existing assessments first
    context.read<AssessmentController>().clearAssessments();
    // Then fetch new assessments
    context.read<AssessmentController>().fetchAssessmentsByStudentAndAspect(
          studentName,
          selectedAspect,
        );
  }

  void _showAddEditDialog({AssessmentModel? assessment}) async {
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();
    final notesController =
        TextEditingController(text: assessment?.notes ?? '');
    final pointController =
        TextEditingController(text: assessment?.point.toString() ?? '');

    // Initialize dropdown values with non-null defaults
    String selectedYearAcademic =
        assessment?.yearAcademic ?? yearAcademicOptions.first;
    String selectedYearAssessment =
        assessment?.yearAssessment ?? yearAssessmentOptions.first;

    // For student, coach, and aspect sub dropdowns
    String? selectedRegIdStudent =
        assessment?.regIdStudent?.toString() ?? selectedStudent;
    String? selectedAspectSubId = assessment?.idAspectSub;
    String? selectedIdCoach = assessment?.idCoach;

    // Pre-fetch data
    await Future.wait([
      context.read<StudentController>().fetchStudents(),
      context.read<CoachController>().fetchCoaches(),
      context.read<AspectSubController>().fetchAspectSubs(),
    ]);

    // Show modal with StatefulBuilder
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Get data for dropdowns
          final students = context.read<StudentController>().students;
          final coaches = context.read<CoachController>().coaches;
          final aspectSubs = context
              .read<AspectSubController>()
              .aspectSubs
              .where((sub) => sub.nameAspect == selectedAspect)
              .toList();

          // Ensure selected values exist in lists
          if (selectedRegIdStudent != null &&
              !students.any(
                  (s) => s.regIdStudent.toString() == selectedRegIdStudent)) {
            selectedRegIdStudent = students.isNotEmpty
                ? students.first.regIdStudent.toString()
                : null;
          }

          if (selectedIdCoach != null &&
              !coaches.any((c) => c.idCoach == selectedIdCoach)) {
            selectedIdCoach =
                coaches.isNotEmpty ? coaches.first.idCoach?.toString() : null;
          }

          if (selectedAspectSubId != null &&
              !aspectSubs.any(
                  (a) => a.idAspectSub.toString() == selectedAspectSubId)) {
            selectedAspectSubId = aspectSubs.isNotEmpty
                ? aspectSubs.first.idAspectSub.toString()
                : null;
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${assessment == null ? 'Add' : 'Edit'} Assessment',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Student Dropdown - Disabled when adding new assessment
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Student',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedRegIdStudent,
                            decoration: InputDecoration(
                              hintText: 'Select Student',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFFF7F50)),
                              ),
                            ),
                            dropdownColor: Colors.black,
                            style: const TextStyle(color: Colors.white),
                            items: students.map((student) {
                              return DropdownMenuItem<String>(
                                value: student.regIdStudent.toString(),
                                child: Text(
                                  student.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a student';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedRegIdStudent = value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Aspect Sub Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sub Aspect',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedAspectSubId,
                            decoration: InputDecoration(
                              hintText: 'Select Sub Aspect',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFFF7F50)),
                              ),
                            ),
                            dropdownColor: Colors.black,
                            style: const TextStyle(color: Colors.white),
                            items: aspectSubs.isNotEmpty
                                ? aspectSubs.map((aspectSub) {
                                    return DropdownMenuItem<String>(
                                      value: aspectSub.idAspectSub.toString(),
                                      child: Text(
                                        aspectSub.nameAspectSub,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    );
                                  }).toList()
                                : [],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a sub aspect';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedAspectSubId = value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Coach Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Coach',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedIdCoach,
                            decoration: InputDecoration(
                              hintText: 'Select Coach',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFFF7F50)),
                              ),
                            ),
                            dropdownColor: Colors.black,
                            style: const TextStyle(color: Colors.white),
                            items: coaches.map((coach) {
                              return DropdownMenuItem<String>(
                                value: coach.idCoach.toString(),
                                child: Text(
                                  coach.nameCoach,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedIdCoach = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Year Academic Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedYearAcademic,
                        decoration: InputDecoration(
                          labelText: 'Academic Year',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFFF7F50)),
                          ),
                        ),
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        items: yearAcademicOptions.map((year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(
                              year,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedYearAcademic = value);
                          }
                        },
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Year Assessment Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedYearAssessment,
                        decoration: InputDecoration(
                          labelText: 'Assessment Year',
                          labelStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFFF7F50)),
                          ),
                        ),
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        items: yearAssessmentOptions.map((year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(
                              year,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedYearAssessment = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Point TextField
                      _buildTextField(
                        pointController,
                        'Point',
                        'Enter point',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Notes TextField
                      _buildTextField(
                        notesController,
                        'Keterangan',
                        'Enter notes',
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F50),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;

                                  setState(() => isLoading = true);

                                  try {
                                    final newAssessment = AssessmentModel(
                                      idAssessment:
                                          assessment?.idAssessment ?? '',
                                      nameAspectSub: '',
                                      notes: notesController.text,
                                      point: int.parse(pointController.text),
                                      dateAssessment: DateTime.now().toString(),
                                      yearAcademic: selectedYearAcademic,
                                      yearAssessment: selectedYearAssessment,
                                      regIdStudent: selectedRegIdStudent != null
                                          ? int.parse(selectedRegIdStudent!)
                                          : null,
                                      idCoach: selectedIdCoach,
                                      idAspectSub:
                                          selectedAspectSubId.toString(),
                                    );

                                    bool success;
                                    if (assessment == null) {
                                      success = await context
                                          .read<AssessmentController>()
                                          .createAssessment(newAssessment);
                                    } else {
                                      success = await context
                                          .read<AssessmentController>()
                                          .updateAssessment(
                                              assessment.idAssessment,
                                              newAssessment);
                                    }

                                    if (!mounted) return;
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? assessment == null
                                                  ? 'Assessment added successfully'
                                                  : 'Assessment updated successfully'
                                              : 'Failed to process assessment',
                                        ),
                                        backgroundColor: success
                                            ? const Color(0xFFFF7F50)
                                            : Colors.red,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => isLoading = false);
                                    }
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  assessment == null
                                      ? 'Add Assessment'
                                      : 'Save Changes',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method for building text fields
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7F50)),
            ),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  // Helper method for building dropdown fields
  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF7F50)),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showDeleteDialog(AssessmentModel assessment) {
    // Debug log untuk memastikan ID ada
    print('Assessment to delete - ID: ${assessment.idAssessment}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assessment'),
        content: const Text('Are you sure you want to delete this assessment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                if (assessment.idAssessment.isEmpty) {
                  throw Exception('Assessment ID is empty');
                }

                print(
                    'Attempting to delete assessment with ID: ${assessment.idAssessment}'); // Debug log

                final success = await context
                    .read<AssessmentController>()
                    .deleteAssessment(assessment.idAssessment);

                if (!mounted) return;

                if (success) {
                  // Refresh data setelah delete berhasil
                  await context
                      .read<AssessmentController>()
                      .fetchAssessmentsByStudentAndAspect(
                        selectedStudentName!,
                        selectedAspect,
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assessment berhasil dihapus'),
                      backgroundColor: Color(0xFFFF7F50),
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  throw Exception('Failed to delete assessment');
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const Sidebar(),
      body: Consumer<StudentController>(
        builder: (context, studentController, child) {
          if (studentController.isLoading) {
            return _buildShimmerAssessment();
          }

          return Column(
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
                          icon: const Icon(Icons.menu,
                              color: Colors.white, size: 28),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
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

              // Aspect Filter
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Consumer<AspectController>(
                  builder: (context, controller, child) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.aspects.length,
                      itemBuilder: (context, index) {
                        final aspect = controller.aspects[index];
                        final isSelected = aspect.nameAspect == selectedAspect;
                        return GestureDetector(
                          onTap: () => _onAspectSelected(aspect.nameAspect),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF7F50)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFF7F50),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                aspect.nameAspect,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFFF7F50),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Student Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Consumer<StudentController>(
                    builder: (context, studentController, child) {
                      if (studentController.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedStudent,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'Select Student',
                              style: TextStyle(
                                color: Color(0xFFFF7F50),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          items: studentController.students
                              .map((student) => DropdownMenuItem<String>(
                                    value: student.idStudent,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Text(
                                        student.name,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              final student = studentController.students
                                  .firstWhere((s) => s.idStudent == newValue);
                              _onStudentSelected(newValue, student.name);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Assessment List
              Expanded(
                child: Consumer<AssessmentController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.assessments.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada data penilaian',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.assessments.length,
                      itemBuilder: (context, index) {
                        final assessment = controller.assessments[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tahun ${assessment.yearAcademic}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Penilaian ${assessment.yearAssessment}',
                                    style: const TextStyle(
                                      color: Color(0xFFFF7F50),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.grey),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          assessment.nameAspectSub,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Point: ${assessment.point}',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'Catatan: ${assessment.notes}',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        onPressed: () => _showAddEditDialog(
                                          assessment: assessment,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _showDeleteDialog(assessment),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: selectedStudentName != null
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFFF7F50),
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showAddEditDialog(),
            )
          : null,
    );
  }

  Widget _buildShimmerAssessment() {
    return Column(
      children: [
        // Custom AppBar tetap ditampilkan
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
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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

        // Filter Section Shimmer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Student Dropdown Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Aspect Filter Buttons Shimmer
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < 2 ? 8.0 : 0,
                      ),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Assessment List Shimmer
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 120,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    // Content
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 100,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 200,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action Buttons
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
