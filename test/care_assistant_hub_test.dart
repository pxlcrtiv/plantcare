import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/presentation/care_assistant_hub/care_assistant_hub.dart';
import 'package:plantcare/presentation/care_assistant_hub/care_chat_stub_screen.dart';
import 'package:plantcare/presentation/care_assistant_hub/plant_doctor_stub_screen.dart';
import 'package:plantcare/providers/plant_ai_service_provider.dart';
import 'package:plantcare/services/plant_ai_service.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class FakePlantAiService implements PlantAiService {
  FakePlantAiService({this.available = true});

  bool available;

  @override
  Future<bool> isAvailable() async => available;

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

  @override
  Future<HealthLogSummary> summarizeHealthLogs(SummaryRequest request) async {
    throw UnsupportedError('FakePlantAiService does not generate summaries');
  }
}

class FakeConnectivityPlatform extends ConnectivityPlatform {
  FakeConnectivityPlatform({List<ConnectivityResult>? checkResult})
      : checkResult = checkResult ?? [ConnectivityResult.wifi];

  List<ConnectivityResult> checkResult;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => checkResult;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

Widget wrapHub(Widget child, {PlantAiService? service}) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: PlantAiServiceProvider(
          service: service ?? FakePlantAiService(),
          child: Scaffold(body: child),
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
  late ConnectivityPlatform originalPlatform;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    originalPlatform = ConnectivityPlatform.instance;
    ConnectivityPlatform.instance = FakeConnectivityPlatform();
  });

  tearDown(() {
    ConnectivityPlatform.instance = originalPlatform;
  });

  group('CareAssistantHub', () {
    testWidgets('renders the header and both entry cards', (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapHub(const CareAssistantHub()));
      await tester.pumpAndSettle();

      expect(find.text('Care Assistant'), findsOneWidget);
      expect(find.text('Plant Doctor'), findsOneWidget);
      expect(find.text('Care chat'), findsOneWidget);
      expect(find.byIcon(Icons.medical_information_outlined), findsOneWidget);
      expect(find.byIcon(Icons.chat_outlined), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
      expect(find.text('The assistant is resting'), findsNothing);
      expect(find.textContaining("You're offline"), findsNothing);
    });

    testWidgets('tapping Plant Doctor opens its stub screen', (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapHub(const CareAssistantHub()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Plant Doctor'));
      await tester.pumpAndSettle();

      expect(find.byType(PlantDoctorStubScreen), findsOneWidget);
      expect(find.text('Diagnose'), findsOneWidget);
    });

    testWidgets('tapping Care chat opens the chat screen', (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapHub(const CareAssistantHub()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Care chat'));
      await tester.pumpAndSettle();

      expect(find.byType(CareChatStubScreen), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('shows a resting notice when the assistant is unavailable',
        (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapHub(
        const CareAssistantHub(),
        service: FakePlantAiService(available: false),
      ));
      await tester.pumpAndSettle();

      expect(find.text('The assistant is resting'), findsOneWidget);
      expect(find.text('Try again in a moment.'), findsOneWidget);
      expect(find.text('Plant Doctor'), findsOneWidget);
      expect(find.text('Care chat'), findsOneWidget);
    });

    testWidgets('shows an offline banner when the device is offline',
        (tester) async {
      await usePhoneViewport(tester);
      ConnectivityPlatform.instance = FakeConnectivityPlatform(
        checkResult: [ConnectivityResult.none],
      );
      await tester.pumpWidget(wrapHub(const CareAssistantHub()));
      await tester.pumpAndSettle();

      expect(find.textContaining("You're offline"), findsOneWidget);
      expect(find.text('Plant Doctor'), findsOneWidget);
    });
  });
}