import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/soil_report_provider.dart';
import '../../app/routes/app_routes.dart';

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

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text(
                        'Verified Soil Report Available',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8E6C9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'AI Synced',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    summaryStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                onAutofill();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Form prefilled from verified Soil Test Profile!'),
                    backgroundColor: Color(0xFF2E7D32),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(64, 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Autofill', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    // When no soil report is present yet, show an invitation card
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have a Soil Test Report (PDF)?',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  'Upload in Soil Report Intelligence to autofill $featureName automatically.',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.soilReport),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
            child: const Text(
              'Upload PDF',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }
}
