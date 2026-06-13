import 'package:agro_spray/screens/auth/forgot_password_screen.dart';
import 'package:agro_spray/screens/auth/login_screen.dart';
import 'package:agro_spray/screens/auth/register_screen.dart';
import 'package:agro_spray/screens/crop/crop_form_screen.dart';
import 'package:agro_spray/screens/crop/crop_history_screen.dart';
import 'package:agro_spray/screens/home/home_shell.dart';
import 'package:agro_spray/screens/profile/profile_screen.dart';
import 'package:agro_spray/screens/reports/reports_screen.dart';
import 'package:agro_spray/screens/recommendation/recommendation_screen.dart';
import 'package:agro_spray/screens/schedule/schedule_form_screen.dart';
import 'package:agro_spray/screens/schedule/schedule_screen.dart';
import 'package:agro_spray/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String cropForm = '/crop-form';
  static const String cropHistory = '/crop-history';
  static const String recommendation = '/recommendation';
  static const String schedule = '/schedule';
  static const String scheduleForm = '/schedule-form';
  static const String reports = '/reports';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case cropForm:
        return MaterialPageRoute(builder: (_) => const CropFormScreen());
      case cropHistory:
        return MaterialPageRoute(builder: (_) => const CropHistoryScreen());
      case recommendation:
        return MaterialPageRoute(builder: (_) => const RecommendationScreen());
      case schedule:
        return MaterialPageRoute(builder: (_) => const ScheduleScreen());
      case scheduleForm:
        return MaterialPageRoute(builder: (_) => const ScheduleFormScreen());
      case reports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
