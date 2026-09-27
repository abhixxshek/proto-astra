import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/config/app_constants.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/url_launcher_util.dart';
import '../../core/utils/validators.dart';

import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_dropdown.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/result_card.dart';
import '../../data/models/fertilizer_recommendation_model.dart';
import '../../providers/fertilizer_provider.dart';
import '../../providers/soil_report_provider.dart';
import '../../core/widgets/soil_report_autofill_card.dart';

class FertilizerRecommendationScreen extends StatefulWidget {
  const FertilizerRecommendationScreen({super.key});

  @override
  State<FertilizerRecommendationScreen> createState() => _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState extends State<FertilizerRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedSoilType = AppConstants.soilTypes[0];
  String? _selectedCropType = AppConstants.cropTypes[0];

  final _tempController = TextEditingController(text: '26');
  final _humidityController = TextEditingController(text: '52');
  final _moistureController = TextEditingController(text: '38');
  final _nitrogenController = TextEditingController(text: '37');
  final _potassiumController = TextEditingController(text: '0');
  final _phosphorousController = TextEditingController(text: '0');

  bool _isPrefilledFromSoil = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final soilProvider = Provider.of<SoilReportProvider>(context);
    if (!_isPrefilledFromSoil && (soilProvider.hasSoilData || soilProvider.targetPreselectedCrop != null)) {
      _autofillFromSoilReport();
      _isPrefilledFromSoil = true;
    }
  }

  void _autofillFromSoilReport() {
    final soilProvider = Provider.of<SoilReportProvider>(context, listen: false);
    if (soilProvider.nitrogen != null) {
      _nitrogenController.text = soilProvider.nitrogen!.toStringAsFixed(0);
    }
    if (soilProvider.phosphorus != null) {
      _phosphorousController.text = soilProvider.phosphorus!.toStringAsFixed(1);
    }
    if (soilProvider.potassium != null) {
      _potassiumController.text = soilProvider.potassium!.toStringAsFixed(0);
    }
    if (soilProvider.soilMoisture != null) {
      _moistureController.text = soilProvider.soilMoisture!.toStringAsFixed(0);
    }
    if (soilProvider.temperature != null) {
      _tempController.text = soilProvider.temperature!.toStringAsFixed(1);
    }
    if (soilProvider.humidity != null) {
      _humidityController.text = soilProvider.humidity!.toStringAsFixed(0);
    }

    if (soilProvider.soilType != null) {
      final sType = soilProvider.soilType!.toLowerCase();
      for (final st in AppConstants.soilTypes) {
        if (st.toLowerCase().contains(sType) || sType.contains(st.toLowerCase())) {
          _selectedSoilType = st;
          break;
        }
      }
    }

    final targetCrop = soilProvider.targetPreselectedCrop ?? soilProvider.topRecommendedCrop;
    if (targetCrop != null) {
      final cName = targetCrop.toLowerCase();
      for (final ct in AppConstants.cropTypes) {
        if (ct.toLowerCase() == cName || ct.toLowerCase().contains(cName) || cName.contains(ct.toLowerCase())) {
          _selectedCropType = ct;
          break;
        }
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _tempController.dispose();
    _humidityController.dispose();
    _moistureController.dispose();
    _nitrogenController.dispose();
    _potassiumController.dispose();
    _phosphorousController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedSoilType != null && _selectedCropType != null) {
      final req = FertilizerRecommendationRequest(
        temperature: double.parse(_tempController.text),
        humidity: double.parse(_humidityController.text),
        soilMoisture: double.parse(_moistureController.text),
        soilType: _selectedSoilType!,
        cropType: _selectedCropType!,
        nitrogen: double.parse(_nitrogenController.text),
        potassium: double.parse(_potassiumController.text),
        phosphorous: double.parse(_phosphorousController.text),
      );

      Provider.of<FertilizerProvider>(context, listen: false).recommendFertilizer(req);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fertilizerProvider = Provider.of<FertilizerProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fertilizer Recommendation'),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.fertilizerRecommend),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Optimal Fertilizer Advice',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Get precise fertilizer recommendations based on soil type, crop requirements, and nutrient deficiencies.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Soil Report Intelligence Autofill Card
            SoilReportAutofillCard(
              featureName: 'Fertilizer Advice',
              onAutofill: _autofillFromSoilReport,
            ),

            if (fertilizerProvider.result != null) ...[
              ResultCard(
                title: 'Recommended Fertilizer',
                icon: Icons.science,
                onReset: () => fertilizerProvider.reset(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => UrlLauncherUtil.launchEcommerceUrl(
                        context,
                        fertilizerProvider.result!.buyLink,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(50),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'OPTIMAL SOIL NUTRIENT SOLUTION',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              fertilizerProvider.result!.recommendedFertilizer,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              fertilizerProvider.result!.productName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white70),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shopping_cart, color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Amazon Direct Store Search',
                                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.open_in_new, color: Colors.white, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Direct Product Purchase Action Card
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
                                child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFFD67700), size: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fertilizerProvider.result!.productName,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Search Query: "${fertilizerProvider.result!.amazonSearchQuery}"',
                                      style: TextStyle(fontSize: 12, color: Colors.amber[900], fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            fertilizerProvider.result!.productDescription,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                          ),
                          const SizedBox(height: 14),

                          // Primary: Direct Amazon Search
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => UrlLauncherUtil.launchAmazonSearch(
                                context,
                                fertilizerProvider.result!.amazonSearchQuery,
                              ),
                              icon: const Icon(Icons.shopping_cart, size: 19),
                              label: Text('Buy ${fertilizerProvider.result!.recommendedFertilizer} on Amazon'),
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

                          // Secondary: Official Agricultural Portal (with safe Amazon fallback)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => UrlLauncherUtil.launchEcommerceUrl(
                                context,
                                fertilizerProvider.result!.buyLink,
                                fallbackSearchQuery: fertilizerProvider.result!.amazonSearchQuery,
                              ),
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

                    const Text(
                      'Application Guidance:',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    _buildGuidelineItem('Apply in split doses during early morning or late evening.'),
                    _buildGuidelineItem('Ensure soil moisture is maintained before applying fertilizer.'),
                    _buildGuidelineItem('Combine with organic compost for enhanced soil structure.'),
                  ],
                ),
              ),

            ] else ...[
              CustomCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomDropdown<String>(
                        label: 'Soil Type',
                        value: _selectedSoilType,
                        items: AppConstants.soilTypes,
                        itemLabelBuilder: (item) => item,
                        onChanged: (val) => setState(() => _selectedSoilType = val),
                      ),
                      const SizedBox(height: 14),
                      CustomDropdown<String>(
                        label: 'Crop Type',
                        value: _selectedCropType,
                        items: AppConstants.cropTypes,
                        itemLabelBuilder: (item) => item,
                        onChanged: (val) => setState(() => _selectedCropType = val),
                      ),
                      const Divider(height: 32),
                      CustomTextField(
                        controller: _tempController,
                        label: 'Temperature',
                        suffixText: '°C',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validateTemperature,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _humidityController,
                        label: 'Humidity',
                        suffixText: '%',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validateHumidity,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _moistureController,
                        label: 'Soil Moisture',
                        suffixText: '%',
                        keyboardType: TextInputType.number,
                        validator: (v) => FormValidators.validateRange(v, 'Soil Moisture', 0, 100, '%'),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _nitrogenController,
                        label: 'Nitrogen (N)',
                        suffixText: 'kg/ha',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validateNitrogen,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _potassiumController,
                        label: 'Potassium (K)',
                        suffixText: 'kg/ha',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validatePotassium,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _phosphorousController,
                        label: 'Phosphorous (P)',
                        suffixText: 'kg/ha',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validatePhosphorus,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Get Fertilizer Advice',
                        icon: Icons.science,
                        isLoading: fertilizerProvider.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
