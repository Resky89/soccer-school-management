import 'package:flutter/material.dart';
import '../Layout/sidebar.dart';
import 'package:provider/provider.dart';
import '../controllers/student_controller.dart';
import '../models/student_model.dart';
import '../controllers/team_category_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../views/student_detail.dart';
import 'package:shimmer/shimmer.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, String> positionOptions = {
    'Goalkeeper': 'GK',
    'Center Back': 'CB',
    'Left Back': 'LB',
    'Right Back': 'RB',
    'Defensive Midfielder': 'DMF',
    'Central Midfielder': 'CMF',
    'Attacking Midfielder': 'AMF',
    'Right Wing': 'RW',
    'Left Wing': 'LW',
    'Striker': 'ST',
  };

  @override
  void initState() {
    super.initState();
    // Fetch students when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentController>().fetchStudents();
      // Fetch team categories
      context.read<TeamCategoryController>().fetchTeamCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const Sidebar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7F50),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddEditDialog(),
      ),
      body: Column(
        children: [
          // Custom AppBar (selalu ditampilkan)
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
                      icon:
                          const Icon(Icons.menu, color: Colors.white, size: 28),
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

          // Content area with Consumer
          Expanded(
            child: Consumer<StudentController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return _buildShimmerStudent();
                }

                if (controller.error != null) {
                  return Center(child: Text(controller.error!));
                }

                return Column(
                  children: [
                    // Students List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: controller.students.length,
                        itemBuilder: (context, index) {
                          final student = controller.students[index];
                          return _buildStudentItem(student);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentItem(StudentModel student) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Photo, Name and Status Row
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentDetailScreen(idStudent: student.idStudent!),
                  ),
                );
              },
              child: Row(
                children: [
                  // Square Photo with rounded corners
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                      image: student.photo != null && student.photo!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(student.photo!),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                setState(() {
                                  student = student.copyWith(photo: null);
                                });
                              },
                            )
                          : const DecorationImage(
                              image: AssetImage('images/avatar.png'),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name and Status
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: student.status == 1
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  student.status == 1 ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: student.status == 1
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Icons Row
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit Button
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 18,
                  ),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () => _showAddEditDialog(student: student),
                ),
                const SizedBox(width: 16),
                // Delete Button
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 18,
                  ),
                  label: const Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  onPressed: () => _showDeleteDialog(student),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Student'),
        content: const Text('Apakah Anda yakin ingin menghapus student ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              final success = await context
                  .read<StudentController>()
                  .deleteStudent(student.regIdStudent!);

              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Student berhasil dihapus'
                        : 'Gagal menghapus student',
                  ),
                  backgroundColor:
                      success ? const Color(0xFFFF7F50) : Colors.red,
                ),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({StudentModel? student}) async {
    final nameController = TextEditingController(text: student?.name);
    final idStudentController = TextEditingController(text: student?.idStudent);
    final birthDateController = TextEditingController(text: student?.dateBirth);
    final emailController = TextEditingController(text: student?.email);
    final phoneController = TextEditingController(text: student?.nohp);
    final positionController = TextEditingController(text: student?.position);
    final heightController =
        TextEditingController(text: student?.heightCm?.toString());
    final weightController =
        TextEditingController(text: student?.weightKg?.toString());
    final shirtNumberController =
        TextEditingController(text: student?.shirtNumber);
    String? imagePath;

    String selectedGender = student?.gender ?? 'L';
    String selectedFoot = student?.dominantFoot ?? 'Right';
    int? selectedTeamId = student?.idTeamCategory;
    bool isActive = student?.status == 1;

    DateTime selectedDate;
    try {
      selectedDate = student != null
          ? DateTime.parse(student.dateBirth.replaceAll(' ', ''))
          : DateTime.now();
      birthDateController.text =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    } catch (e) {
      selectedDate = DateTime.now();
      birthDateController.text =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    }

    // Fetch team categories terlebih dahulu
    await context.read<TeamCategoryController>().fetchTeamCategories();

    // Set selectedTeamId dari student yang akan diedit
    if (student != null) {
      selectedTeamId = student.idTeamCategory;
    }

    // Tambahkan variable untuk mengontrol loading state
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${student == null ? 'Tambah' : 'Edit'} Student',
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

                  // Photo Upload & Preview Section
                  const Text(
                    'Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (imagePath != null ||
                      (student?.photo != null && student!.photo!.isNotEmpty))
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imagePath != null
                              ? FileImage(File(imagePath!)) as ImageProvider
                              : NetworkImage(student!.photo!),
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          imagePath = image.path;
                        });
                      }
                    },
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              imagePath != null
                                  ? Icons.check_circle
                                  : Icons.add_photo_alternate_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              imagePath != null
                                  ? 'Photo selected'
                                  : 'Tap to upload photo',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ID Student field
                  if (student == null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ID Student',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: idStudentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter Student ID',
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
                              borderSide:
                                  const BorderSide(color: Color(0xFFFF7F50)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ID Student',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: idStudentController,
                          enabled: false,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Name field with white text
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter student name',
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
                  ),
                  const SizedBox(height: 16),

                  // Date Picker field
                  const Text(
                    'Tanggal Lahir',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                          birthDateController.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            birthDateController.text.isEmpty
                                ? 'Pilih tanggal lahir'
                                : birthDateController.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: birthDateController.text.isEmpty
                                  ? Colors.grey[400]
                                  : Colors.white,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Gender Radio Group
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'L',
                            groupValue: selectedGender,
                            activeColor: const Color(0xFFFF7F50),
                            onChanged: (value) {
                              setState(() => selectedGender = value!);
                            },
                          ),
                          const Text(
                            'Male',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 24),
                          Radio<String>(
                            value: 'P',
                            groupValue: selectedGender,
                            activeColor: const Color(0xFFFF7F50),
                            onChanged: (value) {
                              setState(() => selectedGender = value!);
                            },
                          ),
                          const Text(
                            'Female',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Email field with white text
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter email',
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
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                      phoneController, 'Phone', 'Enter phone number'),
                  const SizedBox(height: 16),

                  // Position field
                  const Text(
                    'Position',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: positionController.text.isEmpty
                        ? null
                        : positionController.text,
                    decoration: InputDecoration(
                      labelText: 'Position',
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
                        borderSide: const BorderSide(color: Color(0xFFFF7F50)),
                      ),
                    ),
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                    items: positionOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.value,
                        child: Text(
                          '${entry.value} - ${entry.key}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        positionController.text = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dominant Foot Radio Group
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dominant Foot',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Left',
                            groupValue: selectedFoot,
                            activeColor: const Color(0xFFFF7F50),
                            onChanged: (value) {
                              setState(() => selectedFoot = value!);
                            },
                          ),
                          const Text(
                            'Left',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 24),
                          Radio<String>(
                            value: 'Right',
                            groupValue: selectedFoot,
                            activeColor: const Color(0xFFFF7F50),
                            onChanged: (value) {
                              setState(() => selectedFoot = value!);
                            },
                          ),
                          const Text(
                            'Right',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 24),
                          Radio<String>(
                            value: 'Both',
                            groupValue: selectedFoot,
                            activeColor: const Color(0xFFFF7F50),
                            onChanged: (value) {
                              setState(() => selectedFoot = value!);
                            },
                          ),
                          const Text(
                            'Both',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Height and Weight in Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Height (cm)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: heightController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter height',
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
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFF7F50)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weight (kg)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: weightController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter weight',
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
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFF7F50)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Team Category Dropdown
                  const Text(
                    'Team Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<TeamCategoryController>(
                    builder: (context, categoryController, child) {
                      if (categoryController.teamCategories.isEmpty) {
                        categoryController.fetchTeamCategories();
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF7F50),
                          ),
                        );
                      }

                      // Filter active team categories
                      final activeTeamCategories = categoryController
                          .teamCategories
                          .where((category) => category.status == '1')
                          .toList();

                      return DropdownButtonFormField<int>(
                        value: selectedTeamId,
                        dropdownColor: Colors.black,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
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
                        hint: Text(
                          'Select Team Category',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        items: activeTeamCategories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category.idTeamCategory,
                            child: Text(
                              category.nameTeamCategory,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedTeamId = value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Shirt Number field
                  const Text(
                    'Shirt Number',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: shirtNumberController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter shirt number',
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
                  ),
                  const SizedBox(height: 16),

                  // Status Switch
                  Row(
                    children: [
                      const Text(
                        'Status:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Switch(
                        value: isActive,
                        activeColor: const Color(0xFFFF7F50),
                        onChanged: (value) => setState(() => isActive = value),
                      ),
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
                      // Disable button saat loading
                      onPressed: isLoading
                          ? null
                          : () async {
                              // Validasi semua field yang required
                              if (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  phoneController.text.isEmpty ||
                                  birthDateController.text.isEmpty ||
                                  selectedTeamId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Semua field harus diisi'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Validasi ID Student untuk mode tambah
                              if (student == null &&
                                  idStudentController.text.length != 8) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('ID Student harus 8 karakter'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Set loading state
                              setState(() {
                                isLoading = true;
                              });

                              try {
                                final controller =
                                    context.read<StudentController>();
                                final newStudent = StudentModel(
                                  regIdStudent: student?.regIdStudent,
                                  idStudent: student?.idStudent ??
                                      idStudentController.text,
                                  name: nameController.text,
                                  dateBirth: birthDateController.text,
                                  gender: selectedGender,
                                  photo: student?.photo,
                                  email: emailController.text,
                                  nohp: phoneController.text,
                                  position: positionController.text.isEmpty
                                      ? '-'
                                      : positionController.text,
                                  dominantFoot: selectedFoot,
                                  heightCm:
                                      int.tryParse(heightController.text) ?? 0,
                                  weightKg:
                                      int.tryParse(weightController.text) ?? 0,
                                  shirtNumber:
                                      shirtNumberController.text.isEmpty
                                          ? '-'
                                          : shirtNumberController.text,
                                  idTeamCategory: selectedTeamId,
                                  status: isActive ? 1 : 0,
                                );

                                bool success;
                                if (student == null) {
                                  success = await controller.createStudent(
                                    newStudent,
                                    imagePath: imagePath,
                                  );
                                } else {
                                  success = await controller.updateStudent(
                                    student.idStudent!,
                                    newStudent,
                                    imagePath: imagePath,
                                  );
                                }

                                if (!mounted) return;
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? student == null
                                              ? 'Student berhasil ditambahkan'
                                              : 'Student berhasil diupdate'
                                          : 'Gagal memproses student',
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
                                // Reset loading state if modal is still showing
                                if (mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
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
                              student == null
                                  ? 'Tambah Student'
                                  : 'Simpan Perubahan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
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
        TextField(
          controller: controller,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerStudent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5, // Jumlah item shimmer
      itemBuilder: (context, index) => Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                // Photo, Name and Status Row
                Row(
                  children: [
                    // Square Photo with rounded corners
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Name and Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 24,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Action Icons Row
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit Button
                    Container(
                      height: 20,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Delete Button
                    Container(
                      height: 20,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
