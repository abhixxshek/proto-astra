import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/weather_provider.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  final _cityController = TextEditingController(text: 'Delhi');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchForecast('Delhi');
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _search() {
    final city = _cityController.text.trim();
    if (city.isNotEmpty) {
      Provider.of<WeatherProvider>(context, listen: false).fetchForecast(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Weather & Spray Advice'),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.weatherForecast),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agro-Weather Forecast',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              '3-day weather forecast with automated rain detection to optimize fertilizer application timing.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            // Search Bar Card
            CustomCard(
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'Target City / Location',
                      hint: 'e.g. Delhi, Mumbai, Punjab',
                      prefixIcon: Icons.location_city,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: CustomButton(
                      text: 'Search',
                      width: 90,
                      isLoading: weatherProvider.isLoading,
                      onPressed: _search,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (weatherProvider.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            ] else if (weatherProvider.errorMessage != null) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    weatherProvider.errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 16),
                  ),
                ),
              )
            ] else if (weatherProvider.forecast.isNotEmpty) ...[
              Text(
                'Forecast for ${weatherProvider.currentCity}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              ...weatherProvider.forecast.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                item.rainfallExpected ? Icons.grain : Icons.wb_sunny,
                                color: item.rainfallExpected ? Colors.blue : Colors.orange,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item.dateTime,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.temperature}°C',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Condition: ${item.weather}', style: const TextStyle(fontSize: 14)),
                          const Spacer(),
                          Text('Humidity: ${item.humidity}%', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Fertilizer Application Advice Highlight Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: item.rainfallExpected
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: item.rainfallExpected
                                ? Colors.red.shade300
                                : Colors.green.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.rainfallExpected ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              color: item.rainfallExpected ? Colors.red.shade700 : Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.rainfallExpected
                                    ? 'Rainfall expected. Postpone fertilizer application to prevent nutrient runoff.'
                                    : 'No rainfall expected. Safe window for fertilizer & pesticide application.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: item.rainfallExpected ? Colors.red.shade800 : Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
