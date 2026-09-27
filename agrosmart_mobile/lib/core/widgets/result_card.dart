import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import '../../app/theme/app_typography.dart';
import 'glass_card.dart';
import 'glass_button.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onReset;
  final IconData icon;

  const ResultCard({
    super.key,
    required this.title,
    required this.child,
    required this.onReset,
    this.icon = CupertinoIcons.checkmark_circle_fill,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      fillColor: Colors.white.withValues(alpha: 0.95),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.2),
      shadows: AppGlass.emeraldGlow,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.title2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),
          child,
          const SizedBox(height: 22),
          GlassButton(
            text: 'Analyze Another',
            icon: CupertinoIcons.refresh,
            variant: GlassButtonVariant.secondary,
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}
