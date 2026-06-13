import 'package:agro_spray/app.dart';
import 'package:agro_spray/core/constants/app_constants.dart';
import 'package:agro_spray/firebase_options.dart';
import 'package:agro_spray/providers/auth_provider.dart';
import 'package:agro_spray/providers/crop_provider.dart';
import 'package:agro_spray/providers/dashboard_provider.dart';
import 'package:agro_spray/providers/profile_provider.dart';
import 'package:agro_spray/providers/recommendation_provider.dart';
import 'package:agro_spray/providers/report_provider.dart';
import 'package:agro_spray/providers/schedule_provider.dart';
import 'package:agro_spray/providers/theme_provider.dart';
import 'package:agro_spray/repositories/auth_repository.dart';
import 'package:agro_spray/repositories/crop_repository.dart';
import 'package:agro_spray/repositories/profile_repository.dart';
import 'package:agro_spray/repositories/recommendation_repository.dart';
import 'package:agro_spray/repositories/report_repository.dart';
import 'package:agro_spray/repositories/schedule_repository.dart';
import 'package:agro_spray/services/firebase_auth_service.dart';
import 'package:agro_spray/services/firestore_service.dart';
import 'package:agro_spray/services/local_storage_service.dart';
import 'package:agro_spray/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localStorageService = LocalStorageService.instance;
  await localStorageService.init();
  await NotificationService.instance.init();

  final firebaseAuthService = FirebaseAuthService();
  final firestoreService = FirestoreService();
  final authRepository = AuthRepository(
    firebaseAuthService: firebaseAuthService,
    firestoreService: firestoreService,
    localStorageService: localStorageService,
  );
  final cropRepository = CropRepository(firestoreService: firestoreService);
  final scheduleRepository = ScheduleRepository(firestoreService: firestoreService);
  final reportRepository = ReportRepository(firestoreService: firestoreService);
  final recommendationRepository = RecommendationRepository(
    firestoreService: firestoreService,
  );
  final profileRepository = ProfileRepository(
    authRepository: authRepository,
    firestoreService: firestoreService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(localStorageService: localStorageService)..loadThemeMode(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository)..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CropProvider>(
          create: (_) => CropProvider(cropRepository: cropRepository),
          update: (_, authProvider, cropProvider) {
            cropProvider!.syncUser(authProvider.user?.uid);
            return cropProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ScheduleProvider>(
          create: (_) => ScheduleProvider(scheduleRepository: scheduleRepository),
          update: (_, authProvider, scheduleProvider) {
            scheduleProvider!.syncUser(authProvider.user?.uid);
            return scheduleProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ReportProvider>(
          create: (_) => ReportProvider(reportRepository: reportRepository),
          update: (_, authProvider, reportProvider) {
            reportProvider!.syncUser(authProvider.user?.uid);
            return reportProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, RecommendationProvider>(
          create: (_) => RecommendationProvider(
            recommendationRepository: recommendationRepository,
          ),
          update: (_, authProvider, recommendationProvider) {
            recommendationProvider!.syncUser(authProvider.user?.uid);
            return recommendationProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(profileRepository: profileRepository),
          update: (_, authProvider, profileProvider) {
            profileProvider!.syncUser(authProvider.user);
            return profileProvider;
          },
        ),
      ],
      child: const AgroSprayApp(),
    ),
  );
}
