import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plantcare/models/plant.dart';
import 'package:plantcare/presentation/login_screen/login_screen.dart';
import 'package:plantcare/presentation/my_plants_dashboard/my_plants_dashboard.dart';
import 'package:plantcare/presentation/plant_detail_screen/plant_detail_screen.dart';
import 'package:plantcare/presentation/splash_screen/splash_screen.dart';
import 'package:plantcare/repositories/plant_repository.dart';
import 'package:plantcare/services/notification_service.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class FakePlantRepository extends Fake implements PlantRepository {
  FakePlantRepository(this.plants);

  final List<Plant> plants;

  @override
  Stream<List<Plant>> getPlants() => Stream.value(plants);
}

class MockNotificationService extends Mock
    implements NotificationService {}

Widget wrapApp(Widget home, {Map<String, WidgetBuilder> routes = const {}}) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: home,
        routes: routes,
      );
    },
  );
}

/// The screens are designed for portrait phones; the default 800x600 test
/// viewport makes several of them overflow.
Future<void> usePhoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Plant buildPlant({
  String id = 'plant-1',
  String name = 'Monstera',
  String species = 'Monstera deliciosa',
}) {
  return Plant(
    id: id,
    name: name,
    species: species,
    imageUrl: '',
    status: 'healthy',
    dateAdded: DateTime(2026, 1, 1),
    careSchedule: const {'wateringFrequency': 7},
    photos: const [],
  );
}

void main() {
  setUpAll(() {
    // Keep fonts deterministic: no runtime HTTP font fetching in tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('MyPlantsDashboard', () {
    testWidgets('builds the empty state when the repository has no plants',
        (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(
        wrapApp(
          MyPlantsDashboard(plantRepository: FakePlantRepository(const [])),
        ),
      );
      await tester.pump();

      expect(find.text('Hi Plant Parent !'), findsOneWidget);
      expect(find.text('No plants here yet'), findsOneWidget);
      expect(find.text('My Plants'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('builds and shows a plant card when plants exist',
        (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(
        wrapApp(
          MyPlantsDashboard(
            plantRepository: FakePlantRepository([buildPlant()]),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Monstera'), findsWidgets);
      expect(find.text('No plants here yet'), findsNothing);
      expect(find.text('Popular plants'), findsOneWidget);
    });
  });

  group('LoginScreen', () {
    testWidgets('builds with the brand header', (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapApp(const LoginScreen()));

      expect(find.text('Welcome to PlantCare'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('requires email and password before submitting', (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapApp(const LoginScreen()));

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('rejects a malformed email and a short password',
        (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapApp(const LoginScreen()));

      await tester.enterText(find.byType(TextFormField).at(0), 'nope');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  });

  group('SplashScreen', () {
    testWidgets('builds and hands off to the login screen', (tester) async {
      await usePhoneViewport(tester);
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => null,
      );

      await tester.pumpWidget(
        wrapApp(
          const SplashScreen(),
          routes: {'/login-screen': (_) => const LoginScreen()},
        ),
      );

      expect(find.text('PlantCare'), findsOneWidget);
      expect(find.text('Nurture your green companions'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to PlantCare'), findsOneWidget);
    });
  });

  group('PlantDetailScreen', () {
    testWidgets('builds with the plant arguments', (tester) async {
      await usePhoneViewport(tester);
      final arguments = {
        'id': 'plant-1',
        'name': 'Monstera',
        'species': 'Monstera deliciosa',
        'imageUrl': '',
        'status': 'healthy',
        'lastWatered': null,
        'nextWatering':
            DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'careNotes': null,
        'location': 'Living room',
        'dateAdded': DateTime(2026, 1, 1).toIso8601String(),
        'careSchedule': {'wateringFrequency': 7},
        'photos': <String>[],
      };

      await tester.pumpWidget(wrapApp(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed('/plant-detail-screen', arguments: arguments),
              child: const Text('open'),
            ),
          ),
        ),
        routes: {
          '/plant-detail-screen': (_) => PlantDetailScreen(
                plantRepository: FakePlantRepository(const []),
                notificationService: MockNotificationService(),
              ),
        },
      ));

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Monstera'), findsWidgets);
      expect(find.textContaining('Monstera deliciosa'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}