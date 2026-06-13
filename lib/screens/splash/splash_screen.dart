import 'package:agro_spray/core/routes/app_routes.dart';
import 'package:agro_spray/providers/auth_provider.dart';
import 'package:agro_spray/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) {
      return;
    }
    final isLoggedIn = context.read<AuthProvider>().isAuthenticated;
    Navigator.of(context).pushReplacementNamed(isLoggedIn ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.primaryContainer, colorScheme.surface, colorScheme.secondaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: AgroSprayLogo(size: 96),
        ),
      ),
    );
  }
}
