import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_dropdown.dart';
import '../../data/models/analysis_model.dart';
import '../../providers/analysis_provider.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? _selectedState;
  int _selectedYear = 2022;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AnalysisProvider>(context, listen: false);
      provider.loadStates().then((_) {
        if (mounted && provider.states.isNotEmpty) {
          setState(() {
            _selectedState = provider.states[0];
          });
          provider.fetchAnalysis(provider.states[0], _selectedYear);
        }
      });
    });
  }

  void _fetch() {
    if (_selectedState != null) {
      Provider.of<AnalysisProvider>(context, listen: false)
          .fetchAnalysis(_selectedState!, _selectedYear);
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisProvider = Provider.of<AnalysisProvider>(context);
    final years = List<int>.generate(10, (i) => 2015 + i);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agricultural Analytics'),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.analysis),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'State-Wise Agricultural Data Analysis',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Interactive visualizations for production costs, cultivation area distribution, and rainfall impact.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            // Selector Card
            CustomCard(
              child: Column(
                children: [
                  CustomDropdown<String>(
                    label: 'State / Region',
                    value: _selectedState,
                    items: analysisProvider.states,
                    itemLabelBuilder: (item) => item,
                    onChanged: (val) => setState(() => _selectedState = val),
                  ),
                  const SizedBox(height: 14),
                  CustomDropdown<int>(
                    label: 'Analysis Year',
                    value: _selectedYear,
                    items: years,
                    itemLabelBuilder: (item) => '$item',
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedYear = val);
                    },
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    text: 'Generate Analytics Charts',
                    icon: Icons.bar_chart,
                    isLoading: analysisProvider.isLoading,
                    onPressed: _fetch,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (analysisProvider.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            ] else if (analysisProvider.analysisResult != null) ...[
              _buildChartCard(
                title: 'Cost of Production per Hectare (₹)',
                subtitle: 'Comparison across crop varieties in ${_selectedState ?? ''}',
                child: SizedBox(
                  height: 220,
                  child: BarChart(
                    _buildCostBarChartData(analysisProvider.analysisResult!.data),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _buildChartCard(
                title: 'Cultivation Area Distribution (%)',
                subtitle: 'Hectares allocated per crop type',
                child: SizedBox(
                  height: 220,
                  child: PieChart(
                    _buildPieChartData(analysisProvider.analysisResult!.data),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _buildChartCard(
                title: 'Rainfall Impact (mm)',
                subtitle: 'Precipitation received by crop during harvest',
                child: SizedBox(
                  height: 220,
                  child: BarChart(
                    _buildRainfallBarChartData(analysisProvider.analysisResult!.data),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  BarChartData _buildCostBarChartData(List<CropAnalysisDataPoint> data) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (data.map((e) => e.costOfProduction).reduce((a, b) => a > b ? a : b) * 1.2),
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, meta) {
              int idx = val.toInt();
              if (idx >= 0 && idx < data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[idx].cropType,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: data.asMap().entries.map((e) {
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value.costOfProduction,
              color: AppColors.primary,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }).toList(),
    );
  }

  PieChartData _buildPieChartData(List<CropAnalysisDataPoint> data) {
    final totalArea = data.fold<double>(0, (sum, item) => sum + item.cultivationArea);
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      Colors.purple,
      Colors.blue,
    ];

    return PieChartData(
      sectionsSpace: 3,
      centerSpaceRadius: 35,
      sections: data.asMap().entries.map((e) {
        final percentage = (e.value.cultivationArea / totalArea) * 100;
        final color = colors[e.key % colors.length];
        return PieChartSectionData(
          color: color,
          value: e.value.cultivationArea,
          title: '${e.value.cropType}\n${percentage.toStringAsFixed(1)}%',
          radius: 55,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }).toList(),
    );
  }

  BarChartData _buildRainfallBarChartData(List<CropAnalysisDataPoint> data) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: (data.map((e) => e.rainfallMm).reduce((a, b) => a > b ? a : b) * 1.2),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, meta) {
              int idx = val.toInt();
              if (idx >= 0 && idx < data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[idx].cropType,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: data.asMap().entries.map((e) {
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value.rainfallMm,
              color: Colors.teal.shade600,
              width: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }).toList(),
    );
  }
}
