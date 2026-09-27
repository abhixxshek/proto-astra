import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/url_launcher_util.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/glass_badge.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../data/models/soil_report_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/soil_report_provider.dart';

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
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Soil Report Intelligence',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              'AI Agronomic PDF Extraction',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          if (provider.currentStep != SoilReportStep.upload)
            IconButton(
              icon: const Icon(CupertinoIcons.arrow_counterclockwise, size: 20, color: AppColors.textPrimary),
              tooltip: 'New Report',
              onPressed: () => provider.reset(),
            ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            child: Container(
              margin: const EdgeInsets.only(right: 16, left: 4),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.0),
              ),
              child: Center(
                child: Text(
                  (user?.username.isNotEmpty ?? false) ? user!.username[0].toUpperCase() : 'A',
                  style: AppTypography.callout.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.soilReport),
      body: SafeArea(
        child: Column(
          children: [
            _buildIosStepIndicator(provider.currentStep),
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

  Widget _buildIosStepIndicator(SoilReportStep step) {
    int activeIdx = 0;
    if (step == SoilReportStep.reviewParameters) activeIdx = 1;
    if (step == SoilReportStep.analysisResults) activeIdx = 2;

    final steps = ['Upload PDF', 'Verify Data', 'AI Advisory'];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: AppGlass.borderRadiusPill,
        border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
        boxShadow: AppGlass.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (idx) {
          final isDone = idx < activeIdx;
          final isCurrent = idx == activeIdx;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary
                        : (isDone ? AppColors.primaryLight : Colors.grey.shade200),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(CupertinoIcons.checkmark, size: 13, color: Colors.white)
                        : Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    steps[idx],
                    style: AppTypography.caption.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCurrent ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (idx < steps.length - 1) ...[
                  const SizedBox(width: 4),
                  Icon(CupertinoIcons.chevron_right, size: 10, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorBanner(SoilReportProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withValues(alpha: 0.9),
        borderRadius: AppGlass.borderRadiusMd,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.exclamationmark_circle_fill, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: AppTypography.footnote.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 18, color: AppColors.error),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => provider.clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(String message) {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3.0,
            ),
            const SizedBox(height: 20),
            Text(
              message.isNotEmpty ? message : 'Processing...',
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Running multi-page extraction & validating parameters',
              textAlign: TextAlign.center,
              style: AppTypography.footnote.copyWith(
                color: AppColors.textSecondary,
              ),
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
  // STAGE 1: iOS FROSTED UPLOAD STAGE
  // --------------------------------------------------------------------------
  Widget _buildUploadStage(SoilReportProvider provider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info Callout
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppGlass.borderRadiusMd,
                  ),
                  child: const Icon(CupertinoIcons.doc_text_viewfinder, size: 28, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soil Health Card AI',
                        style: AppTypography.headline.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Upload your laboratory soil test PDF to extract NPK, organic carbon & get automated recommendations.',
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Primary Upload Action Card (Apple-style dropzone)
          GestureDetector(
            onTap: () => provider.pickAndUploadPdf(),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(CupertinoIcons.cloud_upload_fill, size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Select Soil Report PDF',
                    style: AppTypography.title3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Supports multi-page ICAR Soil Health Cards & Lab Reports',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  GlassButton(
                    text: 'Browse Device Files',
                    icon: CupertinoIcons.folder_badge_plus,
                    variant: GlassButtonVariant.primary,
                    onPressed: () => provider.pickAndUploadPdf(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Divider with "OR"
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'OR',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 20),

          // Instant ICAR Demo Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.iosTeal.withValues(alpha: 0.12),
                    borderRadius: AppGlass.borderRadiusSm,
                  ),
                  child: const Icon(CupertinoIcons.lab_flask_solid, color: AppColors.iosTeal, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Don\'t have a PDF right now?',
                        style: AppTypography.callout.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Run with verified ICAR Soil Health Card lab data.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassButton(
                  text: 'Try Demo',
                  variant: GlassButtonVariant.tinted,
                  customColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onPressed: () => provider.loadSampleDemoReport(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STAGE 2: PARAMETER VERIFICATION (iOS Grouped List)
  // --------------------------------------------------------------------------
  Widget _buildReviewParametersStage(SoilReportProvider provider) {
    final uploadData = provider.uploadData;
    if (uploadData == null) return const SizedBox();

    final params = uploadData.parameters;
    final extractedCount = params.values.where((p) => p.normalizedValue != null).length;
    final totalCount = params.length;

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
        // Summary Header Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        uploadData.originalFilename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headline.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$extractedCount of $totalCount parameters detected • Tap row to adjust',
                        style: AppTypography.footnote.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // iOS Segmented Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: List.generate(_categoryTabs.length, (idx) {
              final isSelected = _categoryFilterIndex == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _categoryFilterIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.85),
                      borderRadius: AppGlass.borderRadiusPill,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.glassBorderSubtle,
                        width: 1.0,
                      ),
                      boxShadow: isSelected ? AppGlass.emeraldGlow : AppGlass.softShadow,
                    ),
                    child: Text(
                      _categoryTabs[idx],
                      style: AppTypography.footnote.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Parameter Rows List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: activeItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = activeItems[index];
              final hasVal = item.normalizedValue != null;

              return GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                onTap: () => _showEditParameterDialog(context, provider, item),
                child: Row(
                  children: [
                    Icon(
                      hasVal ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                      size: 18,
                      color: hasVal ? AppColors.primary : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.displayName,
                        style: AppTypography.callout.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GlassBadge(
                      label: hasVal ? '${item.normalizedValue} ${item.normalizedUnit}' : '+ Add Value',
                      type: hasVal ? BadgeType.success : BadgeType.neutral,
                    ),
                    const SizedBox(width: 8),
                    const Icon(CupertinoIcons.pencil, size: 14, color: AppColors.textTertiary),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom Action Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: GlassButton(
            text: 'Confirm Profile & Run AI Prediction',
            icon: CupertinoIcons.sparkles,
            variant: GlassButtonVariant.primary,
            onPressed: () => provider.confirmAndRunIntelligence(),
          ),
        ),
      ],
    );
  }

  void _showEditParameterDialog(BuildContext context, SoilReportProvider provider, SoilParameterItem item) {
    final controller = TextEditingController(text: item.normalizedValue?.toString() ?? '');

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Edit ${item.displayName}', style: AppTypography.title3.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Standard Unit: ${item.normalizedUnit}', style: AppTypography.footnote.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              GlassTextField(
                controller: controller,
                label: 'Verified Value',
                hintText: 'Enter value',
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Center(
                    widthFactor: 1.0,
                    child: Text(
                      item.normalizedUnit,
                      style: AppTypography.callout.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: 'Cancel',
                      variant: GlassButtonVariant.secondary,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      text: 'Save & Verify',
                      variant: GlassButtonVariant.primary,
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // STAGE 3: COMBINED AI ADVISORY RESULTS
  // --------------------------------------------------------------------------
  Widget _buildCombinedIntelligenceStage(SoilReportProvider provider) {
    final result = provider.analysisResult;
    if (result == null) return const SizedBox();

    return Column(
      children: [
        // Provenance Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            fillColor: AppColors.primaryMuted.withValues(alpha: 0.8),
            child: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Profile: pH ${result.soilHealthSummary.phValue ?? "—"} (${result.soilHealthSummary.phStatus}) • Top: ${result.topCrop}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.callout.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // iOS Tab Navigation
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200.withValues(alpha: 0.6),
            borderRadius: AppGlass.borderRadiusPill,
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: AppGlass.borderRadiusPill,
              boxShadow: AppGlass.softShadow,
            ),
            labelStyle: AppTypography.footnote.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTypography.footnote,
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
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: candidates.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final crop = candidates[index];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${crop.rank}',
                            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        crop.cropName,
                        style: AppTypography.title3.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  GlassBadge(
                    label: '${crop.suitabilityScore.toStringAsFixed(0)}% Match',
                    type: BadgeType.success,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                crop.reasons,
                style: AppTypography.bodyMuted.copyWith(color: AppColors.textPrimary),
              ),
              if (crop.limitations.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 13, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        crop.limitations,
                        style: AppTypography.caption.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.setTargetPreselectedCrop(crop.cropName);
                      Navigator.pushNamed(context, AppRoutes.yieldPredict);
                    },
                    icon: const Icon(CupertinoIcons.chart_bar_alt_fill, size: 14, color: AppColors.primary),
                    label: Text('Forecast Yield', style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      side: const BorderSide(color: AppColors.primaryLight),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.setTargetPreselectedCrop(crop.cropName);
                      Navigator.pushNamed(context, AppRoutes.fertilizerRecommend);
                    },
                    icon: const Icon(CupertinoIcons.lab_flask, size: 14, color: AppColors.primary),
                    label: Text('Fertilizer Plan', style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      side: const BorderSide(color: AppColors.primaryLight),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(22),
            gradient: AppColors.primaryGradient,
            shadows: AppGlass.emeraldGlow,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Crop: ${yieldResult.crop}',
                        style: AppTypography.callout.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${yieldResult.predictedYieldTonnesHa.toStringAsFixed(2)} Tonnes / ha',
                        style: AppTypography.largeTitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                      Text(
                        '(${yieldResult.predictedYieldHgHa.toStringAsFixed(0)} hg/ha)',
                        style: AppTypography.footnote.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.chart_bar_alt_fill, size: 36, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Contributing Factors & Soil Inputs:',
            style: AppTypography.headline.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...yieldResult.keyInfluencingFactors.map((f) => GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.check_mark_circled_solid, color: AppColors.primary, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(f, style: AppTypography.footnote.copyWith(color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          GlassButton(
            text: 'Open in Yield Predictor with this Data',
            icon: CupertinoIcons.chart_bar_square_fill,
            variant: GlassButtonVariant.secondary,
            onPressed: () {
              provider.setTargetPreselectedCrop(yieldResult.crop);
              Navigator.pushNamed(context, AppRoutes.yieldPredict);
            },
          ),
        ],
      ),
    );
  }

  // TAB 3: FERTILIZER & DEFICIENCIES
  Widget _buildFertilizerTab(SoilReportProvider provider, FertilizerPrescription fert, List<NutrientDeficiency> defs) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Recommended: ${fert.recommendedFertilizer}',
                        style: AppTypography.headline.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => UrlLauncherUtil.launchAmazonSearch(context, fert.amazonSearchQuery),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9900),
                          borderRadius: AppGlass.borderRadiusPill,
                          boxShadow: AppGlass.softShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(CupertinoIcons.cart_fill, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Amazon',
                              style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  fert.dosageGuidance,
                  style: AppTypography.bodyMuted.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 14, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        fert.cautions,
                        style: AppTypography.caption.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (defs.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Specific Nutrient Deficiencies:',
              style: AppTypography.headline.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...defs.map((d) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              d.nutrient,
                              style: AppTypography.callout.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => UrlLauncherUtil.launchAmazonSearch(context, d.amazonQuery),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9900),
                                borderRadius: AppGlass.borderRadiusPill,
                              ),
                              child: Text(
                                'Buy on Amazon',
                                style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Current: ${d.level}', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text('Remedy: ${d.product}', style: AppTypography.footnote.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // TAB 4: SOIL HEALTH
  Widget _buildSoilHealthTab(SoilHealthSummary summary, WeatherConsiderations weather) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Soil Status Overview', style: AppTypography.headline.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildMetricRow('Soil Reaction (pH)', '${summary.phValue ?? "—"} (${summary.phStatus})'),
                _buildMetricRow('Organic Carbon (OC)', '${summary.ocValue ?? "—"}% (${summary.ocStatus})'),
                _buildMetricRow('Electrical Conductivity (EC)', '${summary.ecValue ?? "—"} dS/m (${summary.ecStatus})'),
                _buildMetricRow('Available Nitrogen (N)', '${summary.nitrogenValue ?? "—"} kg/ha (${summary.nitrogenStatus})'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Agro-Climate Synchronization', style: AppTypography.headline.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildMetricRow('Avg Temperature', weather.temperature),
                _buildMetricRow('Relative Humidity', weather.humidity),
                _buildMetricRow('Annual Rainfall', weather.rainfall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.footnote.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTypography.footnote.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
