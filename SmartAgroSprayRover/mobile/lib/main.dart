import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SmartAgroSprayApp());
}

class SmartAgroSprayApp extends StatelessWidget {
  const SmartAgroSprayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: Consumer<AppStateProvider>(
        builder: (context, state, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart AgroSpray Rover',
            theme: ThemeData(primarySwatch: Colors.green),
            home: state.isLoggedIn ? const DashboardScreen() : const LoginScreen(),
          );
        },
      ),
    );
  }
}
