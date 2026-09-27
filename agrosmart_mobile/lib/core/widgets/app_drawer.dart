import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            accountName: Text(
              user?.username ?? 'Farmer User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(user?.email ?? 'farmer@agrosmart.org'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.username.isNotEmpty ?? false) ? user!.username[0].toUpperCase() : 'A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  route: AppRoutes.dashboard,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.document_scanner_outlined,
                  title: 'Soil Report Intelligence',
                  route: AppRoutes.soilReport,
                  badge: 'AI CARD',
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.newspaper_outlined,
                  title: 'Live Agriculture News',
                  route: AppRoutes.news,
                  badge: 'LIVE',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.storefront_outlined,
                  title: 'APMC Mandi Market Rates',
                  route: AppRoutes.marketPrices,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  title: 'Agri Seeds & Inputs Store',
                  route: AppRoutes.shopping,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.smart_toy_outlined,
                  title: 'Farmer AI Assistant',
                  route: AppRoutes.chatbot,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.event_available_outlined,
                  title: 'Farm Task Planner',
                  route: AppRoutes.tasks,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.agriculture_outlined,
                  title: 'Agri Transport & Rental',
                  route: AppRoutes.transport,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.menu_book_outlined,
                  title: 'Agronomic Knowledge Hub',
                  route: AppRoutes.knowledge,
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.grass_outlined,
                  title: 'Crop Recommendation',
                  route: AppRoutes.cropRecommend,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.science_outlined,
                  title: 'Fertilizer Recommendation',
                  route: AppRoutes.fertilizerRecommend,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart_outlined,
                  title: 'Yield Prediction',
                  route: AppRoutes.yieldPredict,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.healing_outlined,
                  title: 'Plant Disease Detection',
                  route: AppRoutes.diseaseDetection,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.cloud_outlined,
                  title: 'Weather Forecast',
                  route: AppRoutes.weatherForecast,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.pie_chart_outline,
                  title: 'Agricultural Analytics',
                  route: AppRoutes.analysis,
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  route: AppRoutes.profile,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  route: AppRoutes.help,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            onTap: () {
              authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    String? badge,
  }) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      selected: isSelected,
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
