import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitializing = true;
  String _loadingText = "Preparing your garden...";

  // Mock user data for navigation logic
  final Map<String, dynamic> _mockUserData = {
    "isFirstTime": false,
    "hasPlants": true,
    "plantsCount": 5,
    "lastLogin": "2025-07-27",
    "notificationPermission": true,
    "weatherSyncEnabled": true,
  };

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setSystemUIOverlay();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate loading plant database
      await _loadPlantDatabase();

      // Check notification permissions
      await _checkNotificationPermissions();

      // Prepare cached plant data
      await _prepareCachedData();

      // Sync weather information
      await _syncWeatherData();

      // Complete initialization
      setState(() {
        _isInitializing = false;
        _loadingText = "Welcome back!";
      });

      // Navigate after brief delay
      await Future.delayed(const Duration(milliseconds: 800));
      _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors gracefully
      _handleInitializationError();
    }
  }

  Future<void> _loadPlantDatabase() async {
    setState(() {
      _loadingText = "Loading plant database...";
    });

    // Simulate database loading with realistic delay
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _checkNotificationPermissions() async {
    setState(() {
      _loadingText = "Checking notifications...";
    });

    // Simulate permission check
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _prepareCachedData() async {
    setState(() {
      _loadingText = "Preparing your plants...";
    });

    // Simulate cache preparation
    await Future.delayed(const Duration(milliseconds: 700));
  }

  Future<void> _syncWeatherData() async {
    setState(() {
      _loadingText = "Syncing weather data...";
    });

    // Simulate weather sync with timeout handling
    try {
      await Future.delayed(const Duration(milliseconds: 900));
    } catch (e) {
      // Continue without weather data if sync fails
    }
  }

  void _handleInitializationError() {
    setState(() {
      _loadingText = "Starting in offline mode...";
    });

    // Navigate to appropriate screen even if some services fail
    Future.delayed(const Duration(milliseconds: 1000), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Navigation logic based on user state
    String nextRoute;

    if (_mockUserData["isFirstTime"] == true) {
      // First-time users see onboarding
      nextRoute = '/onboarding-flow';
    } else if (_mockUserData["hasPlants"] == false ||
        _mockUserData["plantsCount"] == 0) {
      // Users without plants go to add first plant
      nextRoute = '/add-plant-screen';
    } else {
      // Existing users with plants go to dashboard
      nextRoute = '/my-plants-dashboard';
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GradientBackgroundWidget(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spacer to push content up slightly
                const Spacer(flex: 2),

                // Animated logo
                const AnimatedLogoWidget(),

                SizedBox(height: 4.h),

                // App name
                Text(
                  "PlantCare",
                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: 1.h),

                // Tagline
                Text(
                  "Nurture your green companions",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.8),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(flex: 3),

                // Loading indicator
                if (_isInitializing)
                  LoadingIndicatorWidget(
                    loadingText: _loadingText,
                  )
                else
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          size: 5.w,
                          color: AppTheme.lightTheme.colorScheme.surface,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _loadingText,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(flex: 1),

                // Version info
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Text(
                    "Version 1.0.0",
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
