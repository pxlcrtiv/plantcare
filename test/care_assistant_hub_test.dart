import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/presentation/care_assistant_hub/care_assistant_hub.dart';
import 'package:plantcare/presentation/care_assistant_hub/care_chat_stub_screen.dart';
import 'package:plantcare/presentation/care_assistant_hub/plant_doctor_stub_screen.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

Widget wrapHub(Widget child) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: child),
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
    // Keep fonts deterministic: no runtime HTTP font fetching in tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CareAssistantHub', () {
    testWidgets('renders the header and both entry cards', (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapHub(const CareAssistantHub()));
      await tester.pump();

      expect(find.text('Care Assistant'), findsOneWidget);
      expect(find.text('Plant Doctor'), findsOneWidget);
      expect(find.text('Care chat'), findsOneWidget);
      expect(find.byIcon(Icons.medical_information_outlined), findsOneWidget);
      expect(find.byIcon(Icons.chat_outlined), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
    });

    testWidgets('tapping Plant Doctor opens its stub screen', (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapHub(const CareAssistantHub()));
      await tester.pump();

      await tester.tap(find.text('Plant Doctor'));
      await tester.pumpAndSettle();

      expect(find.byType(PlantDoctorStubScreen), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
    });

    testWidgets('tapping Care chat opens its stub screen', (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapHub(const CareAssistantHub()));
      await tester.pump();

      await tester.tap(find.text('Care chat'));
      await tester.pumpAndSettle();

      expect(find.byType(CareChatStubScreen), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
    });
  });
}