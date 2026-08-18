import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plantcare/models/plant.dart';
import 'package:plantcare/presentation/plant_detail_screen/plant_detail_screen.dart';
import 'package:plantcare/providers/plant_ai_service_provider.dart';
import 'package:plantcare/repositories/plant_repository.dart';
import 'package:plantcare/services/notification_service.dart';
import 'package:plantcare/services/plant_ai_service.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class FakePlantAiService implements PlantAiService {
  FakePlantAiService({
    this.available = true,
    this.suggestion,
    this.error,
    this.reminderText = '',
  });

  bool available;
  ScheduleSuggestion? suggestion;
  PlantAiException? error;
  String reminderText;
  int suggestCalls = 0;
  int reminderCalls = 0;
  ScheduleRequest? lastScheduleRequest;
  ReminderTextRequest? lastReminderRequest;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ScheduleSuggestion> suggestWateringSchedule(
    ScheduleRequest request,
  ) async {
    suggestCalls++;
    lastScheduleRequest = request;
    if (error != null) {
      throw error!;
    }
    return suggestion ?? const ScheduleSuggestion(wateringFrequency: 5);
  }

  @override
  Future<String> reminderTextFor(ReminderTextRequest request) async {
    reminderCalls++;
    lastReminderRequest = request;
    if (error != null) {
      throw error!;
    }
    return reminderText;
  }

  @override
  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request) async {
    return const DiagnosisResult(condition: 'Overwatering', severity: 'mild');
  }

  @override
  Future<String> chatAboutPlant(ChatRequest request) async => 'Stub reply';
}

class RecordingPlantRepository extends Fake implements PlantRepository {
  final List<String> updatedIds = [];
  final List<Map<String, dynamic>> updates = [];

  @override
  Future<void> updatePlant(String plantId, Map<String, dynamic> data) async {
    updatedIds.add(plantId);
    updates.add(data);
  }
}

class MockNotificationService extends Mock implements NotificationService {}

Widget wrapDetail(
  Widget home, {
  required PlantAiService service,
  required Map<String, WidgetBuilder> routes,
}) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return PlantAiServiceProvider(
        service: service,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: home,
          routes: routes,
        ),
      );
    },
  );
}

Future<void> usePhoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

