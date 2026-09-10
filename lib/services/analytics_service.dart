import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logPlantAdded({required String source}) async {
    await _analytics.logEvent(
      name: 'plant_added',
      parameters: {'source': source},
    );
  }

  Future<void> logPlantIdentified({required String species, required double confidence}) async {
    await _analytics.logEvent(
      name: 'plant_identified',
      parameters: {
        'species': species,
        'confidence': confidence,
      },
    );
  }

  Future<void> logCareEvent({required String type, required String plantId}) async {
    await _analytics.logEvent(
      name: 'care_event',
      parameters: {
        'type': type,
        'plant_id': plantId,
      },
    );
  }

  Future<void> logProUpgrade() async {
    await _analytics.logEvent(name: 'pro_upgrade');
  }

  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
