import 'package:flutter/material.dart';
import '../Layout/sidebar.dart';
import '../models/coach_team_category_model.dart';
import '../controllers/coach_team_category_controller.dart';
import 'package:provider/provider.dart';
import '../controllers/coach_controller.dart';
import '../controllers/team_category_controller.dart';
import 'package:shimmer/shimmer.dart';

class CoachTeamCategoryScreen extends StatefulWidget {
  const CoachTeamCategoryScreen({Key? key}) : super(key: key);

  @override
  State<CoachTeamCategoryScreen> createState() =>
      _CoachTeamCategoryScreenState();
}

class _CoachTeamCategoryScreenState extends State<CoachTeamCategoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch all required data
      context.read<CoachTeamCategoryController>().fetchCoachTeamCategories();
      context.read<CoachController>().fetchCoaches();
      context.read<TeamCategoryController>().fetchTeamCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      drawer: const Sidebar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7F50),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddEditDialog(),
      ),
      body: Consumer<CoachTeamCategoryController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return _buildShimmerCoachTeamCategory();
          }

          if (controller.error != null) {
            return Center(child: Text(controller.error!));
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
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
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

              // Title Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coach Team Category',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Kelola kategori tim pelatih',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: controller.coachTeamCategories.length,
                  itemBuilder: (context, index) {
                    final category = controller.coachTeamCategories[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.nameCoach,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF7F50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Team: ${category.nameTeamCategory}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: category.isActive == 1
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: category.isActive == 1
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category.isActive == 1
                                        ? 'Active'
                                        : 'Inactive',
                                    style: TextStyle(
                                      color: category.isActive == 1
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.blue),
                              onPressed: () =>
                                  _showAddEditDialog(category: category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _showDeleteDialog(category),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildShimmerCoachTeamCategory() {
    return Column(
      children: [
        // Custom AppBar tetap sama
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
                    onPressed: () =>
                        _scaffoldKey.currentState?.openDrawer(),
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

        // Title Section Shimmer
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),

        // List Shimmer
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 120,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddEditDialog({CoachTeamCategoryModel? category}) async {
    // Initialize controllers and values
    int? selectedCoachId = category?.idCoach;
    int? selectedTeamCategoryId = category?.idTeamCategory;
    bool isActive = category?.isActive == 1;

    // Pre-fetch data if editing
    if (category != null) {
      try {
        // Fetch specific data
        final specificCategory = await context
            .read<CoachTeamCategoryController>()
            .getCoachTeamCategoryById(category.idCoachTeam!);

        if (specificCategory != null) {
          selectedCoachId = specificCategory.idCoach;
          selectedTeamCategoryId = specificCategory.idTeamCategory;
          isActive = specificCategory.isActive == 1;
        }

        // Ensure coaches and team categories are loaded
        await context.read<CoachController>().fetchCoaches();
        await context.read<TeamCategoryController>().fetchTeamCategories();
      } catch (e) {
        print('Error fetching data: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          // Get active coaches and team categories
          final activeCoaches = context
              .read<CoachController>()
              .coaches
              .where((coach) => coach.statusCoach == 1)
              .toList();

          final activeTeamCategories = context
              .read<TeamCategoryController>()
              .teamCategories
              .where((team) => team.status == "1")
              .toList();

          // Ensure selected values exist in active lists
          if (category != null) {
            if (!activeCoaches
                .any((coach) => coach.idCoach == selectedCoachId)) {
              selectedCoachId = null;
            }
            if (!activeTeamCategories
                .any((team) => team.idTeamCategory == selectedTeamCategoryId)) {
              selectedTeamCategoryId = null;
            }
          }

          return Container(
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
                // Header with white text
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category == null
                            ? 'Tambah Coach Team'
                            : 'Edit Coach Team',
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
                // Form fields with white text
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Coach Dropdown with white text
                        Consumer<CoachController>(
                          builder: (context, coachController, child) {
                            if (coachController.coaches.isEmpty) {
                              return const CircularProgressIndicator();
                            }

                            final activeCoaches = coachController.coaches
                                .where((coach) => coach.statusCoach == 1)
                                .toList();

                            return DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'Coach',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.person,
                                    color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFF7F50)),
                                ),
                              ),
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.white),
                              value: selectedCoachId,
                              hint: const Text('Pilih Coach',
                                  style: TextStyle(color: Colors.white70)),
                              items: activeCoaches.map((coach) {
                                return DropdownMenuItem(
                                  value: coach.idCoach,
                                  child: Text(coach.nameCoach),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedCoachId = value);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Team Category Dropdown with white text
                        Consumer<TeamCategoryController>(
                          builder: (context, teamCategoryController, child) {
                            if (teamCategoryController.teamCategories.isEmpty) {
                              return const CircularProgressIndicator();
                            }

                            final activeTeamCategories = teamCategoryController
                                .teamCategories
                                .where((team) => team.status == "1")
                                .toList();

                            return DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'Team Category',
                                labelStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.group,
                                    color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFFF7F50)),
                                ),
                              ),
                              dropdownColor: Colors.black,
                              style: const TextStyle(color: Colors.white),
                              value: selectedTeamCategoryId,
                              hint: const Text('Pilih Team Category',
                                  style: TextStyle(color: Colors.white70)),
                              items: activeTeamCategories.map((team) {
                                return DropdownMenuItem(
                                  value: team.idTeamCategory,
                                  child: Text(team.nameTeamCategory),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedTeamCategoryId = value);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Status Switch with white text
                        SwitchListTile(
                          title: const Text('Status',
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFFFF7F50)
                                  : Colors.white70,
                            ),
                          ),
                          value: isActive,
                          activeColor: const Color(0xFFFF7F50),
                          onChanged: (bool value) {
                            setState(() => isActive = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Submit Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedCoachId == null ||
                          selectedTeamCategoryId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Semua field harus diisi')),
                        );
                        return;
                      }

                      final newCategory = CoachTeamCategoryModel(
                        idCoachTeam: category?.idCoachTeam,
                        idCoach: selectedCoachId,
                        idTeamCategory: selectedTeamCategoryId,
                        nameCoach: '', // Will be filled by backend
                        nameTeamCategory: '', // Will be filled by backend
                        isActive: isActive ? 1 : 0,
                      );

                      final controller =
                          context.read<CoachTeamCategoryController>();
                      bool success;

                      try {
                        success = category == null
                            ? await controller
                                .createCoachTeamCategory(newCategory)
                            : await controller.updateCoachTeamCategory(
                                category.idCoachTeam!, newCategory);

                        if (success && mounted) {
                          Navigator.pop(context);
                          _showSnackBar(
                            category == null
                                ? 'Coach team berhasil ditambahkan'
                                : 'Coach team berhasil diupdate',
                          );
                        }
                      } catch (e) {
                        _showSnackBar('Gagal memproses coach team');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7F50),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      category == null ? 'Tambah' : 'Simpan',
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
          );
        },
      ),
    );
  }

  void _showDeleteDialog(CoachTeamCategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Coach Team'),
        content: Text(
            'Apakah Anda yakin ingin menghapus ${category.nameCoach} dari ${category.nameTeamCategory}?'),
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
                  .read<CoachTeamCategoryController>()
                  .deleteCoachTeamCategory(category.idCoachTeam!);

              if (!mounted) return;
              Navigator.pop(context);
              _showSnackBar(
                success
                    ? 'Coach team berhasil dihapus'
                    : 'Gagal menghapus coach team',
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF7F50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
