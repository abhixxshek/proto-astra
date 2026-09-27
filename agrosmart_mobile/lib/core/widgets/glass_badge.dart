import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import '../../app/theme/app_typography.dart';

enum BadgeType {
  primary,
  success,
  warning,
  error,
  info,
  neutral,
}

/// iOS-styled Frosted Pill Status Badge
class GlassBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final BadgeType type;
  final Color? customColor;

  const GlassBadge({
    super.key,
    required this.label,
    this.icon,
    this.type = BadgeType.primary,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor;
    switch (type) {
      case BadgeType.primary:
        baseColor = customColor ?? AppColors.primary;
        break;
      case BadgeType.success:
        baseColor = AppColors.success;
        break;
      case BadgeType.warning:
        baseColor = AppColors.warning;
        break;
      case BadgeType.error:
        baseColor = AppColors.error;
        break;
      case BadgeType.info:
        baseColor = AppColors.info;
        break;
      case BadgeType.neutral:
        baseColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: AppGlass.borderRadiusPill,
        border: Border.all(
          color: baseColor.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: baseColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: baseColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
