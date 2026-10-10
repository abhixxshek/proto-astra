import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_glass.dart';
import '../../../app/theme/app_typography.dart';

class ListVehicleBanner extends StatelessWidget {
  final bool isHindi;
  final VoidCallback onListPressed;

  const ListVehicleBanner({
    super.key,
    required this.isHindi,
    required this.onListPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F4D27),
            Color(0xFF1E6F3D),
            Color(0xFF26A69A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppGlass.emeraldGlow,
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: Color(0xFFFFD54F),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHindi
                      ? 'ट्रैक्टर या वाहन है? किराए पर देकर कमाएं।'
                      : 'Have a tractor or vehicle? Earn by renting it out.',
                  style: AppTypography.callout.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isHindi
                      ? 'अपना वाहन सूचीबद्ध करें और जरूरतमंद किसानों से जुड़ें।'
                      : 'List your vehicle and connect with farmers who need it.',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action Button
          ElevatedButton(
            onPressed: onListPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  isHindi ? 'सूचीबद्ध करें' : 'List Vehicle',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
