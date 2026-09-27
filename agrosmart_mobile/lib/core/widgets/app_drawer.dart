import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import '../../app/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import 'glass_badge.dart';

/// Premium iOS Frosted Glass App Drawer
class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppGlass.blurHeavy,
            sigmaY: AppGlass.blurHeavy,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              border: const Border(
                right: BorderSide(color: AppColors.glassBorderLight, width: 1.2),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // User Profile iOS Header Card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: AppGlass.borderRadiusLg,
                        boxShadow: AppGlass.emeraldGlow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppGlass.softShadow,
                            ),
                            child: Center(
                              child: Text(
                                (user?.username.isNotEmpty ?? false)
                                    ? user!.username[0].toUpperCase()
                                    : 'A',
                                style: AppTypography.title2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.username ?? 'Farmer User',
                                  style: AppTypography.title3.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? 'farmer@agrosmart.org',
                                  style: AppTypography.footnote.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                const GlassBadge(
                                  label: 'PRO FARMER',
                                  icon: CupertinoIcons.sparkles,
                                  type: BadgeType.neutral,
                                  customColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Grouped Navigation Items (iOS List Section Style)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildSectionHeader('CORE INTELLIGENCE'),
                        _buildDrawerTile(
                          context,
                          icon: CupertinoIcons.house_fill,
                          title: 'Dashboard',
                          route: AppRoutes.dashboard,
                        ),
                        _buildDrawerTile(
                          context,
                          icon: CupertinoIcons.doc_text_viewfinder,
                          title: 'Soil Health Card AI',
                          route: AppRoutes.soilReport,
                          badge: 'AI CARD',
                        ),

                        _buildDrawerTile(
                          context,
                          icon: CupertinoIcons.bandage_fill,
                          title: 'Plant Leaf Disease',
                          route: AppRoutes.diseaseDetection,
                        ),

                        const SizedBox(height: 14),
                        _buildSectionHeader('FARM OPERATIONS & COMMERCE'),

                        _buildDrawerTile(
                          context,
                          icon: CupertinoIcons.money_dollar_circle_fill,
                          title: 'Mandi Market Rates',
                          route: AppRoutes.marketPrices,
                        ),
                        _buildDrawerTile(
                          context,
                          icon: CupertinoIcons.cart_fill,
                          title: 'Agri Inputs Store',
                          route: AppRoutes.shopping,
                        ),


                        _buildDrawerTile(
                          context,
                          icon: CupertinoIcons.car_detailed,
                          title: 'Transport & Rental',
                          route: AppRoutes.transport,
                        ),

                        _buildDrawerTile(
                          context,
                          icon: CupertinoIcons.cloud_sun_fill,
                          title: 'Weather Forecast',
                          route: AppRoutes.weatherForecast,
                        ),


                        const SizedBox(height: 14),
                        _buildSectionHeader('ACCOUNT & SETTINGS'),
                        _buildDrawerTile(
                          context,
                          icon: CupertinoIcons.person_crop_circle_fill,
                          title: 'My Profile',
                          route: AppRoutes.profile,
                        ),
                        _buildDrawerTile(
                          context,
                          icon: CupertinoIcons.question_circle_fill,
                          title: 'Help & Support',
                          route: AppRoutes.help,
                        ),
                      ],
                    ),
                  ),

                  // Bottom Logout Pill
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.errorLight.withValues(alpha: 0.6),
                        borderRadius: AppGlass.borderRadiusPill,
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppGlass.borderRadiusPill,
                        ),
                        leading: const Icon(CupertinoIcons.power, color: AppColors.error, size: 20),
                        title: Text(
                          'Sign Out',
                          style: AppTypography.headline.copyWith(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          authProvider.logout();
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 6),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    String? badge,
  }) {
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: AppGlass.borderRadiusSm,
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.callout.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (badge != null)
              GlassBadge(
                label: badge,
                type: badge == 'LIVE' ? BadgeType.error : BadgeType.primary,
              ),
          ],
        ),
        onTap: () {
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, route);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
