import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/models/plant.dart';
import 'package:plantcare/presentation/add_plant_screen/add_plant_screen.dart';
import 'package:plantcare/repositories/plant_repository.dart';
import 'package:plantcare/services/plant_ai_service.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class FakePlantRepository implements PlantRepository {
  final List<Plant> plants = [];

  @override
  Stream<List<Plant>> getPlants() => Stream.value(List.of(plants));

  @override
  Future<void> addPlant(Plant plant) async {
    plants.add(plant);
  }

  @override
  Future<void> updatePlant(String plantId, Map<String, dynamic> data) async {}

  @override
  Future<void> deletePlant(String plantId) async {}

  @override
  Future<void> addCareEvent(String plantId, Map<String, dynamic> event) async {}

  @override
  Future<void> addHealthLog(String plantId, Map<String, dynamic> log) async {}
}

class FakePlantAiService implements PlantAiService {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> chatAboutPlant(ChatRequest request) async => 'Stub reply';

  @override
  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request) async =>
      throw UnsupportedError('FakePlantAiService does not diagnose');

  @override
  Future<ScheduleSuggestion> suggestWateringSchedule(
    ScheduleRequest request,
  ) async {
    throw UnsupportedError('FakePlantAiService does not schedule');
  }

  @override
  Future<String> reminderTextFor(ReminderTextRequest request) async {
    throw UnsupportedError('FakePlantAiService does not remind');
  }

  @override
  Future<HealthLogSummary> summarizeHealthLogs(SummaryRequest request) async {
    throw UnsupportedError('FakePlantAiService does not summarize');
  }
}

Map<String, dynamic> identificationArgs() => {
      'id': 1,
      'name': 'Guinea fowl Aloe',
      'scientificName': 'Aristaloe aristata (Haw.) Boatwr.',
      'confidence': 0.46,
      'careDifficulty': 'Medium',
      'wateringFrequency': 'Weekly',
      'image': 'https://images.example.com/aloe.jpg',
      'description': 'A rosette-forming aloe.',
      'lightRequirement': 'Bright indirect light',
      'humidity': 'Medium to high',
    };

Widget wrapScreen(FakePlantRepository repository) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: SizedBox()),
        routes: {
          '/add-plant-screen': (_) =>
              AddPlantScreen(repository: repository),
        },
      );
    },
  );
}

Future<void> usePhoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Future<void> pushWizard(WidgetTester tester, FakePlantRepository repo) async {
  await tester.pumpWidget(wrapScreen(repo));
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  navigator.pushNamed('/add-plant-screen', arguments: identificationArgs());
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
      'PlantNet identification args land on Review & Save prefilled',
      (tester) async {
    await usePhoneViewport(tester);
    final repo = FakePlantRepository();
    await pushWizard(tester, repo);

    expect(find.text('5 of 5: Review & Save'), findsOneWidget);
    expect(find.text('Guinea fowl Aloe'), findsOneWidget);
    expect(find.text('Aristaloe aristata (Haw.) Boatwr.'), findsOneWidget);
  });

  testWidgets('Weekly watering maps to a 7-day schedule on Review & Save',
      (tester) async {
    await usePhoneViewport(tester);
    final repo = FakePlantRepository();
    await pushWizard(tester, repo);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('4 of 5: Care Schedule'), findsOneWidget);
    expect(find.textContaining('Frequency: Weekly'), findsOneWidget);
  });

  testWidgets('saving a prefilled identified plant persists via repository',
      (tester) async {
    await usePhoneViewport(tester);
    final repo = FakePlantRepository();
    await pushWizard(tester, repo);

    await tester.tap(find.text('Save Plant'));
    await tester.pumpAndSettle();

    expect(repo.plants, hasLength(1));
    expect(repo.plants.single.name, 'Guinea fowl Aloe');
    expect(repo.plants.single.species, 'Aristaloe aristata (Haw.) Boatwr.');
    expect(find.text('Plant Added!'), findsOneWidget);
  });
}
