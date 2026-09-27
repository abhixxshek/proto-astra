import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/server_settings_dialog.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AgroSmart Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Configure Backend Server IP',
            onPressed: () => ServerSettingsDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.help),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.dashboard),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Hello, ${user?.username ?? 'Farmer'}!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to your smart farming assistant. Select a tool below to make data-driven decisions.',
                    style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Soil & ML Intelligence',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Soil Report Intelligence Core Feature Card
            _buildWideCard(
              context,
              title: 'Soil Report Intelligence',
              subtitle: 'Upload Soil Test PDF -> Auto NPK extraction -> Crop, Yield & Fertilizer AI recommendations',
              icon: Icons.document_scanner_rounded,
              color: const Color(0xFF1B5E20),
              route: AppRoutes.soilReport,
              badge: 'AI CARD',
            ),
            const SizedBox(height: 12),

            // Plant Disease Detection Highlight Card
            _buildWideCard(
              context,
              title: 'Plant Leaf Disease Identification',
              subtitle: '39-class PyTorch Deep Learning leaf diagnosis & organic treatment advice',
              icon: Icons.healing_rounded,
              color: const Color(0xFFD32F2F),
              route: AppRoutes.diseaseDetection,
            ),
            const SizedBox(height: 12),

            // Feature Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildGridCard(
                  context,
                  title: 'Crop Rec.',
                  subtitle: 'Soil & Climate ML',
                  icon: Icons.grass_rounded,
                  color: const Color(0xFF2E7D32),
                  route: AppRoutes.cropRecommend,
                ),
                _buildGridCard(
                  context,
                  title: 'Fertilizer',
                  subtitle: 'NPK Optimization',
                  icon: Icons.science_rounded,
                  color: const Color(0xFF00796B),
                  route: AppRoutes.fertilizerRecommend,
                ),
                _buildGridCard(
                  context,
                  title: 'Yield Predict',
                  subtitle: 'Decision Tree ML',
                  icon: Icons.show_chart_rounded,
                  color: const Color(0xFFE65100),
                  route: AppRoutes.yieldPredict,
                ),
                _buildGridCard(
                  context,
                  title: 'Weather',
                  subtitle: 'Forecast & Spray',
                  icon: Icons.cloud_sync_rounded,
                  color: const Color(0xFF0277BD),
                  route: AppRoutes.weatherForecast,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Farmer Services & Live Feeds',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Integrated News & Mandi Cards
            _buildWideCard(
              context,
              title: 'Live Agriculture News',
              subtitle: 'Krishi Jagran portal live news feeds (Hindi & English)',
              icon: Icons.newspaper_rounded,
              color: const Color(0xFF2E7D32),
              route: AppRoutes.news,
              badge: 'LIVE',
            ),
            const SizedBox(height: 12),
            _buildWideCard(
              context,
              title: 'APMC Mandi Commodity Rates',
              subtitle: 'Daily Mandi min/max/modal spot market prices across India',
              icon: Icons.storefront_rounded,
              color: const Color(0xFFE65100),
              route: AppRoutes.marketPrices,
            ),
            const SizedBox(height: 12),
            _buildWideCard(
              context,
              title: 'Agri Seeds & Fertilizer Store',
              subtitle: 'Doorstep certified seeds, bio-fertilizers & knapsack sprayers',
              icon: Icons.shopping_bag_rounded,
              color: const Color(0xFF00796B),
              route: AppRoutes.shopping,
            ),
            const SizedBox(height: 12),
            _buildWideCard(
              context,
              title: 'Farmer AI Assistant',
              subtitle: '24/7 intelligent Q&A for crop diseases, soil prep & MSP',
              icon: Icons.smart_toy_rounded,
              color: const Color(0xFF1565C0),
              route: AppRoutes.chatbot,
            ),
            const SizedBox(height: 12),
            _buildWideCard(
              context,
              title: 'Farm Activity Planner',
              subtitle: 'Schedule sowing, irrigation, fertilizer & harvesting tasks',
              icon: Icons.event_available_rounded,
              color: const Color(0xFF6A1B9A),
              route: AppRoutes.tasks,
            ),
            const SizedBox(height: 12),
            _buildWideCard(
              context,
              title: 'Agri Transport & Rental',
              subtitle: 'Hire nearby tractors, harvesters & transport trucks',
              icon: Icons.agriculture_rounded,
              color: const Color(0xFF43A047),
              route: AppRoutes.transport,
            ),
            const SizedBox(height: 12),
            _buildWideCard(
              context,
              title: 'Agronomic Knowledge Hub',
              subtitle: 'Package of practices for Crops, Fruits & Govt Schemes',
              icon: Icons.menu_book_rounded,
              color: const Color(0xFF00838F),
              route: AppRoutes.knowledge,
            ),
            const SizedBox(height: 12),
            _buildWideCard(
              context,
              title: 'Agricultural Data Analytics',
              subtitle: 'Production cost, cultivation area & rainfall charts',
              icon: Icons.pie_chart_rounded,
              color: Colors.purple.shade700,
              route: AppRoutes.analysis,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return CustomCard(
      onTap: () => Navigator.pushNamed(context, route),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWideCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
    String? badge,
  }) {
    return CustomCard(
      onTap: () => Navigator.pushNamed(context, route),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
        ],
      ),
    );
  }
}
