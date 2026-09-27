import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/result_card.dart';
import '../../data/models/crop_recommendation_model.dart';
import '../../providers/crop_provider.dart';
import '../../providers/soil_report_provider.dart';
import '../../core/widgets/soil_report_autofill_card.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nitrogenController = TextEditingController(text: '90');
  final _phosphorusController = TextEditingController(text: '42');
  final _potassiumController = TextEditingController(text: '43');
  final _temperatureController = TextEditingController(text: '20.8');
  final _humidityController = TextEditingController(text: '82');
  final _phController = TextEditingController(text: '6.5');
  final _rainfallController = TextEditingController(text: '202');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final soilProvider = Provider.of<SoilReportProvider>(context, listen: false);
      if (soilProvider.hasSoilData) {
        _autofillFromSoilReport();
      }
    });
  }

  void _autofillFromSoilReport() {
    final soilProvider = Provider.of<SoilReportProvider>(context, listen: false);
    if (soilProvider.nitrogen != null) {
      _nitrogenController.text = soilProvider.nitrogen!.toStringAsFixed(0);
    }
    if (soilProvider.phosphorus != null) {
      _phosphorusController.text = soilProvider.phosphorus!.toStringAsFixed(1);
    }
    if (soilProvider.potassium != null) {
      _potassiumController.text = soilProvider.potassium!.toStringAsFixed(0);
    }
    if (soilProvider.ph != null) {
      _phController.text = soilProvider.ph!.toStringAsFixed(1);
    }
    if (soilProvider.temperature != null) {
      _temperatureController.text = soilProvider.temperature!.toStringAsFixed(1);
    }
    if (soilProvider.humidity != null) {
      _humidityController.text = soilProvider.humidity!.toStringAsFixed(0);
    }
    if (soilProvider.rainfall != null) {
      _rainfallController.text = soilProvider.rainfall!.toStringAsFixed(0);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    _temperatureController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final req = CropRecommendationRequest(
        nitrogen: double.parse(_nitrogenController.text),
        phosphorus: double.parse(_phosphorusController.text),
        potassium: double.parse(_potassiumController.text),
        temperature: double.parse(_temperatureController.text),
        humidity: double.parse(_humidityController.text),
        phValue: double.parse(_phController.text),
        rainfall: double.parse(_rainfallController.text),
      );

      Provider.of<CropProvider>(context, listen: false).recommendCrop(req);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropProvider = Provider.of<CropProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.cropRecommend),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommend Best Crops for Your Soil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter soil nutrients and weather conditions below to run our Random Forest ML prediction.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Soil Report Intelligence Autofill Card
            SoilReportAutofillCard(
              featureName: 'Crop Recommendations',
              onAutofill: _autofillFromSoilReport,
            ),

            if (cropProvider.result != null) ...[
              ResultCard(
                title: 'Top Recommended Crops',
                icon: Icons.grass,
                onReset: () => cropProvider.reset(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Based on your soil NPK ratio and local climate parameters, the following crops are predicted to yield the highest harvest:',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ...cropProvider.result!.recommendedCrops.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final cropName = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: idx == 1 ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: idx == 1 ? AppColors.primary : Colors.grey.shade300,
                            width: idx == 1 ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: idx == 1 ? AppColors.primary : Colors.grey.shade600,
                              child: Text(
                                '#$idx',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              cropName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: idx == 1 ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (idx == 1)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'BEST MATCH',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ] else ...[
              CustomCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'Soil Nutrients (NPK)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _nitrogenController,
                        label: 'Nitrogen (N)',
                        hint: 'e.g. 90',
                        suffixText: 'kg/ha',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validateNitrogen,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _phosphorusController,
                        label: 'Phosphorus (P)',
                        hint: 'e.g. 42',
                        suffixText: 'kg/ha',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validatePhosphorus,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _potassiumController,
                        label: 'Potassium (K)',
                        hint: 'e.g. 43',
                        suffixText: 'kg/ha',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validatePotassium,
                      ),
                      const Divider(height: 32),
                      const Text(
                        'Climate & Soil Parameters',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _temperatureController,
                        label: 'Temperature',
                        hint: 'e.g. 20.8',
                        suffixText: '°C',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validateTemperature,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _humidityController,
                        label: 'Humidity',
                        hint: 'e.g. 82',
                        suffixText: '%',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validateHumidity,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _phController,
                        label: 'Soil pH Value',
                        hint: 'e.g. 6.5',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validatePh,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _rainfallController,
                        label: 'Annual Rainfall',
                        hint: 'e.g. 202',
                        suffixText: 'mm',
                        keyboardType: TextInputType.number,
                        validator: FormValidators.validateRainfall,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Predict Recommended Crops',
                        icon: Icons.psychology,
                        isLoading: cropProvider.isLoading,
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
}
