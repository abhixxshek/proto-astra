import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      title: ' AI Model Analyse',
                     // subtitle: 'Predictive intelligence & diagnostic computer vision',
                    ),
                    const SizedBox(height: 12),

                    // Soil Report Intelligence Core Feature Card
                    _buildWideActionCard(
                      context,
                      title: 'Soil Report Intelligence',
                      //subtitle: 'Upload Soil Test PDF -> Auto NPK extraction -> Combined AI Advisory',
                      icon: CupertinoIcons.doc_text_viewfinder,
                      accentColor: AppColors.primary,
                      route: AppRoutes.soilReport,
                      //badge: 'AI CARD',
                      badgeType: BadgeType.success,
                    ),
                    const SizedBox(height: 12),

                    // Plant Leaf Disease Card
                    _buildWideActionCard(
                      context,
                      title: 'Leaf Disease Prediction',
                      //subtitle: '39-class PyTorch Deep Learning leaf diagnosis & organic treatment',
                      icon: CupertinoIcons.bandage_fill,
                      accentColor: AppColors.iosRed,
                      route: AppRoutes.diseaseDetection,
                      //badge: 'VISION AI',
                      badgeType: BadgeType.error,
                    ),
                    const SizedBox(height: 14),

                    // Quick Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRoundAction(context, title: 'Weather', icon: CupertinoIcons.cloud_sun_fill, accentColor: AppColors.iosBlue, route: AppRoutes.weatherForecast),
                        _buildRoundAction(context, title: 'Market', icon: CupertinoIcons.money_dollar_circle_fill, accentColor: AppColors.accent, route: AppRoutes.marketPrices),
                        _buildRoundAction(context, title: 'Seed Store', icon: CupertinoIcons.cart_fill, accentColor: AppColors.secondary, route: AppRoutes.shopping),
                        _buildRoundAction(context, title: 'Transport', icon: CupertinoIcons.car_detailed, accentColor: AppColors.iosTeal, route: AppRoutes.transport),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 4. Intelligence & Live Feeds Section
                    _buildSectionTitle(
                      title: 'Intelligence & Live Feeds',
                      subtitle: 'Automated AI assistant, agricultural news, and regional analytics',
                    ),
                    const SizedBox(height: 12),

                    const _LiveNewsCarousel(),
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

  Widget _buildSectionTitle({required String title, String? subtitle}) {
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
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.footnote.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
    String? subtitle,
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
                if (subtitle != null) ...[
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
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildRoundAction(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withValues(alpha: 0.22), width: 1.0),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveNewsCarousel extends StatefulWidget {
  const _LiveNewsCarousel();

  @override
  State<_LiveNewsCarousel> createState() => _LiveNewsCarouselState();
}

class _LiveNewsCarouselState extends State<_LiveNewsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _newsItems = [
    {
      'title': 'Government announces new MSP for Rabi crops 2026-27',
      'source': 'Krishi Jagran',
      'snippet': 'The cabinet has approved an increase in the Minimum Support Price (MSP) for all mandated Rabi crops...',
      'imageUrl': 'https://images.unsplash.com/photo-1592982537447-6f2a6a0c5c1b?auto=format&fit=crop&w=400&q=80',
      'url': 'https://krishijagran.com/',
    },
    {
      'title': 'ICAR releases drought-resistant wheat varieties',
      'source': 'ICAR News',
      'snippet': 'New varieties promise better yields in rain-fed regions and require 20% less irrigation.',
      'imageUrl': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=400&q=80',
      'url': 'https://icar.org.in/',
    },
    {
      'title': 'Global fertilizer prices stabilize after recent dip',
      'source': 'Agri Business',
      'snippet': 'Farmers can expect consistent pricing for urea and DAP in the upcoming sowing season.',
      'imageUrl': 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?auto=format&fit=crop&w=400&q=80',
      'url': 'https://www.agribusinessglobal.com/',
    }
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _newsItems.length) {
          nextPage = 0;
          _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
        } else {
          _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: _newsItems.length,
        itemBuilder: (context, index) {
          final item = _newsItems[index];
          return GestureDetector(
            onTap: () => _launchUrl(item['url']!),
            child: GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            item['imageUrl']!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: GlassBadge(
                              label: item['source']!,
                              type: BadgeType.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: AppTypography.callout.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                              item['snippet']!,
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
        },
      ),
    );
  }
}
