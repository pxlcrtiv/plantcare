import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:plantcare/presentation/care_assistant_hub/plant_doctor_stub_screen.dart';
import 'package:plantcare/providers/plant_ai_service_provider.dart';
import 'package:plantcare/services/plant_ai_service.dart';
import 'package:plantcare/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class FakePlantAiService implements PlantAiService {
  FakePlantAiService({
    this.outcomes = const [],
    this.delay = Duration.zero,
  });

  final List<Object> outcomes;
  final Duration delay;
  int callCount = 0;
  DiagnosisRequest? lastRequest;

  static const DiagnosisResult defaultResult = DiagnosisResult(
    condition: 'Powdery mildew',
    severity: 'moderate',
    confidence: 0.84,
    causes: ['High humidity', 'Poor air circulation'],
    careSteps: ['Remove affected leaves', 'Improve airflow'],
  );

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> chatAboutPlant(ChatRequest request) async => 'Stub reply';

  @override
  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request) async {
    callCount++;
    lastRequest = request;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final outcome = outcomes.isNotEmpty && callCount <= outcomes.length
        ? outcomes[callCount - 1]
        : defaultResult;
    if (outcome is PlantAiException) {
      throw outcome;
    }
    return outcome as DiagnosisResult;
  }

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

class FakeImagePickerPlatform extends ImagePickerPlatform {
  FakeImagePickerPlatform(this.imageBytes);

  final Uint8List imageBytes;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile.fromData(
      imageBytes,
      mimeType: 'image/png',
      name: 'leaf.png',
    );
  }
}

Widget wrapDoctor(PlantAiService service, {String? initialSpecies}) {
  return Sizer(
    builder: (context, orientation, screenType) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: PlantAiServiceProvider(
          service: service,
          child: PlantDoctorStubScreen(initialSpecies: initialSpecies),
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

Future<void> pickGalleryPhoto(WidgetTester tester) async {
  await tester.tap(find.text('Gallery'));
  await tester.pumpAndSettle();
}

void main() {
  late ImagePickerPlatform originalPickerPlatform;
  late Uint8List pngBytes;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    originalPickerPlatform = ImagePickerPlatform.instance;
    pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ'
      'AAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
    );
    ImagePickerPlatform.instance = FakeImagePickerPlatform(pngBytes);
  });

  tearDown(() {
    ImagePickerPlatform.instance = originalPickerPlatform;
  });

  group('PlantDoctorStubScreen', () {
    testWidgets('shows the photo prompt and a disabled Diagnose button',
        (tester) async {
      await usePhoneViewport(tester);
      await tester.pumpWidget(wrapDoctor(FakePlantAiService()));

      expect(find.text('Snap a photo of the ailing leaf'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      final diagnoseButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Diagnose'),
          matching: find.bySubtype<FilledButton>(),
        ),
      );
      expect(diagnoseButton.onPressed, isNull);
    });

    testWidgets('diagnoses a picked photo and renders the result card',
        (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService();
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();

      expect(find.text('Powdery mildew'), findsOneWidget);
      expect(find.text('moderate'), findsOneWidget);
      expect(find.text('84% confidence'), findsOneWidget);
      expect(find.text('Likely causes'), findsOneWidget);
      expect(find.text('High humidity'), findsOneWidget);
      expect(find.text('Care steps'), findsOneWidget);
      expect(find.text('Remove affected leaves'), findsOneWidget);
      expect(find.text('Diagnose another photo'), findsOneWidget);
    });

    testWidgets('passes the photo bytes and species to the service',
        (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService();
      await tester.pumpWidget(
        wrapDoctor(service, initialSpecies: 'Monstera deliciosa'),
      );
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();

      final request = service.lastRequest!;
      expect(request.photoBytes, isNotEmpty);
      expect(request.photoMimeType, 'image/png');
      expect(request.species, 'Monstera deliciosa');
    });

    testWidgets('shows a loading state while diagnosing', (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(
        delay: const Duration(seconds: 1),
      );
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Diagnosing your plant…'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Powdery mildew'), findsOneWidget);
    });

    testWidgets('shows the resting card on a quota error', (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(
        outcomes: [const QuotaExceededError()],
      );
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();

      expect(find.text('The assistant is resting'), findsOneWidget);
      expect(find.text('Try again in a moment.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows the resting card on malformed output', (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(
        outcomes: [const MalformedOutputError()],
      );
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();

      expect(find.text('The assistant is resting'), findsOneWidget);
      expect(find.text('Try again in a moment.'), findsOneWidget);
    });

    testWidgets('shows a no-blame message when the photo is blocked',
        (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(outcomes: [const BlockedError()]);
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();

      expect(find.text('Photo not reviewable'), findsOneWidget);
      expect(
        find.textContaining('could not review this photo'),
        findsOneWidget,
      );
    });

    testWidgets('shows a timeout message', (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(outcomes: [const TimeoutError()]);
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();

      expect(find.text('The assistant took too long'), findsOneWidget);
    });

    testWidgets('shows an offline message', (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(outcomes: [const OfflineError()]);
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();

      expect(find.text("You're offline"), findsOneWidget);
      expect(find.text('AI features need a connection.'), findsOneWidget);
    });

    testWidgets('shows a generic message on unknown errors', (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(outcomes: [const UnknownError()]);
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('retries the diagnosis from the error card', (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService(
        outcomes: [const QuotaExceededError(), FakePlantAiService.defaultResult],
      );
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();
      expect(find.text('The assistant is resting'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Powdery mildew'), findsOneWidget);
      expect(service.callCount, 2);
    });

    testWidgets('re-runs a diagnosis on a new photo after a result',
        (tester) async {
      await usePhoneViewport(tester);
      final service = FakePlantAiService();
      await tester.pumpWidget(wrapDoctor(service));
      await pickGalleryPhoto(tester);

      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();
      expect(find.text('Powdery mildew'), findsOneWidget);

      await tester.tap(find.text('Diagnose another photo'));
      await tester.pumpAndSettle();
      expect(find.text('Snap a photo of the ailing leaf'), findsOneWidget);

      await pickGalleryPhoto(tester);
      await tester.tap(find.text('Diagnose'));
      await tester.pumpAndSettle();

      expect(find.text('Powdery mildew'), findsOneWidget);
      expect(service.callCount, 2);
    });
  });
}