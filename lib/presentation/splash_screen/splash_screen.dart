import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_export.dart';
import '../../services/notification_service.dart';
import '../../services/firebase_service.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, this.firebaseService}) : super(key: key);

  /// Optional service override; defaults to the shared FirebaseService.
  /// Injectable so the screen can be built and its init flow exercised in
  /// tests without booting Firebase.
  final FirebaseService? firebaseService;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitializing = true;
  String _loadingText = "Preparing your garden...";

  FirebaseService get _firebaseService =>
      widget.firebaseService ?? FirebaseService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setSystemUIOverlay();
  }
  
  Future<void> _initializeNotificationService() async {
    setState(() {
      _loadingText = "Setting up notifications...";
    });
    
    try {
      await NotificationService().initialize();
      print("Notification service initialized successfully");
    } catch (e) {
      print("Failed to initialize notification service: $e");
    }
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
      // Initialize notification service
      await _initializeNotificationService();

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

    // In a real implementation, this would fetch user's plants
    // For now, we just ensure Firebase is ready
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        // Preload user's plant data to make subsequent screens faster
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('plants')
            .limit(10) // Limit to prevent loading too much at once
            .get();
      }
    } catch (e) {
      print("Error loading plant database: $e");
      // Continue with app initialization even if this fails
    }
  }

  Future<void> _checkNotificationPermissions() async {
    setState(() {
      _loadingText = "Checking notifications...";
    });

    // Check notification permissions
    try {
      await _firebaseService.currentUser;
      // Notification permissions were already handled in initialization
    } catch (e) {
      print("Error checking notification permissions: $e");
    }
  }

  Future<void> _prepareCachedData() async {
    setState(() {
      _loadingText = "Preparing your plants...";
    });

    // Prepare any cached data needed for the app
    // This might include common plant care guides, etc.
  }

  Future<void> _syncWeatherData() async {
    setState(() {
      _loadingText = "Syncing weather data...";
    });

    // In a real implementation, this would get weather data
    // based on user's location and plant needs
    try {
      // Placeholder for future weather sync implementation
    } catch (e) {
      print("Error syncing weather data: $e");
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

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    try {
      // Check if user is authenticated
      final user = _firebaseService.currentUser;
      
      String nextRoute;
      if (user == null) {
        // If not authenticated, show login screen
        nextRoute = '/login-screen';
      } else {
        // User is authenticated, check if they have plants
        final userPlants = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('plants')
            .limit(1)
            .get();

        if (userPlants.docs.isEmpty) {
          // User has no plants, go to onboarding flow or add plant screen
          nextRoute = '/onboarding-flow';
        } else {
          // User has plants, go to dashboard
          nextRoute = '/my-plants-dashboard';
        }
      }

      Navigator.pushReplacementNamed(context, nextRoute);
    } catch (e) {
      print("Error determining navigation route: $e");
      // Default to login screen if there's an error
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
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
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: 1.h),

                // Tagline
                Text(
                  "Nurture your green companions",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.surface
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
                      color: Theme.of(context).colorScheme.surface
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          size: 5.w,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          _loadingText,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                            color: Theme.of(context).colorScheme.surface,
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.surface
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
