import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/models/plant.dart';
import 'package:plantcare/presentation/plant_detail_screen/widgets/health_log_tab_widget.dart';
import 'package:plantcare/providers/plant_ai_service_provider.dart';
import 'package:plantcare/services/plant_ai_service.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class FakePlantAiService implements PlantAiService {
  FakePlantAiService({this.onSummarize});

  final Future<HealthLogSummary> Function(SummaryRequest request)? onSummarize;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<HealthLogSummary> summarizeHealthLogs(SummaryRequest request) {
    final handler = onSummarize;
    if (handler == null) {
      throw UnimplementedError('No summarize handler registered.');
    }
    return handler(request);
  }

  @override
  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request) async {
    return const DiagnosisResult(condition: 'Overwatering', severity: 'mild');
  }

  @override
  Future<String> chatAboutPlant(ChatRequest request) async => 'Stub reply';

  @override
  Future<ScheduleSuggestion> suggestWateringSchedule(
    ScheduleRequest request,
  ) async {
    throw UnsupportedError('FakePlantAiService does not generate schedules');
  }

  @override
  Future<String> reminderTextFor(ReminderTextRequest request) async {
    throw UnsupportedError(
      'FakePlantAiService does not generate reminder text',
    );
  }
}

Widget wrapApp(Widget home, {PlantAiService? service}) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: PlantAiServiceProvider(
          service: service ?? const StubPlantAiService(),
          child: Scaffold(body: home),
        ),
      );
    },
  );
}

Plant buildPlant() {
  return Plant(
    id: 'plant-1',
    name: 'Monstera',
    species: 'Monstera deliciosa',
    imageUrl: '',
    status: 'healthy',
    location: 'Living room',
    dateAdded: DateTime(2026, 1, 1),
    careSchedule: const {'wateringFrequency': 7},
    photos: const [],
  );
}

HealthLogSummary buildSummary() {
  return const HealthLogSummary(
    overallHealth: 'Healthy and growing steadily.',
    notableChanges: ['New leaf unfurled'],
    anomalies: ['Two yellowing lower leaves'],
    suggestions: ['Water when the top two centimetres are dry'],
  );
}

