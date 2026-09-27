import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app/config/api_config.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/url_launcher_util.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/result_card.dart';
import '../../core/widgets/server_settings_dialog.dart';
import '../../providers/disease_provider.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (file != null) {
        final Uint8List bytes = await file.readAsBytes();
        if (mounted) {
          Provider.of<DiseaseProvider>(context, listen: false).setImage(bytes, file.name);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final diseaseProvider = Provider.of<DiseaseProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Configure Backend Server IP',
            onPressed: () async {
              await ServerSettingsDialog.show(context);
              setState(() {});
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.diseaseDetection),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Identify Leaf Diseases Instantly',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await ServerSettingsDialog.show(context);
                    setState(() {});
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.dns, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          ApiConfig.baseUrl.replaceAll('/api/v1', '').replaceAll('http://', ''),
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload or take a photo of a crop leaf. Our 39-class PyTorch Deep Convolutional Neural Network will analyze and identify diseases, symptoms, and organic treatment supplements.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),


            // Image Selection Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (diseaseProvider.selectedImageBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.memory(
                            diseaseProvider.selectedImageBytes!,
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withAlpha(150),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => diseaseProvider.reset(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_sharp, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            diseaseProvider.selectedFileName ?? 'leaf_sample.jpg',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withAlpha(60), style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 54, color: AppColors.primary.withAlpha(200)),
                          const SizedBox(height: 12),
                          const Text(
                            'Select or Capture Leaf Image',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Supports JPG, PNG (Max 10MB)',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                          label: const Text('Camera', style: TextStyle(color: AppColors.primary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, color: AppColors.primary),
                          label: const Text('Gallery', style: TextStyle(color: AppColors.primary)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Diagnose Plant Disease',
                    icon: Icons.search,
                    isLoading: diseaseProvider.isLoading,
                    onPressed: diseaseProvider.selectedImageBytes != null
                        ? () => diseaseProvider.detectDisease()
                        : null,
                  ),
                ],
              ),
            ),

            if (diseaseProvider.errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withAlpha(80)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'Prediction Error / Server Unreachable',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      diseaseProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await ServerSettingsDialog.show(context);
                              setState(() {});
                            },
                            icon: const Icon(Icons.settings_ethernet, size: 16),
                            label: const Text('Change Server IP'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => diseaseProvider.detectDisease(),
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],


            // Results Section
            if (diseaseProvider.result != null) ...[
              const SizedBox(height: 24),
              ResultCard(
                title: 'Diagnosis & Treatment Plan',
                icon: Icons.healing,
                onReset: () => diseaseProvider.reset(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease Header & Confidence
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: diseaseProvider.result!.diseaseName.toLowerCase().contains('healthy')
                            ? Colors.green.withAlpha(25)
                            : Colors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: diseaseProvider.result!.diseaseName.toLowerCase().contains('healthy')
                              ? Colors.green.withAlpha(100)
                              : Colors.orange.withAlpha(100),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            diseaseProvider.result!.diseaseName.toLowerCase().contains('healthy')
                                ? Icons.check_circle
                                : Icons.warning_amber_rounded,
                            color: diseaseProvider.result!.diseaseName.toLowerCase().contains('healthy')
                                ? Colors.green
                                : Colors.orange[800],
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  diseaseProvider.result!.diseaseName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Class: ${diseaseProvider.result!.rawClassLabel}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${diseaseProvider.result!.confidence.toStringAsFixed(1)}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Description Box
                    const Text(
                      'Disease Overview',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      diseaseProvider.result!.description,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 18),

                    // Prevention Steps
                    const Text(
                      'Recommended Control & Prevention Steps',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        diseaseProvider.result!.prevention,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Background Without Leaves Notification
                    if (diseaseProvider.result!.predictionIndex == 4) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey.withAlpha(100)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blueGrey, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No plant leaf detected in this photo. For accurate results, capture a clear close-up photo of a single plant leaf.',
                                style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Supplement Recommendation Box
                    if (diseaseProvider.result!.supplement.name.isNotEmpty &&
                        diseaseProvider.result!.supplement.name != 'N/A' &&
                        diseaseProvider.result!.predictionIndex != 4) ...[
                      const Text(
                        'Recommended Fungicide / Supplement Treatment',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.amber.withAlpha(120)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9900).withAlpha(40),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.local_pharmacy, color: Color(0xFFD67700), size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        diseaseProvider.result!.supplement.name,
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        diseaseProvider.result!.supplement.amazonSearchQuery.isNotEmpty
                                            ? 'Search: "${diseaseProvider.result!.supplement.amazonSearchQuery}"'
                                            : 'Recommended plant treatment product',
                                        style: TextStyle(fontSize: 12, color: Colors.amber[900], fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Primary: Guaranteed Amazon Direct Search (Zero 403 Forbidden errors!)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final query = diseaseProvider.result!.supplement.amazonSearchQuery.isNotEmpty
                                      ? diseaseProvider.result!.supplement.amazonSearchQuery
                                      : '${diseaseProvider.result!.supplement.name} fungicide';
                                  UrlLauncherUtil.launchAmazonSearch(context, query);
                                },
                                icon: const Icon(Icons.shopping_cart, size: 19),
                                label: const Text('Buy Treatment on Amazon'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9900),
                                  foregroundColor: Colors.black87,
                                  elevation: 1,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Secondary: Alternative Store Link with fallback
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final link = diseaseProvider.result!.supplement.buyLink.isNotEmpty
                                      ? diseaseProvider.result!.supplement.buyLink
                                      : diseaseProvider.result!.supplement.amazonBuyLink;
                                  UrlLauncherUtil.launchEcommerceUrl(
                                    context,
                                    link,
                                    fallbackSearchQuery: diseaseProvider.result!.supplement.amazonSearchQuery,
                                  );
                                },
                                icon: const Icon(Icons.storefront, size: 17, color: AppColors.primary),
                                label: const Text('Alternative Store Link', style: TextStyle(color: AppColors.primary)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],


                    // Top Predictions Confidence Breakdown
                    if (diseaseProvider.result!.topPredictions.isNotEmpty) ...[
                      const Text(
                        'Class Confidence Distribution',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      ...diseaseProvider.result!.topPredictions.map((pred) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      pred.diseaseName,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${pred.confidence.toStringAsFixed(1)}%',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (pred.confidence / 100).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey.withAlpha(40),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    pred.confidence > 70 ? AppColors.primary : Colors.amber,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
