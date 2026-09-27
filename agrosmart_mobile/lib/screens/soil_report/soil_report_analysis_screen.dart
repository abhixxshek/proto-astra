import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/soil_report_provider.dart';
import '../../data/models/soil_report_model.dart';
import '../../core/utils/url_launcher_util.dart';
import '../../core/widgets/app_drawer.dart';
import '../../app/routes/app_routes.dart';

class SoilReportAnalysisScreen extends StatefulWidget {
  const SoilReportAnalysisScreen({super.key});

  @override
  State<SoilReportAnalysisScreen> createState() => _SoilReportAnalysisScreenState();
}

class _SoilReportAnalysisScreenState extends State<SoilReportAnalysisScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _categoryFilterIndex = 0;

  final List<String> _categoryTabs = [
    'All',
    'Macronutrients (NPK)',
    'Soil Chemistry',
    'Micronutrients',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SoilReportProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soil Report Intelligence',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            ),
            Text(
              'AI Agronomic PDF Extraction',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (provider.currentStep != SoilReportStep.upload)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'New Report',
              onPressed: () => provider.reset(),
            ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.soilReport),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(provider.currentStep),
            if (provider.errorMessage != null) _buildErrorBanner(provider),
            Expanded(
              child: provider.isLoading
                  ? _buildLoadingView(provider.loadingMessage)
                  : _buildStepContent(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(SoilReportProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Color(0xFFC62828), fontSize: 12, height: 1.3),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Color(0xFFC62828)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => provider.clearError(),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MODERN STEP PROGRESS BAR
  // --------------------------------------------------------------------------
  Widget _buildProgressIndicator(SoilReportStep currentStep) {
    final steps = [
      {'title': 'Upload', 'icon': Icons.upload_file_rounded},
      {'title': 'Verify', 'icon': Icons.checklist_rounded},
      {'title': 'AI Results', 'icon': Icons.psychology_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final prevStepIndex = (index - 1) ~/ 2;
            final isDone = currentStep.index > prevStepIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isDone ? const Color(0xFF2E7D32) : Colors.grey.shade300,
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = currentStep.index == stepIndex;
          final isDone = currentStep.index > stepIndex;
          final color = isDone
              ? const Color(0xFF2E7D32)
              : (isActive ? const Color(0xFF1B5E20) : Colors.grey.shade400);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? const Color(0xFF2E7D32)
                      : (isActive ? const Color(0xFFE8F5E9) : Colors.grey.shade100),
                  border: Border.all(
                    color: isActive ? const Color(0xFF1B5E20) : color,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Icon(steps[stepIndex]['icon'] as IconData, size: 13, color: color),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                steps[stepIndex]['title'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive || isDone ? FontWeight.bold : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLoadingView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF2E7D32)),
            const SizedBox(height: 24),
            Text(
              message.isNotEmpty ? message : 'Processing...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Extracting soil parameters and normalizing units...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(SoilReportProvider provider) {
    switch (provider.currentStep) {
      case SoilReportStep.upload:
        return _buildUploadStage(provider);
      case SoilReportStep.reviewParameters:
        return _buildReviewParametersStage(provider);
      case SoilReportStep.analysisResults:
        return _buildCombinedIntelligenceStage(provider);
    }
  }

  // --------------------------------------------------------------------------
  // STAGE 1: CLEAN UPLOAD STAGE
  // --------------------------------------------------------------------------
  Widget _buildUploadStage(SoilReportProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.document_scanner_rounded, size: 28, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Soil Health Intelligence',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Upload your soil test card (PDF) to get automated Crop, Yield, and Fertilizer recommendations.',
                        style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary Upload Action Card
          InkWell(
            onTap: () => provider.pickAndUploadPdf(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.35), width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.upload_file_rounded, size: 34, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Soil Report PDF',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Supports ICAR Soil Health Cards & Lab PDFs',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Divider with "OR"
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 16),

          // Sample Demo Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.science_outlined, color: Color(0xFF2E7D32), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Don\'t have a PDF right now?',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Try with a realistic ICAR sample card.',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => provider.loadSampleDemoReport(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Try Demo', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STAGE 2: CLEAN, UNCLUTTERED PARAMETER VERIFICATION
  // --------------------------------------------------------------------------
  Widget _buildReviewParametersStage(SoilReportProvider provider) {
    final uploadData = provider.uploadData;
    if (uploadData == null) return const SizedBox();

    final params = uploadData.parameters;
    final extractedCount = params.values.where((p) => p.normalizedValue != null).length;
    final totalCount = params.length;

    // Filter keys according to active category tab
    List<String> visibleKeys;
    switch (_categoryFilterIndex) {
      case 1:
        visibleKeys = ['nitrogen', 'phosphorus', 'potassium'];
        break;
      case 2:
        visibleKeys = ['ph', 'electrical_conductivity', 'organic_carbon', 'soil_moisture'];
        break;
      case 3:
        visibleKeys = ['zinc', 'iron', 'boron', 'copper', 'manganese', 'sulfur', 'calcium', 'magnesium'];
        break;
      case 0:
      default:
        visibleKeys = [
          'nitrogen', 'phosphorus', 'potassium',
          'ph', 'electrical_conductivity', 'organic_carbon',
          'zinc', 'iron', 'boron', 'copper', 'manganese', 'sulfur',
          'soil_type', 'soil_texture', 'soil_moisture',
          'calcium', 'magnesium',
        ];
        break;
    }

    final activeItems = visibleKeys
        .where((k) => params.containsKey(k))
        .map((k) => params[k]!)
        .toList();

    return Column(
      children: [
        // Summary Header
        Container(
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uploadData.originalFilename,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$extractedCount of $totalCount parameters detected • Tap any row to edit',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: List.generate(_categoryTabs.length, (idx) {
              final isSelected = _categoryFilterIndex == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(_categoryTabs[idx], style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2E7D32),
                  backgroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                  onSelected: (selected) {
                    if (selected) setState(() => _categoryFilterIndex = idx);
                  },
                ),
              );
            }),
          ),
        ),

        // Clean Parameter Rows List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: activeItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final item = activeItems[index];
              final hasVal = item.normalizedValue != null;

              return InkWell(
                onTap: () => _showEditParameterDialog(context, provider, item),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: hasVal ? Colors.grey.shade200 : Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasVal ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 16,
                        color: hasVal ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.displayName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasVal ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hasVal ? '${item.normalizedValue} ${item.normalizedUnit}' : '+ Add Value',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: hasVal ? const Color(0xFF1B5E20) : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_outlined, size: 15, color: Color(0xFF2E7D32)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => provider.confirmAndRunIntelligence(),
              icon: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Confirm Profile & Run AI Prediction',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditParameterDialog(BuildContext context, SoilReportProvider provider, SoilParameterItem item) {
    final controller = TextEditingController(text: item.normalizedValue?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${item.displayName}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Standard Unit: ${item.normalizedUnit}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Verified Value',
                suffixText: item.normalizedUnit,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final numVal = double.tryParse(text);
                provider.updateParameterValue(item.key, numVal ?? text);
              } else {
                provider.updateParameterValue(item.key, null);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            child: const Text('Save & Verify', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STAGE 3: CLEAN COMBINED AI INTELLIGENCE DASHBOARD
  // --------------------------------------------------------------------------
  Widget _buildCombinedIntelligenceStage(SoilReportProvider provider) {
    final result = provider.analysisResult;
    if (result == null) return const SizedBox();

    return Column(
      children: [
        // Provenance Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFE8F5E9),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Profile: pH ${result.soilHealthSummary.phValue ?? "—"} (${result.soilHealthSummary.phStatus}) • Top: ${result.topCrop}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                ),
              ),
            ],
          ),
        ),

        // Tab Navigation
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: const Color(0xFF1B5E20),
            unselectedLabelColor: Colors.black54,
            indicatorColor: const Color(0xFF2E7D32),
            indicatorWeight: 3,
            labelPadding: EdgeInsets.zero,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(text: 'Crops'),
              Tab(text: 'Yield'),
              Tab(text: 'Fertilizer'),
              Tab(text: 'Soil Health'),
            ],
          ),
        ),

        // Tabs Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCropSuitabilityTab(provider, result.cropCandidates),
              _buildYieldPredictionTab(provider, result.yieldPrediction),
              _buildFertilizerTab(provider, result.fertilizerPrescription, result.soilHealthSummary.deficiencies),
              _buildSoilHealthTab(result.soilHealthSummary, result.weatherConsiderations),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 1: CROPS
  Widget _buildCropSuitabilityTab(SoilReportProvider provider, List<CropCandidate> candidates) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final crop = candidates[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: const Color(0xFF2E7D32),
                        child: Text('${crop.rank}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Text(crop.cropName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${crop.suitabilityScore.toStringAsFixed(0)}% Match',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(crop.reasons, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3)),
              if (crop.limitations.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('⚠️ ${crop.limitations}', style: TextStyle(fontSize: 11, color: Colors.brown.shade700)),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.setTargetPreselectedCrop(crop.cropName);
                      Navigator.pushNamed(context, AppRoutes.yieldPredict);
                    },
                    icon: const Icon(Icons.show_chart, size: 13, color: Color(0xFF2E7D32)),
                    label: const Text('Forecast Yield', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32))),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: Color(0xFF81C784)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.setTargetPreselectedCrop(crop.cropName);
                      Navigator.pushNamed(context, AppRoutes.fertilizerRecommend);
                    },
                    icon: const Icon(Icons.science_outlined, size: 13, color: Color(0xFF2E7D32)),
                    label: const Text('Fertilizer Plan', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32))),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                      side: const BorderSide(color: Color(0xFF81C784)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 2: YIELD
  Widget _buildYieldPredictionTab(SoilReportProvider provider, YieldPredictionResult yieldResult) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target Crop: ${yieldResult.crop}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                      const SizedBox(height: 4),
                      Text(
                        '${yieldResult.predictedYieldTonnesHa.toStringAsFixed(2)} Tonnes / ha',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                      ),
                      Text('(${yieldResult.predictedYieldHgHa.toStringAsFixed(0)} hg/ha)',
                          style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.agriculture_rounded, size: 44, color: Color(0xFF2E7D32)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Contributing Factors & Soil Inputs:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          ...yieldResult.keyInfluencingFactors.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text('• $f', style: const TextStyle(fontSize: 12, color: Colors.black87)),
              )),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              provider.setTargetPreselectedCrop(yieldResult.crop);
              Navigator.pushNamed(context, AppRoutes.yieldPredict);
            },
            icon: const Icon(Icons.show_chart, color: Color(0xFF2E7D32), size: 16),
            label: const Text(
              'Open in Yield Predictor with this Data',
              style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: const BorderSide(color: Color(0xFF81C784)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: FERTILIZER & DEFICIENCIES
  Widget _buildFertilizerTab(SoilReportProvider provider, FertilizerPrescription fert, List<NutrientDeficiency> defs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Recommended: ${fert.recommendedFertilizer}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.brown.shade900),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => UrlLauncherUtil.launchAmazonSearch(context, fert.amazonSearchQuery),
                      icon: const Icon(Icons.shopping_cart, size: 14, color: Colors.white),
                      label: const Text('Amazon', style: TextStyle(fontSize: 11, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9900),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(60, 30),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(fert.dosageGuidance, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3)),
                const SizedBox(height: 6),
                Text('⚠️ ${fert.cautions}', style: TextStyle(fontSize: 11, color: Colors.brown.shade700)),
              ],
            ),
          ),
          if (defs.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Specific Nutrient Deficiencies:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            ...defs.map((d) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(d.nutrient,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                          ),
                          ElevatedButton(
                            onPressed: () => UrlLauncherUtil.launchAmazonSearch(context, d.amazonQuery),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9900),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: const Size(60, 24),
                              elevation: 0,
                            ),
                            child: const Text('Buy on Amazon', style: TextStyle(fontSize: 10, color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Current: ${d.level}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      Text('Remedy: ${d.product}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              provider.setTargetPreselectedCrop(fert.targetCrop);
              Navigator.pushNamed(context, AppRoutes.fertilizerRecommend);
            },
            icon: const Icon(Icons.science_outlined, color: Color(0xFF2E7D32), size: 16),
            label: const Text(
              'Open in Fertilizer Advisory with this Data',
              style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: const BorderSide(color: Color(0xFF81C784)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 4: SOIL HEALTH
  Widget _buildSoilHealthTab(SoilHealthSummary health, WeatherConsiderations weather) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildHealthTile(
                  'Soil Reaction (pH)',
                  health.phValue != null ? '${health.phValue}' : '—',
                  health.phStatus,
                  health.phStatus.contains('Optimal') ? Colors.green : Colors.amber.shade800,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHealthTile(
                  'Nitrogen (N)',
                  health.nitrogenValue != null ? '${health.nitrogenValue?.toStringAsFixed(0)} kg/ha' : '—',
                  health.nitrogenStatus,
                  health.nitrogenStatus == 'Low' ? Colors.red.shade700 : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildHealthTile(
                  'Phosphorus (P)',
                  health.phosphorusValue != null ? '${health.phosphorusValue?.toStringAsFixed(1)} kg/ha' : '—',
                  health.phosphorusStatus,
                  health.phosphorusStatus == 'Low' ? Colors.red.shade700 : Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHealthTile(
                  'Potassium (K)',
                  health.potassiumValue != null ? '${health.potassiumValue?.toStringAsFixed(0)} kg/ha' : '—',
                  health.potassiumStatus,
                  health.potassiumStatus == 'Low' ? Colors.red.shade700 : Colors.green,
                ),
              ),
            ],
          ),
          if (health.phAlert != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 ${health.phAlert!} ${health.phAmendment ?? ""}',
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weather & Moisture Context',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(
                  'Temp: ${weather.temperature} | Humidity: ${weather.humidity} | Rainfall: ${weather.rainfall}',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTile(String label, String value, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
        ],
      ),
    );
  }
}
