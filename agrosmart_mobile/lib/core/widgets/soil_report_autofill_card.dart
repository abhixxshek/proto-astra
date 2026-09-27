import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/soil_report_provider.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import '../../app/theme/app_typography.dart';
import 'glass_card.dart';
import 'glass_badge.dart';

class SoilReportAutofillCard extends StatelessWidget {
  final VoidCallback onAutofill;
  final String featureName;

  const SoilReportAutofillCard({
    super.key,
    required this.onAutofill,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    final soilProvider = context.watch<SoilReportProvider>();

    if (soilProvider.hasSoilData) {
      final n = soilProvider.nitrogen != null ? '${soilProvider.nitrogen!.toStringAsFixed(0)} N' : null;
      final p = soilProvider.phosphorus != null ? '${soilProvider.phosphorus!.toStringAsFixed(1)} P' : null;
      final k = soilProvider.potassium != null ? '${soilProvider.potassium!.toStringAsFixed(0)} K' : null;
      final ph = soilProvider.ph != null ? 'pH ${soilProvider.ph!.toStringAsFixed(1)}' : null;
      final soilType = soilProvider.soilType;

      final summaryList = [n, p, k, ph, soilType].whereType<String>().toList();
      final summaryStr = summaryList.isNotEmpty ? summaryList.join(' • ') : 'Verified Profile';

      return GlassCard(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        fillColor: AppColors.primaryMuted.withValues(alpha: 0.75),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppGlass.borderRadiusSm,
                boxShadow: AppGlass.softShadow,
              ),
              child: const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 18),
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
                          'Soil Health Data Synced',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const GlassBadge(
                        label: 'AI ACTIVE',
                        type: BadgeType.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    summaryStr,
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAutofill,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppGlass.borderRadiusPill,
                  boxShadow: AppGlass.softShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.arrow_down_doc_fill, size: 13, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      'Apply',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Prompts farmer to upload soil report
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      fillColor: Colors.white.withValues(alpha: 0.8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppGlass.borderRadiusSm,
            ),
            child: const Icon(CupertinoIcons.doc_text_viewfinder, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have a Soil Test Report?',
                  style: AppTypography.subhead.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Upload PDF to autofill $featureName parameters.',
                  style: AppTypography.footnote.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.soilReport),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppGlass.borderRadiusPill,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.0),
              ),
              child: Text(
                'Upload PDF',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
