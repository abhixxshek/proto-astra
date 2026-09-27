import 'package:flutter/material.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';

import '../../screens/weather_forecast/weather_forecast_screen.dart';

import '../../screens/disease_detection/disease_detection_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/help/help_screen.dart';
import '../../screens/soil_report/soil_report_analysis_screen.dart';

import '../../screens/market/market_prices_screen.dart';
import '../../screens/shopping/shopping_screen.dart';
import '../../screens/shopping/cart_screen.dart';


import '../../screens/transport/transport_screen.dart';


class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';

  static const String diseaseDetection = '/disease-detection';
  static const String soilReport = '/soil-report';
  static const String weatherForecast = '/weather-forecast';

  static const String profile = '/profile';
  static const String help = '/help';

  static const String marketPrices = '/market-prices';
  static const String shopping = '/shopping';
  static const String cart = '/cart';


  static const String transport = '/transport';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case diseaseDetection:
        return MaterialPageRoute(builder: (_) => const DiseaseDetectionScreen());
      case soilReport:
        return MaterialPageRoute(builder: (_) => const SoilReportAnalysisScreen());
      case weatherForecast:
        return MaterialPageRoute(builder: (_) => const WeatherForecastScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());

      case marketPrices:
        return MaterialPageRoute(builder: (_) => const MarketPricesScreen());
      case shopping:
        return MaterialPageRoute(builder: (_) => const ShoppingScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());


      case transport:
        return MaterialPageRoute(builder: (_) => const TransportScreen());


      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