Map<String, dynamic> buildArguments() {
  return {
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
}

Future<void> pumpUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> openReminderSheet(
  WidgetTester tester, {
  required RecordingPlantRepository repository,
  required PlantAiService service,
}) async {
  await usePhoneViewport(tester);
  final arguments = buildArguments();
  final notifications = MockNotificationService();
  when(() => notifications.cancelPlantReminders(any()))
      .thenAnswer((_) async {});
  when(() => notifications.scheduleWateringReminder(any()))
      .thenAnswer((_) async {});
  when(() => notifications.scheduleFertilizingReminder(any()))
      .thenAnswer((_) async {});

  await tester.pumpWidget(wrapDetail(
    Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).pushNamed(
            '/plant-detail-screen',
            arguments: arguments,
          ),
          child: const Text('open'),
        ),
      ),
    ),
    service: service,
    routes: {
      '/plant-detail-screen': (_) => PlantDetailScreen(
            plantRepository: repository,
            notificationService: notifications,
          ),
    },
  ));

  await tester.tap(find.text('open'));
  await tester.pump();
  await pumpUi(tester);

  await tester.tap(find.byIcon(Icons.notifications));
  await pumpUi(tester);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(
      Plant(
        id: 'plant-1',
        name: 'Monstera',
        species: 'Monstera deliciosa',
        imageUrl: '',
        status: 'healthy',
        dateAdded: DateTime(2026, 1, 1),
        careSchedule: const {},
        photos: const [],
      ),
    );
  });

  group('PlantDetailScreen reminder sheet AI', () {
    testWidgets('renders the AI schedule and reminder message affordances',
        (tester) async {
      await openReminderSheet(
        tester,
        repository: RecordingPlantRepository(),
        service: FakePlantAiService(),
      );

      expect(find.text('Care Reminders'), findsOneWidget);
      expect(find.text('AI Schedule'), findsOneWidget);
      expect(find.text('Regenerate schedule'), findsOneWidget);
      expect(find.text('Reminder Message'), findsOneWidget);
      expect(find.text('Write smart reminder text'), findsOneWidget);
      expect(find.text('Time to water Monstera!'), findsOneWidget);
    });

    testWidgets(
        'Confirm on a regenerated schedule writes dot-notation fields',
        (tester) async {
      final repository = RecordingPlantRepository();
      final service = FakePlantAiService(
        suggestion: const ScheduleSuggestion(
          wateringFrequency: 12,
          fertilizingEnabled: true,
          fertilizingFrequency: 45,
          mistingEnabled: true,
          mistingFrequency: 2,
          rotatingEnabled: false,
          rotatingFrequency: 7,
        ),
      );
      await openReminderSheet(tester, repository: repository, service: service);

      await tester.ensureVisible(find.text('Regenerate schedule'));
      await tester.tap(find.text('Regenerate schedule'));
      await pumpUi(tester);

      expect(service.suggestCalls, 1);
      expect(service.lastScheduleRequest!.species, 'Monstera deliciosa');
      expect(service.lastScheduleRequest!.light, isNull);
      expect(service.lastScheduleRequest!.location, 'Living room');
      expect(find.text('Suggested schedule'), findsOneWidget);

      await tester.ensureVisible(find.text('Confirm'));
      await tester.tap(find.text('Confirm'));
      await pumpUi(tester);

      expect(repository.updatedIds, ['plant-1']);
      final update = repository.updates.single;
      expect(update['careSchedule.wateringFrequency'], 12);
      expect(update['careSchedule.fertilizingEnabled'], isTrue);
      expect(update['careSchedule.fertilizingFrequency'], 45);
      expect(update['careSchedule.mistingEnabled'], isTrue);
      expect(update['careSchedule.mistingFrequency'], 2);
      expect(update['careSchedule.rotatingEnabled'], isFalse);
      expect(update['careSchedule.rotatingFrequency'], 7);
      expect(find.text('AI schedule applied'), findsOneWidget);
      expect(find.text('Suggested schedule'), findsNothing);
    });

    testWidgets('Try again re-calls the schedule service', (tester) async {
      final service = FakePlantAiService();
      await openReminderSheet(
        tester,
        repository: RecordingPlantRepository(),
        service: service,
      );

      await tester.ensureVisible(find.text('Regenerate schedule'));
      await tester.tap(find.text('Regenerate schedule'));
      await pumpUi(tester);
      await tester.ensureVisible(find.text('Try again'));
      await tester.tap(find.text('Try again'));
      await pumpUi(tester);

      expect(service.suggestCalls, 2);
      expect(find.text('Suggested schedule'), findsOneWidget);
    });

    testWidgets('Confirm on reminder text writes careSchedule.reminderText',
        (tester) async {
      final repository = RecordingPlantRepository();
      final service = FakePlantAiService(
        reminderText: 'Monstera is thirsty — water it today!',
      );
      await openReminderSheet(tester, repository: repository, service: service);

      await tester.ensureVisible(find.text('Write smart reminder text'));
      await tester.tap(find.text('Write smart reminder text'));
      await pumpUi(tester);

      expect(service.reminderCalls, 1);
      expect(
        service.lastReminderRequest!.careSchedule['wateringFrequency'],
        7,
      );
      expect(find.text('Suggested reminder message'), findsOneWidget);
      expect(
        find.text('Monstera is thirsty — water it today!'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Confirm'));
      await tester.tap(find.text('Confirm'));
      await pumpUi(tester);

      expect(repository.updatedIds, ['plant-1']);
      expect(
        repository.updates.single['careSchedule.reminderText'],
        'Monstera is thirsty — water it today!',
      );
      expect(find.text('Reminder message updated'), findsOneWidget);
    });

    testWidgets('shows the resting card when schedule generation is limited',
        (tester) async {
      await openReminderSheet(
        tester,
        repository: RecordingPlantRepository(),
        service: FakePlantAiService(error: const QuotaExceededError()),
      );

      await tester.ensureVisible(find.text('Regenerate schedule'));
      await tester.tap(find.text('Regenerate schedule'));
      await pumpUi(tester);

      expect(find.text('The assistant is resting'), findsOneWidget);
      expect(find.text('Try again in a moment.'), findsOneWidget);
    });

    testWidgets('shows the resting card when reminder text generation is limited',
        (tester) async {
      await openReminderSheet(
        tester,
        repository: RecordingPlantRepository(),
        service: FakePlantAiService(error: const QuotaExceededError()),
      );

      await tester.ensureVisible(find.text('Write smart reminder text'));
      await tester.tap(find.text('Write smart reminder text'));
      await pumpUi(tester);

      expect(find.text('The assistant is resting'), findsOneWidget);
      expect(find.text('Try again in a moment.'), findsOneWidget);
    });

    testWidgets('shows the current reminder message after confirmation',
        (tester) async {
      final repository = RecordingPlantRepository();
      final service = FakePlantAiService(
        reminderText: 'Monstera is thirsty — water it today!',
      );
      await openReminderSheet(tester, repository: repository, service: service);

      await tester.ensureVisible(find.text('Write smart reminder text'));
      await tester.tap(find.text('Write smart reminder text'));
      await pumpUi(tester);
      await tester.ensureVisible(find.text('Confirm'));
      await tester.tap(find.text('Confirm'));
      await pumpUi(tester);

      expect(find.text('Monstera is thirsty — water it today!'), findsWidgets);
    });
  });
}