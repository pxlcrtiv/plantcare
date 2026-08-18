import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare/services/plant_ai_service.dart';

class FakeConnectivityPlatform extends ConnectivityPlatform {
  FakeConnectivityPlatform({this.isOffline = false});

  final bool isOffline;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
        if (isOffline) ConnectivityResult.none else ConnectivityResult.wifi,
      ];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

class RecordingModelCall {
  RecordingModelCall();

  final List<GenerateContentResponse> responses = [];
  final List<Object> errors = [];
  List<Content>? lastContent;
  GenerationConfig? lastConfig;
  int callCount = 0;

  ModelCall get call => (content, config) async {
        callCount++;
        lastContent = content;
        lastConfig = config;
        if (errors.isNotEmpty) {
          throw errors.removeAt(0);
        }
        return responses.removeAt(0);
      };
}

GenerateContentResponse textResponse(String text) {
  return GenerateContentResponse(
    [Candidate(Content('model', [TextPart(text)]), null, null, null, null)],
    null,
  );
}

GenerateContentResponse blockedResponse() {
  return GenerateContentResponse(
    const [],
    PromptFeedback(BlockReason.safety, 'blocked', const []),
  );
}

DiagnosisRequest buildRequest({
  Uint8List? photoBytes,
  String? species,
  String? light,
  int? humidity,
  String? location,
}) {
  return DiagnosisRequest(
    photoBytes: photoBytes ?? Uint8List.fromList([1, 2, 3, 4]),
    photoMimeType: 'image/jpeg',
    species: species,
    light: light,
    humidity: humidity,
    location: location,
  );
}

