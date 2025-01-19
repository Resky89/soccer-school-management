import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Layout/sidebar.dart';
import '../controllers/assessment_setting_controller.dart';
import '../models/assessment_setting_model.dart';
import '../controllers/aspect_controller.dart';
import '../models/aspect_sub_model.dart';
import '../controllers/aspect_sub_controller.dart';
import '../controllers/coach_controller.dart';
import '../models/coach_model.dart';
import 'package:shimmer/shimmer.dart';

class AssessmentSettingScreen extends StatefulWidget {
  const AssessmentSettingScreen({Key? key}) : super(key: key);

  @override
  State<AssessmentSettingScreen> createState() =>
      _AssessmentSettingScreenState();
}

class _AssessmentSettingScreenState extends State<AssessmentSettingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedAspect = 'Aspek Teknisknis';
  final TextEditingController _yearAcademicController = TextEditingController();
  final TextEditingController _yearAssessmentController =
      TextEditingController();
  final TextEditingController _bobotController = TextEditingController();
  String? selectedSubAspect;
  List<AspectSubModel> subAspects = [];
  String? selectedCoachId;
  List<CoachModel> coaches = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachController>().fetchCoaches();
      context.read<AspectController>().fetchAspects();
      context.read<AspectSubController>().fetchAspectSubs();
      context
          .read<AssessmentSettingController>()
          .fetchAssessmentSettings(selectedAspect);
    });
  }

  void _loadSubAspects(String aspectName) async {
    final aspects = context.read<AspectController>().aspects;
    final selectedAspectId =
        aspects.firstWhere((aspect) => aspect.nameAspect == aspectName).id;

    if (selectedAspectId != null) {
      print('Loading sub aspects for aspect ID: $selectedAspectId');
      final subAspectList = await context
          .read<AspectSubController>()
          .fetchAspectSubsByAspect(selectedAspectId);

      print('Loaded sub aspects: ${subAspectList.length}');
      setState(() {
        subAspects = subAspectList;
        selectedSubAspect = null;
      });
    }
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
        onPressed: () => _showBottomSheet(null,
            context.read<AssessmentSettingController>().assessmentSettings[0]),
      ),
      body: Consumer<AssessmentSettingController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return _buildShimmerAssessmentSetting();
          }
          return Column(
            children: [
              // Custom AppBar (similar to other screens)
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
              // Filter Aspect
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Consumer<AspectController>(
                  builder: (context, aspectController, child) {
                    if (aspectController.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: aspectController.aspects.length,
                      itemBuilder: (context, index) {
                        final aspect = aspectController.aspects[index];
                        final isSelected = aspect.nameAspect == selectedAspect;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAspect = aspect.nameAspect;
                            });
                            _loadSubAspects(aspect.nameAspect);
                            context
                                .read<AssessmentSettingController>()
                                .fetchAssessmentSettings(aspect.nameAspect);
                          },
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
              // Assessment List
              Expanded(
                child: Consumer<AssessmentSettingController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.assessmentSettings.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada data penilaian',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.assessmentSettings.length,
                      itemBuilder: (context, index) {
                        final setting = controller.assessmentSettings[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
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
                                        'Tahun ${setting.yearAcademic}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Penilaian ${setting.yearAssessment}',
                                        style: const TextStyle(
                                          color: Color(0xFFFF7F50),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Colors.grey),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: setting.assessments.length,
                                    itemBuilder: (context, idx) {
                                      final assessment =
                                          setting.assessments[idx];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    assessment.subAspect,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Pelatih: ${assessment.coach}',
                                                    style: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF7F50),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Bobot: ${assessment.bobot}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.white),
                                              onPressed: () => _showBottomSheet(
                                                  assessment, setting),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _showDeleteDialog(
                                                      assessment.id!),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildAssessmentItem({
    required String title,
    required String year,
    required String score,
    required String academicYear,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF7F50),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFF7F50)),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Bobot Nilai: $score',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Text(
              'Tahun Akademik: $academicYear',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(
      AssessmentDetail? assessment, AssessmentSettingResponse settingResponse) {
    final isEditing = assessment != null;

    // Pre-fill form untuk edit
    if (isEditing) {
      _yearAcademicController.text = settingResponse.yearAcademic;
      _yearAssessmentController.text = settingResponse.yearAssessment;
      _bobotController.text = assessment.bobot.toString();
      // selectedCoachId akan di-set di dalam builder dropdown
    } else {
      _yearAcademicController.clear();
      _yearAssessmentController.clear();
      _bobotController.clear();
      selectedCoachId = null;
      selectedSubAspect = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Penilaian' : 'Tambah Penilaian',
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
            ),
            const Divider(color: Colors.grey),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Aspek Field
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aspek',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAspect,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sub Aspek
                    if (!isEditing)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sub Aspek',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Consumer<AspectSubController>(
                              builder: (context, aspectSubController, child) {
                                final filteredSubAspects = aspectSubController
                                    .aspectSubs
                                    .where((sub) =>
                                        sub.nameAspect == selectedAspect)
                                    .toList();

                                return DropdownButtonFormField<String>(
                                  value: selectedSubAspect,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    border: InputBorder.none,
                                  ),
                                  dropdownColor: Colors.grey[900],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                  hint: const Text('Pilih Sub Aspek',
                                      style: TextStyle(color: Colors.grey)),
                                  items: filteredSubAspects
                                      .map((sub) => DropdownMenuItem(
                                            value: sub.idAspectSub.toString(),
                                            child: Text(sub.nameAspectSub),
                                          ))
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => selectedSubAspect = value),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sub Aspek',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              assessment.subAspect,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Tahun Fields
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _yearAcademicController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Tahun Akademik',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.grey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _yearAssessmentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Tahun Penilaian',
                              labelStyle:
                                  const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.grey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bobot & Coach
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bobot',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _bobotController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Pelatih',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Consumer<CoachController>(
                          builder: (context, coachController, child) {
                            // Pre-select coach berdasarkan nama jika dalam mode edit
                            if (isEditing && selectedCoachId == null) {
                              final coach = coachController.coaches.firstWhere(
                                (c) => c.nameCoach == assessment.coach,
                                orElse: () => coachController.coaches.first,
                              );
                              selectedCoachId = coach.idCoach.toString();
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedCoachId,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  border: InputBorder.none,
                                ),
                                dropdownColor: Colors.grey[900],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                                hint: const Text('Pilih Pelatih',
                                    style: TextStyle(color: Colors.grey)),
                                items: coachController.coaches.map((coach) {
                                  return DropdownMenuItem(
                                    value: coach.idCoach.toString(),
                                    child: Text(coach.nameCoach),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => selectedCoachId = value);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Submit Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7F50),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_validateForm(assessment != null)) {
                    try {
                      bool success;
                      final controller =
                          context.read<AssessmentSettingController>();

                      // Buat model untuk update
                      final setting = AssessmentSettingModel(
                        yearAcademic: _yearAcademicController.text,
                        yearAssessment: _yearAssessmentController.text,
                        nameCoach: selectedCoachId!,
                        nameAspect: selectedAspect,
                        // Cari ID sub aspek berdasarkan nama
                        nameAspectSub: assessment != null
                            ? context
                                .read<AspectSubController>()
                                .aspectSubs
                                .firstWhere((sub) =>
                                    sub.nameAspectSub == assessment.subAspect)
                                .idAspectSub
                                .toString()
                            : selectedSubAspect!,
                        bobot: int.parse(_bobotController.text),
                      );

                      // Debug prints
                      print('Is Editing: ${assessment != null}');
                      print('Assessment ID: ${assessment?.id}');
                      print('Sub Aspect Name: ${assessment?.subAspect}');
                      print('Request Body: ${setting.toJson()}');

                      if (assessment != null) {
                        success = await controller.updateAssessmentSetting(
                          assessment.id!,
                          setting,
                        );
                        print('Update Response: $success');
                      } else {
                        success =
                            await controller.createAssessmentSetting(setting);
                      }

                      if (!mounted) return;
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Data berhasil ${assessment != null ? 'diupdate' : 'disimpan'}'
                              : 'Gagal'),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );

                      if (success) {
                        controller.fetchAssessmentSettings(selectedAspect);
                      }
                    } catch (e) {
                      print('Error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  isEditing ? 'Update' : 'Simpan',
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
    );
  }

  // Fungsi validasi form
  bool _validateForm(bool isEditing) {
    if (isEditing) {
      // Validasi khusus untuk mode edit
      if (_yearAcademicController.text.isEmpty ||
          _yearAssessmentController.text.isEmpty ||
          _bobotController.text.isEmpty ||
          selectedCoachId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua field harus diisi'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else {
      // Validasi untuk mode tambah
      if (_yearAcademicController.text.isEmpty ||
          _yearAssessmentController.text.isEmpty ||
          _bobotController.text.isEmpty ||
          selectedCoachId == null ||
          selectedSubAspect == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua field harus diisi'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }
    return true;
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Penilaian'),
        content: const Text('Apakah Anda yakin ingin menghapus penilaian ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final controller = context.read<AssessmentSettingController>();
              final success = await controller.deleteAssessmentSetting(id);

              if (!mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Data berhasil dihapus'
                      : 'Gagal menghapus data'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );

              if (success) {
                controller.fetchAssessmentSettings(selectedAspect);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerAssessmentSetting() {
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

        // Filter Buttons Shimmer
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: const Color(0xFFFF7F50)),
                  ),
                  width: 120,
                ),
              );
            },
          ),
        ),

        // Assessment List Shimmer
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 2,
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan tahun
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 150,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7F50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    // List items dalam card
                    ...List.generate(
                        3,
                        (itemIndex) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 180,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 120,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[600],
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF7F50),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        width: 100,
                                        height: 32,
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
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
