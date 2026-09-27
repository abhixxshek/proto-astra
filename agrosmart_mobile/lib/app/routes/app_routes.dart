import 'package:flutter/material.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/crop_recommendation/crop_recommendation_screen.dart';
import '../../screens/fertilizer_recommendation/fertilizer_recommendation_screen.dart';
import '../../screens/yield_prediction/yield_prediction_screen.dart';
import '../../screens/weather_forecast/weather_forecast_screen.dart';
import '../../screens/analysis/analysis_screen.dart';
import '../../screens/disease_detection/disease_detection_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/help/help_screen.dart';
import '../../screens/soil_report/soil_report_analysis_screen.dart';
import '../../screens/news/news_screen.dart';
import '../../screens/market/market_prices_screen.dart';
import '../../screens/shopping/shopping_screen.dart';
import '../../screens/shopping/cart_screen.dart';
import '../../screens/chatbot/chatbot_screen.dart';
import '../../screens/tasks/tasks_screen.dart';
import '../../screens/transport/transport_screen.dart';
import '../../screens/knowledge/knowledge_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String cropRecommend = '/crop-recommend';
  static const String fertilizerRecommend = '/fertilizer-recommend';
  static const String yieldPredict = '/yield-predict';
  static const String diseaseDetection = '/disease-detection';
  static const String soilReport = '/soil-report';
  static const String weatherForecast = '/weather-forecast';
  static const String analysis = '/analysis';
  static const String profile = '/profile';
  static const String help = '/help';
  static const String news = '/news';
  static const String marketPrices = '/market-prices';
  static const String shopping = '/shopping';
  static const String cart = '/cart';
  static const String chatbot = '/chatbot';
  static const String tasks = '/tasks';
  static const String transport = '/transport';
  static const String knowledge = '/knowledge';

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
      case cropRecommend:
        return MaterialPageRoute(builder: (_) => const CropRecommendationScreen());
      case fertilizerRecommend:
        return MaterialPageRoute(builder: (_) => const FertilizerRecommendationScreen());
      case yieldPredict:
        return MaterialPageRoute(builder: (_) => const YieldPredictionScreen());
      case diseaseDetection:
        return MaterialPageRoute(builder: (_) => const DiseaseDetectionScreen());
      case soilReport:
        return MaterialPageRoute(builder: (_) => const SoilReportAnalysisScreen());
      case weatherForecast:
        return MaterialPageRoute(builder: (_) => const WeatherForecastScreen());
      case analysis:
        return MaterialPageRoute(builder: (_) => const AnalysisScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      case news:
        return MaterialPageRoute(builder: (_) => const NewsScreen());
      case marketPrices:
        return MaterialPageRoute(builder: (_) => const MarketPricesScreen());
      case shopping:
        return MaterialPageRoute(builder: (_) => const ShoppingScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case chatbot:
        return MaterialPageRoute(builder: (_) => const ChatBotScreen());
      case tasks:
        return MaterialPageRoute(builder: (_) => const TasksScreen());
      case transport:
        return MaterialPageRoute(builder: (_) => const TransportScreen());
      case knowledge:
        return MaterialPageRoute(builder: (_) => const KnowledgeScreen());

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
