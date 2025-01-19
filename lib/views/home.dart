import 'package:flutter/material.dart';
import '../Layout/sidebar.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/management_controller.dart';
import '../controllers/coach_team_category_controller.dart';
import '../controllers/info_controller.dart';
import '../views/info.dart';
import '../views/info_detail.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  double _containerHeight = 0.25;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkAuth();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    // Add info fetch
    context.read<InfoController>().fetchInfos();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      // Get controllers using Provider
      final studentController =
          Provider.of<StudentController>(context, listen: false);
      final managementController =
          Provider.of<ManagementController>(context, listen: false);
      final coachController =
          Provider.of<CoachTeamCategoryController>(context, listen: false);

      // Fetch data secara bersamaan menggunakan Future.wait
      await Future.wait([
        studentController.fetchTotalsByCategory(),
        managementController.fetchTotalsByDepartment(),
        coachController.fetchCoachTeamCategories(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Pastikan untuk tidak memanggil _loadData setelah dispose
    super.dispose();
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxHeight = MediaQuery.of(context).size.height * 0.25;

    setState(() {
      _containerHeight = (maxHeight - scrollOffset).clamp(0.0, maxHeight) /
          MediaQuery.of(context).size.height;
    });
  }

  void _checkAuth() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final isAuthenticated = await authController.checkAuth();

    if (!isAuthenticated && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const Sidebar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Stack(
          children: [
            // Combined black background container
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height:
                    MediaQuery.of(context).size.height * _containerHeight + 100,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
              ),
            ),
            // Content
            Column(
              children: [
                // Custom AppBar with increased height
                SafeArea(
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: IconButton(
                            icon: const Icon(Icons.menu,
                                color: Colors.white, size: 28),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
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
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildManagementCard(),
                          const SizedBox(height: 16),
                          _buildStudentCard(),
                          const SizedBox(height: 16),
                          _buildCoachCard(),
                          const SizedBox(height: 16),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Latest Info',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const InfoScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'See all >>',
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> items,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7F50),
                  ),
                ),
                Icon(icon, color: const Color(0xFFFF7F50)),
              ],
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 24,
                    width: 120,
                    color: Colors.white,
                  ),
                  Container(
                    height: 24,
                    width: 24,
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: 150,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 16,
                        width: 100,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 120,
                height: 70,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 100,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard() {
    return Consumer<StudentController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return _buildShimmerCard();
        }

        if (controller.error != null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                controller.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final totals = controller.totalsByCategory;
        return _buildCard(
          title: 'Students',
          items: totals.isEmpty
              ? [_buildCardItem('No Categories', '0 Players')]
              : totals.entries
                  .map((entry) => _buildCardItem(
                        entry.key,
                        '${entry.value} Active Players',
                      ))
                  .toList(),
          icon: Icons.school,
        );
      },
    );
  }

  Widget _buildManagementCard() {
    return Consumer<ManagementController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return _buildShimmerCard();
        }

        if (controller.error != null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                controller.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final totals = controller.totalsByDepartment;
        return _buildCard(
          title: 'Management',
          items: totals.isEmpty
              ? [_buildCardItem('No Departments', '0 Staff')]
              : totals.entries
                  .map((entry) => _buildCardItem(
                        entry.key,
                        '${entry.value} Active Staff',
                      ))
                  .toList(),
          icon: Icons.business,
        );
      },
    );
  }

  Widget _buildCoachCard() {
    return Consumer<CoachTeamCategoryController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return _buildShimmerCard();
        }

        final totals = controller.getTotalsByTeamCategory();
        return _buildCard(
          title: 'Coach',
          items: totals.isEmpty
              ? [_buildCardItem('No Categories', '0 Coach Active')]
              : totals.entries
                  .map((entry) => _buildCardItem(
                        entry.key,
                        '${entry.value} Coach Active',
                      ))
                  .toList(),
          icon: Icons.sports,
        );
      },
    );
  }

  Widget _buildInfoList() {
    return Consumer<InfoController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return Column(
            children: List.generate(3, (index) => _buildShimmerInfo()),
          );
        }

        final activeInfos = controller.infos
            .where((info) => info.statusInfo == 1)
            .take(5)
            .toList();

        if (activeInfos.isEmpty) {
          return const Center(
            child: Text('No active information available'),
          );
        }

        return Column(
          children: activeInfos
              .map((info) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InfoDetail(
                              idInformation: info.idInformation!,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 120,
                              height: 70,
                              child: info.photo != null
                                  ? Image(
                                      image: NetworkImage(info.photo!),
                                      width: 120,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 120,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.image,
                                              color: Colors.grey),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 120,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.image,
                                          color: Colors.grey),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  info.nameInfo,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  info.dateInfo,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  // Refresh method
  Future<void> _refreshData() async {
    await _loadData();
  }
}
