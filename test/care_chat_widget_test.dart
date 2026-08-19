import 'dart:async';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/presentation/care_assistant_hub/care_chat_stub_screen.dart';
import 'package:plantcare/providers/plant_ai_service_provider.dart';
import 'package:plantcare/services/plant_ai_service.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class FakeChatPlantAiService implements PlantAiService {
  FakeChatPlantAiService({this.reply = 'Water it weekly.', this.error});

  final String? reply;
  final PlantAiException? error;
  Completer<String>? pending;
  ChatRequest? lastRequest;
  List<ChatMessage> lastRequestMessages = const [];

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request) async {
    return const DiagnosisResult(condition: 'Overwatering', severity: 'mild');
  }

  @override
  Future<String> chatAboutPlant(ChatRequest request) {
    lastRequest = request;
    lastRequestMessages = List.of(request.messages);
    final inFlight = pending;
    if (inFlight != null) return inFlight.future;
    final failure = error;
    if (failure != null) throw failure;
    return Future.value(reply);
  }

  @override
  Future<ScheduleSuggestion> suggestWateringSchedule(
    ScheduleRequest request,
  ) async {
    throw UnsupportedError('FakeChatPlantAiService does not generate schedules');
  }

  @override
  Future<String> reminderTextFor(ReminderTextRequest request) async {
    throw UnsupportedError(
      'FakeChatPlantAiService does not generate reminder text',
    );
  }

  @override
  Future<HealthLogSummary> summarizeHealthLogs(SummaryRequest request) async {
    throw UnsupportedError('FakeChatPlantAiService does not generate summaries');
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

Widget wrapChat(Widget child, {required PlantAiService service}) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: PlantAiServiceProvider(
          service: service,
          child: child,
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

Future<void> sendMessage(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.byType(IconButton));
  await tester.pump();
}

bool sendButtonEnabled(WidgetTester tester) {
  final button = tester.widget<IconButton>(find.byType(IconButton));
  return button.onPressed != null;
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

  group('CareChatStubScreen', () {
    testWidgets('sends a message and renders the assistant reply',
        (tester) async {
      await usePhoneViewport(tester);
      final fake = FakeChatPlantAiService(reply: 'Water it weekly.');
      await tester.pumpWidget(wrapChat(
        const CareChatStubScreen(),
        service: fake,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ask about watering, light, pests and more'),
          findsOneWidget);
      expect(sendButtonEnabled(tester), isFalse);

      await sendMessage(tester, 'Why are the leaves yellow?');
      await tester.pumpAndSettle();

      expect(find.text('Why are the leaves yellow?'), findsOneWidget);
      expect(find.text('Water it weekly.'), findsOneWidget);
      expect(fake.lastRequestMessages, hasLength(1));
      expect(fake.lastRequestMessages.first.role, 'user');
      expect(fake.lastRequestMessages.first.text,
          'Why are the leaves yellow?');
      expect(fake.lastRequest!.plantName, 'your plant');
    });

    testWidgets('renders a resting card for each taxonomy error',
        (tester) async {
      await usePhoneViewport(tester);
      final errors = <PlantAiException>[
        const QuotaExceededError(),
        const BlockedError(),
        const TimeoutError(),
        const MalformedOutputError(),
        const OfflineError(),
        const UnknownError(),
      ];

      for (final error in errors) {
        await tester.pumpWidget(wrapChat(
          const CareChatStubScreen(),
          service: FakeChatPlantAiService(error: error),
        ));
        await tester.pumpAndSettle();

        await sendMessage(tester, 'Is my plant okay?');
        await tester.pumpAndSettle();

        expect(find.text('The assistant is resting'), findsOneWidget,
            reason: error.runtimeType.toString());
        expect(find.text(error.message), findsOneWidget,
            reason: error.runtimeType.toString());
      }
    });

    testWidgets('disables the send button while the assistant is typing',
        (tester) async {
      await usePhoneViewport(tester);
      final fake = FakeChatPlantAiService()
        ..pending = Completer<String>();
      await tester.pumpWidget(wrapChat(
        const CareChatStubScreen(),
        service: fake,
      ));
      await tester.pumpAndSettle();

      await sendMessage(tester, 'What light does it need?');

      expect(sendButtonEnabled(tester), isFalse);
      expect(find.text('Assistant is typing…'), findsOneWidget);

      fake.pending!.complete('Bright, indirect light.');
      await tester.pumpAndSettle();

      expect(find.text('Bright, indirect light.'), findsOneWidget);
      expect(find.text('Assistant is typing…'), findsNothing);

      await tester.enterText(find.byType(TextField), 'More light?');
      await tester.pump();

      expect(sendButtonEnabled(tester), isTrue);
    });

    testWidgets('disables the send button when offline', (tester) async {
      await usePhoneViewport(tester);
      ConnectivityPlatform.instance = FakeConnectivityPlatform(
        checkResult: [ConnectivityResult.none],
      );
      final fake = FakeChatPlantAiService();
      await tester.pumpWidget(wrapChat(
        const CareChatStubScreen(),
        service: fake,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Any tips?');
      await tester.pump();

      expect(sendButtonEnabled(tester), isFalse);

      await tester.tap(find.byType(IconButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(fake.lastRequest, isNull);
    });
  });
}