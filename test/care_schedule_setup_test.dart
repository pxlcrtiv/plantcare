import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/presentation/add_plant_screen/widgets/care_schedule_setup.dart';
import 'package:plantcare/providers/plant_ai_service_provider.dart';
import 'package:plantcare/services/plant_ai_service.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class FakePlantAiService implements PlantAiService {
  FakePlantAiService({
    this.available = true,
    this.suggestion,
    this.error,
  });

  bool available;
  ScheduleSuggestion? suggestion;
  PlantAiException? error;
  int suggestCalls = 0;
  ScheduleRequest? lastScheduleRequest;

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
    throw UnsupportedError('FakePlantAiService does not generate reminder text');
  }

  @override
  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request) async {
    return const DiagnosisResult(condition: 'Overwatering', severity: 'mild');
  }

  @override
  Future<String> chatAboutPlant(ChatRequest request) async => 'Stub reply';
}

Widget wrapSetup(
  Widget child, {
  PlantAiService? service,
}) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: PlantAiServiceProvider(
          service: service ?? FakePlantAiService(),
          child: Scaffold(body: SingleChildScrollView(child: child)),
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

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CareScheduleSetup AI proposal', () {
    testWidgets('proposes a schedule grounded in species and environment',
        (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(
        suggestion: const ScheduleSuggestion(
          wateringFrequency: 12,
          fertilizingEnabled: true,
          fertilizingFrequency: 45,
          mistingEnabled: true,
          mistingFrequency: 2,
          rotatingEnabled: false,
          rotatingFrequency: 7,
          reason: 'Bright light dries the soil faster',
        ),
      );
      await tester.pumpWidget(wrapSetup(
        CareScheduleSetup(
          species: 'Monstera deliciosa',
          light: 'Bright indirect',
          humidity: 60,
          location: 'Living room',
          onScheduleChanged: (_) {},
        ),
        service: service,
      ));
      await tester.pump();

      expect(find.text('Generate AI schedule'), findsOneWidget);

      await tester.tap(find.text('Generate AI schedule'));
      await tester.pumpAndSettle();

      expect(service.suggestCalls, 1);
      expect(service.lastScheduleRequest!.species, 'Monstera deliciosa');
      expect(service.lastScheduleRequest!.light, 'Bright indirect');
      expect(service.lastScheduleRequest!.humidity, 60);
      expect(service.lastScheduleRequest!.location, 'Living room');
      expect(
        service.lastScheduleRequest!.careSchedule['wateringFrequency'],
        7,
      );
      expect(find.text('Suggested schedule'), findsOneWidget);
      expect(find.text('Watering'), findsOneWidget);
      expect(find.text('Every 12 days'), findsOneWidget);
      expect(find.text('Every 45 days'), findsOneWidget);
      expect(find.text('Every 2 days'), findsOneWidget);
      expect(find.text('Bright light dries the soil faster'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Confirm applies the suggested schedule through the callback',
        (tester) async {
      await usePhoneViewport(tester);
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
      final received = <Map<String, dynamic>>[];
      await tester.pumpWidget(wrapSetup(
        CareScheduleSetup(
          species: 'Monstera deliciosa',
          onScheduleChanged: received.add,
        ),
        service: service,
      ));
      await tester.pump();

      await tester.tap(find.text('Generate AI schedule'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      final applied = received.last;
      expect(applied['wateringFrequency'], 12);
      expect(applied['fertilizingEnabled'], isTrue);
      expect(applied['fertilizingFrequency'], 45);
      expect(applied['mistingEnabled'], isTrue);
      expect(applied['mistingFrequency'], 2);
      expect(applied['rotatingEnabled'], isFalse);
      expect(applied['rotatingFrequency'], 7);
      expect(find.text('Suggested schedule'), findsNothing);
    });

    testWidgets('Try again re-calls the service', (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService();
      await tester.pumpWidget(wrapSetup(
        CareScheduleSetup(species: 'Monstera', onScheduleChanged: (_) {}),
        service: service,
      ));
      await tester.pump();

      await tester.tap(find.text('Generate AI schedule'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(service.suggestCalls, 2);
      expect(find.text('Suggested schedule'), findsOneWidget);
    });

    testWidgets('Cancel dismisses the suggestion without applying',
        (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(
        suggestion: const ScheduleSuggestion(wateringFrequency: 12),
      );
      final received = <Map<String, dynamic>>[];
      await tester.pumpWidget(wrapSetup(
        CareScheduleSetup(
          species: 'Monstera',
          onScheduleChanged: received.add,
        ),
        service: service,
      ));
      await tester.pump();

      await tester.tap(find.text('Generate AI schedule'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Suggested schedule'), findsNothing);
      expect(received.last['wateringFrequency'], isNot(12));
    });

    testWidgets('shows the resting card when the quota is exhausted',
        (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(error: const QuotaExceededError());
      await tester.pumpWidget(wrapSetup(
        CareScheduleSetup(species: 'Monstera', onScheduleChanged: (_) {}),
        service: service,
      ));
      await tester.pump();

      await tester.tap(find.text('Generate AI schedule'));
      await tester.pumpAndSettle();

      expect(find.text('The assistant is resting'), findsOneWidget);
      expect(find.text('Try again in a moment.'), findsOneWidget);
      expect(find.text('Generate AI schedule'), findsOneWidget);
    });

    testWidgets('renders a message for each taxonomy error', (tester) async {
      final cases = <PlantAiException, String>{
        const QuotaExceededError(): 'The assistant is resting',
        const BlockedError(): "The assistant couldn't answer that",
        const TimeoutError(): 'The assistant took too long',
        const MalformedOutputError():
            'The assistant returned an unexpected answer',
        const OfflineError(): "You're offline",
        const UnknownError(): 'The assistant hit a snag',
      };

      for (final entry in cases.entries) {
        await usePhoneViewport(tester);
        final service = FakePlantAiService(error: entry.key);
        await tester.pumpWidget(wrapSetup(
          CareScheduleSetup(species: 'Monstera', onScheduleChanged: (_) {}),
          service: service,
        ));
        await tester.pump();

        await tester.tap(find.text('Generate AI schedule'));
        await tester.pumpAndSettle();

        expect(
          find.text(entry.value),
          findsOneWidget,
          reason: 'Expected ${entry.key.runtimeType} to render its message',
        );
      }
    });

    testWidgets('falls back to the resting state when no service is wired',
        (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapSetup(
        CareScheduleSetup(species: 'Monstera', onScheduleChanged: (_) {}),
        service: const StubPlantAiService(),
      ));
      await tester.pump();

      await tester.tap(find.text('Generate AI schedule'));
      await tester.pumpAndSettle();

      expect(find.text('The assistant hit a snag'), findsOneWidget);
      expect(find.text('Try again in a moment.'), findsOneWidget);
    });
  });
}