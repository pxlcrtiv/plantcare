import 'package:flutter/material.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/my_plants_dashboard/my_plants_dashboard.dart';
import '../presentation/plant_identification_camera/plant_identification_camera.dart';
import '../presentation/plant_detail_screen/plant_detail_screen.dart';
import '../presentation/add_plant_screen/add_plant_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String onboardingFlow = '/onboarding-flow';
  static const String splashScreen = '/splash-screen';
  static const String myPlantsDashboard = '/my-plants-dashboard';
  static const String plantIdentificationCamera =
      '/plant-identification-camera';
  static const String plantDetailScreen = '/plant-detail-screen';
  static const String addPlantScreen = '/add-plant-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    splashScreen: (context) => const SplashScreen(),
    myPlantsDashboard: (context) => const MyPlantsDashboard(),
    plantIdentificationCamera: (context) => const PlantIdentificationCamera(),
    plantDetailScreen: (context) => const PlantDetailScreen(),
    addPlantScreen: (context) => const AddPlantScreen(),
    // TODO: Add your other routes here
  };
}
