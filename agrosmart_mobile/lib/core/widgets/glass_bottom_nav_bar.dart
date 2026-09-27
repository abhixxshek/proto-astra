import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import '../../app/theme/app_typography.dart';

enum GlassNavTab {
  dashboard,
  soilReport,

  store,
  profile,
}

/// Floating iOS Frosted Glass Bottom Navigation Bar
class GlassBottomNavBar extends StatelessWidget {
  final GlassNavTab currentTab;
  final ValueChanged<GlassNavTab>? onTabSelected;

  const GlassBottomNavBar({
    super.key,
    required this.currentTab,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 14),
        height: 66,
        decoration: BoxDecoration(
          borderRadius: AppGlass.borderRadiusPill,
          boxShadow: AppGlass.floatingShadow,
        ),
        child: ClipRRect(
          borderRadius: AppGlass.borderRadiusPill,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppGlass.blurHeavy,
              sigmaY: AppGlass.blurHeavy,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: AppGlass.borderRadiusPill,
                border: Border.all(
                  color: AppColors.glassBorderLight,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    tab: GlassNavTab.dashboard,
                    icon: CupertinoIcons.home,
                    activeIcon: CupertinoIcons.house_fill,
                    label: 'Home',
                    route: AppRoutes.dashboard,
                  ),
                  _buildNavItem(
                    context,
                    tab: GlassNavTab.soilReport,
                    icon: CupertinoIcons.doc_text,
                    activeIcon: CupertinoIcons.doc_text_fill,
                    label: 'Soil Health',
                    route: AppRoutes.soilReport,
                  ),

                  _buildNavItem(
                    context,
                    tab: GlassNavTab.store,
                    icon: CupertinoIcons.cart,
                    activeIcon: CupertinoIcons.cart_fill,
                    label: 'Store',
                    route: AppRoutes.shopping,
                  ),
                  _buildNavItem(
                    context,
                    tab: GlassNavTab.profile,
                    icon: CupertinoIcons.person_crop_circle,
                    activeIcon: CupertinoIcons.person_crop_circle_fill,
                    label: 'Profile',
                    route: AppRoutes.profile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required GlassNavTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
  }) {
    final isSelected = currentTab == tab;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (onTabSelected != null) {
            onTabSelected!(tab);
          } else if (!isSelected) {
            Navigator.pushNamed(context, route);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: AppGlass.borderRadiusPill,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
