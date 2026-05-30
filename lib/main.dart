import 'package:flutter/material.dart';
import 'dart:ui'; // Import helper for PlatformDispatcher
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/material_provider.dart';
import 'providers/doubt_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/game_provider.dart';
import 'providers/group_provider.dart';

import 'screens/admin/admin_home_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/teacher/teacher_home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:studentscomputer/core/notification_service.dart';
import 'screens/auth/welcome_screen.dart'; // Import Welcome Screen
import 'core/ad_service.dart';
import 'screens/onboarding/splash_screen.dart';
import 'core/app_feedback.dart';
import 'widgets/shimmer_loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Robust error handling to prevent app crashes from system/plugin errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("Global Error Caught: $error");
    return true; // Return true to prevent the error from crashing the app
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Notifications
  await NotificationService.init();

  // Initialize AdMob
  await AdService().init();

  // Check Onboarding Status
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => MaterialProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DoubtProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProxyProvider<AuthProvider, GameProvider>(
          create: (context) => GameProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previous) => GameProvider(auth),
        ),
      ],
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool hasSeenOnboarding;
  
  const MyApp({super.key, this.hasSeenOnboarding = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Master',
      scaffoldMessengerKey: AppFeedback.messengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode, // Use ThemeProvider for theme mode
      home: !_isInitialized
          ? AnimatedSplashScreen(
              onInitializationComplete: () => setState(() => _isInitialized = true),
            )
          : (widget.hasSeenOnboarding ? const AuthWrapper() : const OnboardingScreen()),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/user-home': (context) => const UserHomeScreen(),
        '/teacher-home': (context) => const TeacherHomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ShimmerWidget.circular(width: 60, height: 60),
              const SizedBox(height: 16),
              ShimmerWidget.rectangular(height: 16, width: 120),
            ],
          ),
        ),
      );
    }
    
    if (!authProvider.isAuthenticated) {
      return const WelcomeScreen();
    }

    if (authProvider.isAdmin) {
      return const AdminHomeScreen();
    } else if (authProvider.isTeacher) {
      return const TeacherHomeScreen();
    } else {
      return const UserHomeScreen();
    }
  }
}
