import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/presentation/plant_detail_screen/widgets/health_log_tab_widget.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

Widget wrapApp(Widget home) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: home),
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
}