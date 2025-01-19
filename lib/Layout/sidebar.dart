import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the userName from AuthController
    final userName = context.watch<AuthController>().userName;

    return Drawer(
      child: Container(
        color: const Color(0xFF1A1B1E),
        child: Column(
          children: [
            // Status bar space
            Container(
              color: const Color(0xFFFF7F50),
              height: MediaQuery.of(context).padding.top,
            ),
            // Header with centered profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFFF7F50),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  // Profile picture with tap gesture
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                    child: const CircleAvatar(
                      radius: 35,
                      backgroundImage:
                          AssetImage('images/profile_placeholder.png'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Username
                  Text(
                    'Hai, $userName!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  _buildMenuItem(
                    icon: Icons.home_outlined,
                    title: 'Home',
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Info',
                  ),
                  _buildMenuItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Schedule',
                  ),
                  _buildMenuItem(
                    icon: Icons.groups_outlined,
                    title: 'Students',
                  ),
                  _buildMenuItem(
                    icon: Icons.sports_outlined,
                    title: 'Coach',
                  ),
                  _buildMenuItem(
                    icon: Icons.manage_accounts_outlined,
                    title: 'Management',
                  ),
                  _buildMenuItem(
                    icon: Icons.analytics_outlined,
                    title: 'Aspect',
                  ),
                  _buildMenuItem(
                    icon: Icons.category_outlined,
                    title: 'Aspek Sub',
                  ),
                  _buildMenuItem(
                    icon: Icons.business_outlined,
                    title: 'Departement',
                  ),
                  _buildMenuItem(
                    icon: Icons.assessment_outlined,
                    title: 'Assessment',
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Assessment Settings',
                  ),
                  _buildMenuItem(
                    icon: Icons.star_outline,
                    title: 'Point Rate',
                  ),
                  _buildMenuItem(
                    icon: Icons.group,
                    title: 'Team Category',
                  ),
                  _buildMenuItem(
                    icon: Icons.group_work,
                    title: 'Coach Team Category',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool showArrow = false,
  }) {
    return Builder(
      builder: (context) => SizedBox(
        height: 40,
        child: ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          minLeadingWidth: 20,
          dense: true,
          leading: title == 'Log out'
              ? null
              : Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight:
                  title == 'Log out' ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          trailing: title == 'Log out'
              ? Transform.translate(
                  offset: const Offset(8, 0),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 18,
                  ),
                )
              : null,
          tileColor: title == 'Log out' ? const Color(0xFFFF7F50) : null,
          shape: title == 'Log out'
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          onTap: () async {
            // Handle navigation based on menu item
            switch (title) {
              case 'Home':
                Navigator.pushNamed(context, AppRoutes.home);
                break;
              case 'Schedule':
                Navigator.pushNamed(context, AppRoutes.schedule);
                break;
              case 'Info':
                Navigator.pushNamed(context, AppRoutes.info);
                break;
              case 'Students':
                Navigator.pushNamed(context, AppRoutes.students);
                break;
              case 'Coach':
                Navigator.pushNamed(context, AppRoutes.coach);
                break;
              case 'Management':
                Navigator.pushNamed(context, AppRoutes.management);
                break;
              case 'Aspect':
                Navigator.pushNamed(context, AppRoutes.aspek);
                break;
              case 'Aspek Sub':
                Navigator.pushNamed(context, AppRoutes.aspekSub);
                break;
              case 'Departement':
                Navigator.pushNamed(context, AppRoutes.departement);
                break;
              case 'Assessment':
                Navigator.pushNamed(context, AppRoutes.asessment);
                break;
              case 'Assessment Settings':
                Navigator.pushNamed(context, AppRoutes.asessmentSetting);
                break;
              case 'Point Rate':
                Navigator.pushNamed(context, AppRoutes.pointRate);
                break;
              case 'Team Category':
                Navigator.pushNamed(context, AppRoutes.teamCategory);
                break;
              case 'Coach Team Category':
                Navigator.pushNamed(context, AppRoutes.coachTeamCategory);
                break;
              case 'Log out':
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (shouldLogout) {
                  // Call logout from AuthController
                  await Provider.of<AuthController>(context, listen: false)
                      .logout();

                  if (context.mounted) {
                    // Navigate to login screen and clear navigation stack
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                }
                break;

              default:
                // Handle other menu items as before
                if (context.mounted) {
                  Navigator.pop(context); // Close drawer
                }
            }
          },
        ),
      ),
    );
  }
}