/// The screens are designed for portrait phones; the default 800x600 test
/// viewport makes several of them overflow.
Future<void> usePhoneViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() {
    // Keep fonts deterministic: no runtime HTTP font fetching in tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('HealthLogTabWidget', () {
    testWidgets('Add Log opens a dialog with type selector, notes and date',
        (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(
        wrapApp(HealthLogTabWidget(
          plant: buildPlant(),
          healthLogs: const [],
          onAddLog: (type, notes, date) async {},
        )),
      );

      expect(find.text('Health Timeline'), findsOneWidget);

      await tester.tap(find.text('Add Log'));
      await tester.pumpAndSettle();

      expect(find.text('Add Health Log'), findsOneWidget);
      // Log type selector options
      expect(find.text('Watering'), findsOneWidget);
      expect(find.text('Fertilizing'), findsOneWidget);
      expect(find.text('Repotting'), findsOneWidget);
      expect(find.text('Pest check'), findsOneWidget);
      // Optional notes field and date input
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('date defaults to today in the Add Log dialog',
        (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(
        wrapApp(HealthLogTabWidget(
          plant: buildPlant(),
          healthLogs: const [],
          onAddLog: (type, notes, date) async {},
        )),
      );

      await tester.tap(find.text('Add Log'));
      await tester.pumpAndSettle();

      final today = DateTime.now();
      expect(
        find.text('${today.day}/${today.month}/${today.year}'),
        findsOneWidget,
      );
    });

    testWidgets('saving a log invokes onAddLog with the selected values',
        (tester) async {
      await usePhoneViewport(tester);
      String? savedType;
      String? savedNotes;
      DateTime? savedDate;
      await tester.pumpWidget(
        wrapApp(HealthLogTabWidget(
          plant: buildPlant(),
          healthLogs: const [],
          onAddLog: (type, notes, date) async {
            savedType = type;
            savedNotes = notes;
            savedDate = date;
          },
        )),
      );

      await tester.tap(find.text('Add Log'));
      await tester.pumpAndSettle();

      // Pick a log type and add notes.
      await tester.tap(find.text('Fertilizing'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Fertilized with 10-10-10');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final today = DateTime.now();
      expect(savedType, 'fertilizing');
      expect(savedNotes, 'Fertilized with 10-10-10');
      expect(savedDate!.day, today.day);
      expect(savedDate!.month, today.month);
      expect(savedDate!.year, today.year);
      // Dialog closed after saving.
      expect(find.text('Add Health Log'), findsNothing);
    });

    testWidgets('cancelling the dialog does not call onAddLog',
        (tester) async {
      await usePhoneViewport(tester);
      var calls = 0;
      await tester.pumpWidget(
        wrapApp(HealthLogTabWidget(
          plant: buildPlant(),
          healthLogs: const [],
          onAddLog: (type, notes, date) async {
            calls++;
          },
        )),
      );

      await tester.tap(find.text('Add Log'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(calls, 0);
      expect(find.text('Add Health Log'), findsNothing);
    });

    testWidgets('timeline renders entries written with the health log keys',
        (tester) async {
      await usePhoneViewport(tester);
      final logs = [
        {
          'type': 'watering',
          'title': 'Watering',
          'description': 'Soaked thoroughly until drainage',
          'date': DateTime(2026, 8, 10),
          'createdAt': DateTime(2026, 8, 10).toIso8601String(),
        },
      ];
      await tester.pumpWidget(
        wrapApp(HealthLogTabWidget(
          plant: buildPlant(),
          healthLogs: logs,
          onAddLog: (type, notes, date) async {},
        )),
      );

      expect(find.text('WATERING'), findsOneWidget);
      expect(find.text('Watering'), findsOneWidget);
      expect(find.text('Soaked thoroughly until drainage'), findsOneWidget);
      expect(find.text('10/8/2026'), findsOneWidget);
    });
  });

  group('HealthLogTabWidget summary', () {
    testWidgets('renders a generated summary card after summarizing',
        (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(
        wrapApp(
          HealthLogTabWidget(
            plant: buildPlant(),
            healthLogs: const [],
            onAddLog: (type, notes, date) async {},
          ),
          service: FakePlantAiService(onSummarize: (_) async => buildSummary()),
        ),
      );

      await tester.tap(find.text('Summarize'));
      await tester.pumpAndSettle();

      expect(find.text('Healthy and growing steadily.'), findsOneWidget);
      expect(find.text('Notable changes'), findsOneWidget);
      expect(find.text('New leaf unfurled'), findsOneWidget);
      expect(find.text('Worth attention'), findsOneWidget);
      expect(find.text('Two yellowing lower leaves'), findsOneWidget);
      expect(find.text('Suggestions'), findsOneWidget);
      expect(
        find.text('Water when the top two centimetres are dry'),
        findsOneWidget,
      );
      expect(find.text('Regenerate'), findsOneWidget);
    });

    testWidgets('shows a loading state while summarizing', (tester) async {
      await usePhoneViewport(tester);
      final completer = Completer<HealthLogSummary>();
      await tester.pumpWidget(
        wrapApp(
          HealthLogTabWidget(
            plant: buildPlant(),
            healthLogs: const [],
            onAddLog: (type, notes, date) async {},
          ),
          service: FakePlantAiService(
            onSummarize: (_) => completer.future,
          ),
        ),
      );

      await tester.tap(find.text('Summarize'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.text("Writing your plant's health story…"),
        findsOneWidget,
      );

      completer.complete(buildSummary());
      await tester.pumpAndSettle();

      expect(find.text('Healthy and growing steadily.'), findsOneWidget);
    });

    testWidgets('regenerating replaces the summary with an updated one',
        (tester) async {
      await usePhoneViewport(tester);
      var calls = 0;
      await tester.pumpWidget(
        wrapApp(
          HealthLogTabWidget(
            plant: buildPlant(),
            healthLogs: const [],
            onAddLog: (type, notes, date) async {},
          ),
          service: FakePlantAiService(onSummarize: (_) async {
            calls++;
            return calls == 1
                ? buildSummary()
                : const HealthLogSummary(
                    overallHealth: 'Updated summary text.',
                  );
          }),
        ),
      );

      await tester.tap(find.text('Summarize'));
      await tester.pumpAndSettle();
      expect(find.text('Healthy and growing steadily.'), findsOneWidget);

      await tester.tap(find.text('Regenerate'));
      await tester.pumpAndSettle();

      expect(find.text('Updated summary text.'), findsOneWidget);
      expect(find.text('Healthy and growing steadily.'), findsNothing);
    });

    for (final (error, title, body) in [
      (
        const QuotaExceededError(),
        'The assistant is resting',
        'Try again in a moment.',
      ),
      (
        const BlockedError(),
        'The assistant could not answer',
        'Try rephrasing or summarize again.',
      ),
      (
        const TimeoutError(),
        'The assistant took too long',
        'Try again in a moment.',
      ),
      (
        const MalformedOutputError(),
        'The assistant is resting',
        'Try again in a moment.',
      ),
      (
        const OfflineError(),
        "You're offline",
        'Connect to the internet and try again.',
      ),
      (
        const UnknownError(),
        'Something went wrong',
        'Try again in a moment.',
      ),
    ]) {
      testWidgets('renders the $title error message with retry',
          (tester) async {
        await usePhoneViewport(tester);
        await tester.pumpWidget(
          wrapApp(
            HealthLogTabWidget(
              plant: buildPlant(),
              healthLogs: const [],
              onAddLog: (type, notes, date) async {},
            ),
            service: FakePlantAiService(
              onSummarize: (_) async => throw error,
            ),
          ),
        );

        await tester.tap(find.text('Summarize'));
        await tester.pumpAndSettle();

        expect(find.text(title), findsOneWidget);
        expect(find.text(body), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
      });
    }
  });
}