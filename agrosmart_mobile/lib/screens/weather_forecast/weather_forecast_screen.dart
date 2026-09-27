import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import '../../app/theme/app_typography.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/glass_badge.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_text_field.dart';
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
        title: Text(
          'Agro-Weather & Spray Radar',
          style: AppTypography.headline.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.weatherForecast),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hyperlocal Weather Radar',
              style: AppTypography.largeTitle.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '5-day meteorological forecast to determine optimal spray & fertilizer windows.',
              style: AppTypography.footnote.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            // Search Bar Glass Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: GlassTextField(
                      controller: _cityController,
                      label: 'Target Location / City',
                      hintText: 'e.g. Indore, Pune, Punjab',
                      prefixIcon: CupertinoIcons.location_solid,
                      onEditingComplete: _search,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GlassButton(
                    text: 'Search',
                    icon: CupertinoIcons.search,
                    width: 105,
                    isLoading: weatherProvider.isLoading,
                    onPressed: _search,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            if (weatherProvider.isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ] else if (weatherProvider.errorMessage != null) ...[
              GlassCard(
                fillColor: AppColors.errorLight.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_circle_fill, color: AppColors.error, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        weatherProvider.errorMessage!,
                        style: AppTypography.callout.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (weatherProvider.forecast.isNotEmpty) ...[
              // Current Hero Weather Card
              _buildCurrentWeatherHero(weatherProvider),
              const SizedBox(height: 22),

              Text(
                'Upcoming Forecast Windows',
                style: AppTypography.title3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...weatherProvider.forecast.map((item) {
                final isRain = item.rainfallExpected;
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isRain
                                      ? AppColors.iosBlue.withValues(alpha: 0.12)
                                      : AppColors.iosOrange.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isRain ? CupertinoIcons.cloud_rain_fill : CupertinoIcons.sun_max_fill,
                                  color: isRain ? AppColors.iosBlue : AppColors.iosOrange,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.dateTime,
                                    style: AppTypography.callout.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    item.weather,
                                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: AppGlass.borderRadiusPill,
                            ),
                            child: Text(
                              '${item.temperature.toStringAsFixed(1)}°C',
                              style: AppTypography.headline.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Metrics Row
                      Row(
                        children: [
                          const Icon(CupertinoIcons.drop_fill, size: 14, color: AppColors.iosBlue),
                          const SizedBox(width: 4),
                          Text('Humidity: ${item.humidity}%', style: AppTypography.footnote),
                          const Spacer(),
                          GlassBadge(
                            label: isRain ? 'POSTPONE SPRAY' : 'SAFE TO SPRAY',
                            type: isRain ? BadgeType.error : BadgeType.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Recommendation Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isRain ? AppColors.errorLight.withValues(alpha: 0.7) : AppColors.primaryMuted.withValues(alpha: 0.7),
                          borderRadius: AppGlass.borderRadiusSm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isRain ? CupertinoIcons.exclamationmark_triangle_fill : CupertinoIcons.checkmark_circle_fill,
                              color: isRain ? AppColors.error : AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isRain
                                    ? 'Precipitation predicted. Hold fertilizer application to avoid nutrient runoff.'
                                    : 'Ideal meteorological conditions for spraying and foliar feeding.',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isRain ? AppColors.error : AppColors.primaryDark,
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

  Widget _buildCurrentWeatherHero(WeatherProvider provider) {
    final first = provider.forecast.first;
    final isRain = first.rainfallExpected;

    return GlassCard(
      padding: const EdgeInsets.all(22),
      gradient: isRain
          ? const LinearGradient(
              colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : AppColors.primaryGradient,
      shadows: AppGlass.emeraldGlow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.currentCity,
                    style: AppTypography.title2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    first.weather,
                    style: AppTypography.footnote.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              Icon(
                isRain ? CupertinoIcons.cloud_rain_fill : CupertinoIcons.sun_max_fill,
                color: isRain ? Colors.lightBlueAccent : Colors.amber,
                size: 44,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${first.temperature.toStringAsFixed(1)}°C',
            style: AppTypography.largeTitle.copyWith(
              fontSize: 42,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(CupertinoIcons.drop, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                'Humidity ${first.humidity}%',
                style: AppTypography.caption.copyWith(color: Colors.white70),
              ),
              const SizedBox(width: 16),
              const Icon(CupertinoIcons.wind, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                'Agronomic Spray Window',
                style: AppTypography.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
