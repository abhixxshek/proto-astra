import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/glass_badge.dart';
import '../../core/widgets/glass_bottom_nav_bar.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/server_settings_dialog.dart';
import '../../providers/auth_provider.dart';
import '../../providers/soil_report_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final soilProvider = Provider.of<SoilReportProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: AppRoutes.dashboard),
      body: Stack(
        children: [
          // Background subtle ambient gradients
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.iosTeal.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Content with iOS slivers
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // iOS-styled Frosted Navigation Bar
              SliverAppBar(
                pinned: true,
                floating: false,
                expandedHeight: 120,
                elevation: 0,
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                surfaceTintColor: Colors.transparent,
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(CupertinoIcons.line_horizontal_3, size: 24, color: AppColors.textPrimary),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    tooltip: 'Menu',
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.antenna_radiowaves_left_right, size: 20, color: AppColors.textPrimary),
                    tooltip: 'Configure Backend IP',
                    onPressed: () => ServerSettingsDialog.show(context),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.question_circle, size: 20, color: AppColors.textPrimary),
                    tooltip: 'Help',
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.help),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16, left: 4),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.0),
                      ),
                      child: Center(
                        child: Text(
                          (user?.username.isNotEmpty ?? false) ? user!.username[0].toUpperCase() : 'A',
                          style: AppTypography.callout.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  title: Text(
                    'AgroSmart',
                    style: AppTypography.largeTitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Dashboard Body Content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Apple-grade Frosted Hero Banner
                    _buildHeroBanner(context, user?.username ?? 'Farmer', soilProvider),
                    const SizedBox(height: 24),

                    // 2. Core Agronomic & AI Models
                    _buildSectionTitle(
                      title: 'Agronomic AI Models',
                      subtitle: 'Predictive intelligence & diagnostic computer vision',
                    ),
                    const SizedBox(height: 12),

                    // Soil Report Intelligence Core Feature Card
                    _buildWideActionCard(
                      context,
                      title: 'Soil Report Intelligence',
                      subtitle: 'Upload Soil Test PDF -> Auto NPK extraction -> Combined AI Advisory',
                      icon: CupertinoIcons.doc_text_viewfinder,
                      accentColor: AppColors.primary,
                      route: AppRoutes.soilReport,
                      badge: 'AI CARD',
                      badgeType: BadgeType.success,
                    ),
                    const SizedBox(height: 12),

                    // Plant Leaf Disease Card
                    _buildWideActionCard(
                      context,
                      title: 'Leaf Disease Diagnosis',
                      subtitle: '39-class PyTorch Deep Learning leaf diagnosis & organic treatment',
                      icon: CupertinoIcons.bandage_fill,
                      accentColor: AppColors.iosRed,
                      route: AppRoutes.diseaseDetection,
                      badge: 'VISION AI',
                      badgeType: BadgeType.error,
                    ),
                    const SizedBox(height: 14),

                    // 2x2 Feature Grid (Crop, Fertilizer, Yield, Weather)
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
                          icon: CupertinoIcons.tree,
                          accentColor: AppColors.primary,
                          route: AppRoutes.cropRecommend,
                        ),
                        _buildGridCard(
                          context,
                          title: 'Fertilizer',
                          subtitle: 'NPK Optimization',
                          icon: CupertinoIcons.lab_flask,
                          accentColor: AppColors.iosTeal,
                          route: AppRoutes.fertilizerRecommend,
                        ),
                        _buildGridCard(
                          context,
                          title: 'Yield Predict',
                          subtitle: 'Decision Tree Regressor',
                          icon: CupertinoIcons.chart_bar_alt_fill,
                          accentColor: AppColors.iosOrange,
                          route: AppRoutes.yieldPredict,
                        ),
                        _buildGridCard(
                          context,
                          title: 'Weather',
                          subtitle: '5-Day Forecast & Spray',
                          icon: CupertinoIcons.cloud_sun_fill,
                          accentColor: AppColors.iosBlue,
                          route: AppRoutes.weatherForecast,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 3. Farm Operations & Commerce Section
                    _buildSectionTitle(
                      title: 'Farm Operations & Commerce',
                      subtitle: 'Real-time commodity mandi rates and certified farm inputs',
                    ),
                    const SizedBox(height: 12),

                    _buildWideActionCard(
                      context,
                      title: 'APMC Mandi Spot Rates',
                      subtitle: 'Daily wholesale market commodity rates across Indian mandis',
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      accentColor: AppColors.accent,
                      route: AppRoutes.marketPrices,
                    ),
                    const SizedBox(height: 12),

                    _buildWideActionCard(
                      context,
                      title: 'Agri Seeds & Inputs Store',
                      subtitle: 'Doorstep certified seeds, bio-fertilizers & knapsack sprayers',
                      icon: CupertinoIcons.cart_fill,
                      accentColor: AppColors.secondary,
                      route: AppRoutes.shopping,
                    ),
                    const SizedBox(height: 12),

                    _buildWideActionCard(
                      context,
                      title: 'Transport & Machinery Rental',
                      subtitle: 'Book local tractors, combine harvesters & logistics trucks',
                      icon: CupertinoIcons.car_detailed,
                      accentColor: AppColors.iosTeal,
                      route: AppRoutes.transport,
                    ),
                    const SizedBox(height: 12),

                    _buildWideActionCard(
                      context,
                      title: 'Farm Activity Planner',
                      subtitle: 'Organize crop sowing, irrigation, fertilizer & harvesting logs',
                      icon: CupertinoIcons.calendar,
                      accentColor: AppColors.iosPurple,
                      route: AppRoutes.tasks,
                    ),

                    const SizedBox(height: 28),

                    // 4. Intelligence & Live Feeds Section
                    _buildSectionTitle(
                      title: 'Intelligence & Live Feeds',
                      subtitle: 'Automated AI assistant, agricultural news, and regional analytics',
                    ),
                    const SizedBox(height: 12),

                    _buildWideActionCard(
                      context,
                      title: 'Farmer AI Assistant',
                      subtitle: '24/7 intelligent chat for pest symptoms, soil prep & MSP rules',
                      icon: CupertinoIcons.chat_bubble_2_fill,
                      accentColor: AppColors.iosBlue,
                      route: AppRoutes.chatbot,
                    ),
                    const SizedBox(height: 12),

                    _buildWideActionCard(
                      context,
                      title: 'Live Agriculture News',
                      subtitle: 'Verified agricultural bulletins from Krishi Jagran & ICAR',
                      icon: CupertinoIcons.news_solid,
                      accentColor: AppColors.primary,
                      route: AppRoutes.news,
                      badge: 'LIVE',
                      badgeType: BadgeType.error,
                    ),
                    const SizedBox(height: 12),

                    _buildWideActionCard(
                      context,
                      title: 'Agronomic Knowledge Hub',
                      subtitle: 'ICAR Package of Practices for 50+ Cereals, Fruits & Pulses',
                      icon: CupertinoIcons.book_fill,
                      accentColor: AppColors.iosIndigo,
                      route: AppRoutes.knowledge,
                    ),
                    const SizedBox(height: 12),

                    _buildWideActionCard(
                      context,
                      title: 'Production Analytics',
                      subtitle: 'Multi-year district crop yields, rainfall patterns & charts',
                      icon: CupertinoIcons.chart_pie_fill,
                      accentColor: AppColors.iosPurple,
                      route: AppRoutes.analysis,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Floating Glass Bottom Navigation Bar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomNavBar(currentTab: GlassNavTab.dashboard),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.title3.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.footnote.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context, String farmerName, SoilReportProvider soilProvider) {
    final hasSoilData = soilProvider.hasSoilData;
    final soilSummary = hasSoilData
        ? '${soilProvider.nitrogen?.toStringAsFixed(0) ?? "--"} N • ${soilProvider.phosphorus?.toStringAsFixed(1) ?? "--"} P • ${soilProvider.potassium?.toStringAsFixed(0) ?? "--"} K'
        : 'No Soil Card Active';

    return GlassCard(
      padding: const EdgeInsets.all(22),
      gradient: AppColors.heroGradient,
      border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.2),
      shadows: AppGlass.emeraldGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.sun_max_fill, color: Colors.amber, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Good Day, $farmerName',
                        style: AppTypography.title3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GlassBadge(
                label: hasSoilData ? 'AI SYNCED' : 'READY',
                icon: CupertinoIcons.sparkles,
                type: BadgeType.neutral,
                customColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            hasSoilData
                ? 'Your farm has an active verified soil profile ($soilSummary). AI recommendations are personalized for your field.'
                : 'Upload your soil test card or run a demo to unlock tailored AI crop, yield, and nutrient advisory.',
            style: AppTypography.callout.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  text: hasSoilData ? 'View Soil Report' : 'Analyze Soil Card',
                  icon: CupertinoIcons.doc_text_viewfinder,
                  variant: GlassButtonVariant.secondary,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.soilReport),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWideActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String route,
    String? badge,
    BadgeType badgeType = BadgeType.primary,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      onTap: () => Navigator.pushNamed(context, route),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: AppGlass.borderRadiusMd,
              border: Border.all(color: accentColor.withValues(alpha: 0.22), width: 1.0),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.headline.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null)
                      GlassBadge(
                        label: badge,
                        type: badgeType,
                        customColor: accentColor,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String route,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: AppGlass.borderRadiusSm,
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const Icon(CupertinoIcons.arrow_up_right, size: 14, color: AppColors.textTertiary),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.callout.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
