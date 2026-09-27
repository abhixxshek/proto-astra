import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/config/api_config.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'providers/auth_provider.dart';

import 'providers/weather_provider.dart';

import 'providers/disease_provider.dart';
import 'providers/soil_report_provider.dart';
import 'providers/language_provider.dart';
import 'providers/shopping_provider.dart';


import 'providers/transport_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.init();
  runApp(const AgroSmartApp());
}

class AgroSmartApp extends StatelessWidget {
  const AgroSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => WeatherProvider()),

        ChangeNotifierProvider(create: (_) => DiseaseProvider()),
        ChangeNotifierProvider(create: (_) => SoilReportProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),


        ChangeNotifierProvider(create: (_) => TransportProvider()),

      ],
      child: MaterialApp(
        title: 'AgroSmart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
