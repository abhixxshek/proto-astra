import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_dropdown.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/result_card.dart';
import '../../data/models/yield_prediction_model.dart';
import '../../providers/yield_provider.dart';
import '../../providers/soil_report_provider.dart';
import '../../core/widgets/soil_report_autofill_card.dart';

class YieldPredictionScreen extends StatefulWidget {
  const YieldPredictionScreen({super.key});

  @override
  State<YieldPredictionScreen> createState() => _YieldPredictionScreenState();
}

class _YieldPredictionScreenState extends State<YieldPredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  int _selectedYear = 2013;
  String? _selectedArea;
  String? _selectedItem;

  final _rainfallController = TextEditingController(text: '1485');
  final _pesticidesController = TextEditingController(text: '121');
  final _tempController = TextEditingController(text: '16.3');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<YieldProvider>(context, listen: false);
      provider.fetchOptions().then((_) {
        if (mounted && provider.areas.isNotEmpty && provider.items.isNotEmpty) {
          setState(() {
            _selectedArea = provider.areas.contains('India') ? 'India' : provider.areas[0];
            _selectedItem = provider.items.contains('Wheat') ? 'Wheat' : provider.items[0];
          });
          final soilProvider = Provider.of<SoilReportProvider>(context, listen: false);
          if (soilProvider.hasSoilData || soilProvider.targetPreselectedCrop != null) {
            _autofillFromSoilReport();
          }
        }
      });
    });
  }

  void _autofillFromSoilReport() {
    final soilProvider = Provider.of<SoilReportProvider>(context, listen: false);
    final yieldProvider = Provider.of<YieldProvider>(context, listen: false);

    final targetCrop = soilProvider.targetPreselectedCrop ?? soilProvider.topRecommendedCrop;
    if (targetCrop != null && yieldProvider.items.isNotEmpty) {
      final cName = targetCrop.toLowerCase();
      for (final item in yieldProvider.items) {
        if (item.toLowerCase() == cName || item.toLowerCase().contains(cName) || cName.contains(item.toLowerCase())) {
          _selectedItem = item;
          break;
        }
      }
    }

    if (soilProvider.temperature != null) {
      _tempController.text = soilProvider.temperature!.toStringAsFixed(1);
    }
    if (soilProvider.rainfall != null) {
      _rainfallController.text = soilProvider.rainfall!.toStringAsFixed(0);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _rainfallController.dispose();
    _pesticidesController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedArea != null && _selectedItem != null) {
      final req = YieldPredictionRequest(
        year: _selectedYear,
        averageRainfall: double.parse(_rainfallController.text),
        pesticidesTonnes: double.parse(_pesticidesController.text),
        avgTemp: double.parse(_tempController.text),
        area: _selectedArea!,
        item: _selectedItem!,
      );

      Provider.of<YieldProvider>(context, listen: false).predictYield(req);
    }
  }

  @override
  Widget build(BuildContext context) {
    final yieldProvider = Provider.of<YieldProvider>(context);
    final years = List<int>.generate(25, (i) => 1990 + i);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Crop Yield Prediction'),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.yieldPredict),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forecast Harvest Yield per Hectare',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Utilizes Decision Tree Regressor trained on global agricultural FAO/Kaggle datasets.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Soil Report Intelligence Autofill Card
            SoilReportAutofillCard(
              featureName: 'Yield Predictions',
              onAutofill: _autofillFromSoilReport,
            ),

            if (yieldProvider.result != null) ...[
              ResultCard(
                title: 'Predicted Crop Yield',
                icon: Icons.bar_chart,
                onReset: () => yieldProvider.reset(),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'PREDICTED YIELD OUTPUT',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${yieldProvider.result!.predictedYield.toStringAsFixed(2)} hg/ha',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '≈ ${(yieldProvider.result!.predictedYield / 10000).toStringAsFixed(2)} tonnes per hectare',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailTile('Target Area', _selectedArea ?? ''),
                        _buildDetailTile('Target Crop', _selectedItem ?? ''),
                        _buildDetailTile('Target Year', '$_selectedYear'),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              CustomCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomDropdown<int>(
                        label: 'Year',
                        value: _selectedYear,
                        items: years,
                        itemLabelBuilder: (item) => '$item',
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedYear = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      if (yieldProvider.isFetchingOptions) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        )
                      ] else ...[
                        CustomDropdown<String>(
                          label: 'Country / Region (Area)',
                          value: _selectedArea,
                          items: yieldProvider.areas,
                          itemLabelBuilder: (item) => item,
                          onChanged: (val) => setState(() => _selectedArea = val),
                        ),
                        const SizedBox(height: 14),
                        CustomDropdown<String>(
                          label: 'Crop Item',
                          value: _selectedItem,
                          items: yieldProvider.items,
                          itemLabelBuilder: (item) => item,
                          onChanged: (val) => setState(() => _selectedItem = val),
                        ),
                      ],
                      const Divider(height: 32),
                      CustomTextField(
                        controller: _rainfallController,
                        label: 'Average Annual Rainfall',
                        suffixText: 'mm/yr',
                        keyboardType: TextInputType.number,
                        validator: (v) => FormValidators.validateRange(v, 'Rainfall', 51, 3240, 'mm'),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _pesticidesController,
                        label: 'Pesticides Used',
                        suffixText: 'tonnes',
                        keyboardType: TextInputType.number,
                        validator: (v) => FormValidators.validateRange(v, 'Pesticides', 0.04, 367778, 'tonnes'),
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _tempController,
                        label: 'Average Temperature',
                        suffixText: '°C',
                        keyboardType: TextInputType.number,
                        validator: (v) => FormValidators.validateRange(v, 'Avg Temp', 1.3, 40.65, '°C'),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Calculate Estimated Yield',
                        icon: Icons.show_chart,
                        backgroundColor: const Color(0xFFE65100),
                        isLoading: yieldProvider.isLoading,
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

  Widget _buildDetailTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