void main() {
  late ConnectivityPlatform originalPlatform;
  late RecordingModelCall recorder;
  late FirebasePlantAiService service;

  setUp(() {
    originalPlatform = ConnectivityPlatform.instance;
    ConnectivityPlatform.instance = FakeConnectivityPlatform();
    recorder = RecordingModelCall();
    service = FirebasePlantAiService(recorder.call);
  });

  tearDown(() {
    ConnectivityPlatform.instance = originalPlatform;
  });

  group('prompt assembly', () {
    test('sends photo bytes and grounding fields in the content', () async {
      recorder.responses.add(textResponse(_validJson));

      await service.diagnosePlant(
        buildRequest(
          species: 'Monstera deliciosa',
          light: 'Bright indirect light',
          humidity: 60,
          location: 'Living room',
        ),
      );

      final content = recorder.lastContent!;
      expect(content, hasLength(1));
      expect(content.first.parts, hasLength(2));
      final textPart = content.first.parts.first as TextPart;
      final dataPart = content.first.parts.last as InlineDataPart;
      expect(textPart.text, contains('Monstera deliciosa'));
      expect(textPart.text, contains('Bright indirect light'));
      expect(textPart.text, contains('60'));
      expect(textPart.text, contains('Living room'));
      expect(dataPart.bytes, [1, 2, 3, 4]);
      expect(dataPart.mimeType, 'image/jpeg');
    });

    test('uses tolerant placeholders when grounding is missing', () async {
      recorder.responses.add(textResponse(_validJson));

      await service.diagnosePlant(buildRequest());

      final textPart =
          recorder.lastContent!.first.parts.first as TextPart;
      expect(textPart.text, contains('- Species: Unknown'));
      expect(textPart.text, contains('- Light: Unknown'));
      expect(textPart.text, contains('- Humidity: Unknown'));
      expect(textPart.text, contains('- Location: Unknown'));
    });

    test('configures JSON schema output for the diagnosis feature', () async {
      recorder.responses.add(textResponse(_validJson));

      await service.diagnosePlant(buildRequest());

      final config = recorder.lastConfig!;
      expect(config.responseMimeType, 'application/json');
      expect(config.responseSchema, isNotNull);
      expect(config.temperature, 0.3);
      expect(config.maxOutputTokens, 1024);
    });
  });

  group('result parsing', () {
    test('parses a well-formed diagnosis JSON', () async {
      recorder.responses.add(textResponse(_validJson));

      final result = await service.diagnosePlant(buildRequest());

      expect(result.condition, 'Powdery mildew');
      expect(result.severity, 'moderate');
      expect(result.confidence, closeTo(0.84, 0.0001));
      expect(result.causes, ['High humidity', 'Poor air circulation']);
      expect(
        result.careSteps,
        ['Remove affected leaves', 'Improve airflow around the plant'],
      );
    });

    test('fills tolerant defaults when optional fields are missing', () async {
      recorder.responses.add(textResponse(_minimalJson));

      final result = await service.diagnosePlant(buildRequest());

      expect(result.condition, 'Underwatering');
      expect(result.severity, 'mild');
      expect(result.confidence, 0.0);
      expect(result.causes, isEmpty);
      expect(result.careSteps, isEmpty);
    });

    test('throws MalformedOutputError for a non-JSON response', () async {
      recorder.responses.add(textResponse('definitely not json'));

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when JSON is not an object', () async {
      recorder.responses.add(textResponse('[1, 2, 3]'));

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when a required field is missing',
        () async {
      recorder.responses.add(textResponse('{"severity": "mild"}'));

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when a field has the wrong type',
        () async {
      recorder.responses.add(
        textResponse('{"condition": "X", "severity": 42}'),
      );

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when the response has no text', () async {
      recorder.responses.add(
        GenerateContentResponse(
          [Candidate(Content('model', const []), null, null, null, null)],
          null,
        ),
      );

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('fromJson rejects garbage directly', () {
      expect(
        () => DiagnosisResult.fromJson(const {'nope': true}),
        throwsA(isA<MalformedOutputError>()),
      );
    });
  });

  group('error mapping', () {
    test('maps QuotaExceeded to QuotaExceededError', () async {
      recorder.errors.add(QuotaExceeded('Quota exceeded for today'));

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('maps a blocked response to BlockedError', () async {
      recorder.responses.add(blockedResponse());

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<BlockedError>()),
      );
    });

    test('maps a blocked text exception to BlockedError', () async {
      recorder.errors
          .add(FirebaseAIException('Response was blocked due to SAFETY'));

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<BlockedError>()),
      );
    });

    test('maps a TimeoutException to TimeoutError', () async {
      recorder.errors.add(TimeoutException('took too long'));

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<TimeoutError>()),
      );
    });

    test('maps an unknown model failure to UnknownError', () async {
      recorder.errors.add(StateError('boom'));

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<UnknownError>()),
      );
    });
  });

  group('offline handling', () {
    test('throws OfflineError before calling the model when offline',
        () async {
      ConnectivityPlatform.instance = FakeConnectivityPlatform(isOffline: true);

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<OfflineError>()),
      );
      expect(recorder.callCount, 0);
    });

    test('reports unavailable when offline', () async {
      ConnectivityPlatform.instance = FakeConnectivityPlatform(isOffline: true);

      expect(await service.isAvailable(), isFalse);
    });
  });

  group('StubPlantAiService', () {
    test('diagnosePlant throws UnknownError', () async {
      const stub = StubPlantAiService();

      expect(
        () => stub.diagnosePlant(buildRequest()),
        throwsA(isA<UnknownError>()),
      );
    });

    test('isAvailable is false', () async {
      const stub = StubPlantAiService();

      expect(await stub.isAvailable(), isFalse);
    });
  });
}

const String _validJson = '''
{
  "condition": "Powdery mildew",
  "severity": "moderate",
  "confidence": 0.84,
  "causes": ["High humidity", "Poor air circulation"],
  "careSteps": ["Remove affected leaves", "Improve airflow around the plant"]
}
''';

const String _minimalJson = '''
{
  "condition": "Underwatering",
  "severity": "mild"
}
''';