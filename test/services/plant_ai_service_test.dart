import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
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
  RecordingModelCall({this.responder});

  final Future<GenerateContentResponse> Function(
      List<Content>, GenerationConfig)? responder;

  final List<GenerateContentResponse> responses = [];
  final List<Object> errors = [];
  List<Content>? lastContent;
  GenerationConfig? lastConfig;
  int callCount = 0;

  ModelCall get call => (content, config) async {
        callCount++;
        lastContent = content;
        lastConfig = config;
        if (responder != null) {
          return responder!(content, config);
        }
        if (errors.isNotEmpty) {
          throw errors.removeAt(0);
        }
        if (responses.isNotEmpty) {
          return responses.removeAt(0);
        }
        return textResponse('Water it weekly.');
      };
}

GenerateContentResponse textResponse(String text) {
  return GenerateContentResponse(
    [Candidate(Content('model', [TextPart(text)]), null, null, null, null)],
    null,
  );
}

GenerateContentResponse jsonResponse(String json) {
  return GenerateContentResponse(
    [Candidate(Content.text(json), null, null, FinishReason.stop, null)],
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

ChatRequest buildChatRequest({int messageCount = 3}) {
  return ChatRequest(
    plantName: 'Smoke Fern',
    species: 'Nephrolepis exaltata',
    light: 'Partial shade',
    humidity: 60,
    location: 'Living room',
    careSchedule: const {
      'wateringFrequency': 7,
      'fertilizing': 'monthly',
    },
    healthLogs: const [
      {'type': 'issue', 'description': 'brown tips'},
    ],
    notes: 'Repotted in spring.',
    messages: List.generate(messageCount, (index) {
      return ChatMessage(
        role: index.isEven ? 'user' : 'assistant',
        text: 'Message $index',
      );
    }),
  );
}

ScheduleRequest buildScheduleRequest() {
  return ScheduleRequest(
    species: 'Monstera deliciosa',
    light: 'Bright indirect',
    humidity: 60,
    location: 'Living room',
    careSchedule: const {
      'wateringFrequency': 7,
      'fertilizingEnabled': true,
      'fertilizingFrequency': 30,
      'mistingEnabled': false,
      'mistingFrequency': 3,
      'rotatingEnabled': false,
      'rotatingFrequency': 7,
    },
  );
}

ReminderTextRequest buildReminderRequest() {
  return ReminderTextRequest(
    careSchedule: const {
      'wateringFrequency': 7,
      'fertilizingEnabled': true,
      'fertilizingFrequency': 30,
      'mistingEnabled': false,
      'mistingFrequency': 3,
      'rotatingEnabled': false,
      'rotatingFrequency': 7,
    },
  );
}

SummaryRequest buildSummaryRequest() {
  return SummaryRequest(
    plantName: 'Monstera',
    species: 'Monstera deliciosa',
    humidity: 60,
    light: 'Bright indirect',
    location: 'Living room',
    careNotes: 'Likes a moss pole.',
    careSchedule: const {'wateringFrequency': 7},
    healthLogs: [
      HealthLogEntry(
        type: 'watering',
        title: 'Watering',
        description: 'Soaked thoroughly until drainage',
        date: DateTime(2026, 8, 10),
      ),
    ],
  );
}

void main() {
  late ConnectivityPlatform originalPlatform;
  late RecordingModelCall recorder;
  late GeminiPlantAiService service;

  setUp(() {
    originalPlatform = ConnectivityPlatform.instance;
    ConnectivityPlatform.instance = FakeConnectivityPlatform();
    recorder = RecordingModelCall();
    service = GeminiPlantAiService(modelCall: recorder.call);
  });

  tearDown(() {
    ConnectivityPlatform.instance = originalPlatform;
  });

  group('diagnosePlant prompt assembly', () {
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

  group('chatAboutPlant prompt assembly', () {
    test('sends a system prompt grounded in the request and a full history',
        () async {
      final reply = await service.chatAboutPlant(buildChatRequest());

      expect(reply, 'Water it weekly.');
      expect(recorder.lastContent, hasLength(4));

      final system = recorder.lastContent!.first;
      expect(system.role, 'system');
      final systemText = (system.parts.first as TextPart).text;
      expect(systemText, contains('Smoke Fern'));
      expect(systemText, contains('Nephrolepis exaltata'));
      expect(systemText, contains('Partial shade'));
      expect(systemText, contains('60%'));
      expect(systemText, contains('Living room'));
      expect(systemText, contains('wateringFrequency: 7'));
      expect(systemText, contains('fertilizing: monthly'));
      expect(systemText, contains('brown tips'));
      expect(systemText, contains('Repotted in spring.'));

      final history = recorder.lastContent!.sublist(1);
      expect(history[0].role, 'user');
      expect((history[0].parts.first as TextPart).text, 'Message 0');
      expect(history[1].role, 'model');
      expect((history[1].parts.first as TextPart).text, 'Message 1');
      expect(history[2].role, 'user');
      expect((history[2].parts.first as TextPart).text, 'Message 2');
    });

    test('truncates the history to the last 12 messages', () async {
      await service.chatAboutPlant(buildChatRequest(messageCount: 18));

      expect(recorder.lastContent, hasLength(13));

      final history = recorder.lastContent!.sublist(1);
      expect(history, hasLength(12));
      expect((history.first.parts.first as TextPart).text, 'Message 6');
      expect((history.last.parts.first as TextPart).text, 'Message 17');
    });

    test('omits empty grounding sections from the system prompt', () async {
      await service.chatAboutPlant(
        const ChatRequest(plantName: 'Cactus'),
      );

      final system = recorder.lastContent!.first;
      final systemText = (system.parts.first as TextPart).text;
      expect(systemText, contains('Name: Cactus'));
      expect(systemText, contains('No care schedule set.'));
      expect(systemText, contains('No health logs yet.'));
      expect(systemText, contains('No additional notes.'));
      expect(systemText, isNot(contains('Species:')));
    });

    test('uses the chat model configuration for the generation call',
        () async {
      await service.chatAboutPlant(buildChatRequest());

      expect(
        recorder.lastConfig!.temperature,
        plantAiFeatureConfigs['chat']!.temperature,
      );
      expect(
        recorder.lastConfig!.maxOutputTokens,
        plantAiFeatureConfigs['chat']!.maxOutputTokens,
      );
    });
  });

  group('suggestWateringSchedule prompt assembly', () {
    test('sends the grounded schedule prompt with a JSON schema config',
        () async {
      recorder.responses.add(jsonResponse('{"wateringFrequency": 5}'));

      await service.suggestWateringSchedule(buildScheduleRequest());

      expect(recorder.callCount, 1);
      final content = recorder.lastContent!;
      expect(content, hasLength(1));
      final prompt = (content.single.parts.single as TextPart).text;
      expect(prompt, contains('Monstera deliciosa'));
      expect(prompt, contains('Bright indirect'));
      expect(prompt, contains('60'));
      expect(prompt, contains('Living room'));
      expect(prompt, contains('wateringFrequency'));
      final config = recorder.lastConfig!;
      expect(config.temperature, 0.5);
      expect(config.maxOutputTokens, 1024);
      expect(config.responseMimeType, 'application/json');
      expect(config.responseSchema, isNotNull);
    });

    test('parses a valid JSON suggestion', () async {
      recorder.responses.add(jsonResponse(jsonEncode({
            'wateringFrequency': 10,
            'fertilizingEnabled': true,
            'fertilizingFrequency': 45,
            'mistingEnabled': true,
            'mistingFrequency': 2,
            'rotatingEnabled': true,
            'rotatingFrequency': 14,
            'reason': 'Bright light dries the soil faster',
          })));

      final suggestion =
          await service.suggestWateringSchedule(buildScheduleRequest());

      expect(suggestion.wateringFrequency, 10);
      expect(suggestion.fertilizingEnabled, isTrue);
      expect(suggestion.fertilizingFrequency, 45);
      expect(suggestion.mistingEnabled, isTrue);
      expect(suggestion.mistingFrequency, 2);
      expect(suggestion.rotatingEnabled, isTrue);
      expect(suggestion.rotatingFrequency, 14);
      expect(suggestion.reason, 'Bright light dries the soil faster');
    });

    test('applies tolerant defaults when optional fields are missing',
        () async {
      recorder.responses.add(jsonResponse('{"wateringFrequency": 4}'));

      final suggestion =
          await service.suggestWateringSchedule(buildScheduleRequest());

      expect(suggestion.wateringFrequency, 4);
      expect(suggestion.fertilizingEnabled, isFalse);
      expect(suggestion.fertilizingFrequency, 30);
      expect(suggestion.mistingEnabled, isFalse);
      expect(suggestion.mistingFrequency, 3);
      expect(suggestion.rotatingEnabled, isFalse);
      expect(suggestion.rotatingFrequency, 7);
      expect(suggestion.reason, isNull);
    });

    test('throws MalformedOutputError when the model returns non-JSON text',
        () async {
      recorder.responses.add(textResponse('sure, water it weekly'));

      expect(
        () => service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when the JSON is not an object',
        () async {
      recorder.responses.add(jsonResponse('[1, 2, 3]'));

      expect(
        () => service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when the watering frequency is invalid',
        () async {
      recorder.responses.add(jsonResponse('{"fertilizingEnabled": true}'));

      expect(
        () => service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws BlockedError when the response is blocked', () async {
      recorder.errors
          .add(FirebaseAIException('Response was blocked due to safety'));

      expect(
        () => service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<BlockedError>()),
      );
    });
  });

  group('reminderTextFor', () {
    test('sends the reminder prompt with a plain text config', () async {
      recorder.responses
          .add(textResponse('Monstera is thirsty — water it today!'));

      final text = await service.reminderTextFor(buildReminderRequest());

      expect(text, 'Monstera is thirsty — water it today!');
      final content = recorder.lastContent!;
      final prompt = (content.single.parts.single as TextPart).text;
      expect(prompt, contains('wateringFrequency'));
      expect(prompt, contains('7'));
      final config = recorder.lastConfig!;
      expect(config.temperature, 0.8);
      expect(config.maxOutputTokens, 256);
      expect(config.responseMimeType, isNull);
      expect(config.responseSchema, isNull);
    });
  });

  group('summarizeHealthLogs prompt assembly', () {
    test('assembles a grounded prompt with the profile and log entries',
        () async {
      recorder.responses.add(textResponse(_validSummaryJson));

      final summary = await service.summarizeHealthLogs(buildSummaryRequest());

      expect(summary.overallHealth, 'Healthy and growing steadily.');
      final prompt =
          (recorder.lastContent!.single.parts.single as TextPart).text;
      expect(prompt, contains('Monstera'));
      expect(prompt, contains('Monstera deliciosa'));
      expect(prompt, contains('Living room'));
      expect(prompt, contains('60%'));
      expect(prompt, contains('Bright indirect'));
      expect(prompt, contains('wateringFrequency: 7'));
      expect(prompt, contains('Soaked thoroughly until drainage'));
      expect(prompt, contains('2026-08-10'));
    });

    test('sends the summary model config with JSON schema', () async {
      recorder.responses.add(textResponse(_validSummaryJson));

      await service.summarizeHealthLogs(buildSummaryRequest());

      final config = recorder.lastConfig!;
      expect(config.temperature, 0.4);
      expect(config.maxOutputTokens, 1024);
      expect(config.responseMimeType, 'application/json');
      expect(config.responseSchema, isNotNull);
    });

    test('limits long histories to the newest 40 entries', () async {
      final entries = List.generate(
        45,
        (i) => HealthLogEntry(
          type: 'watering',
          title: 'Watering',
          description: 'Entry $i',
          date: DateTime(2026, 1, 1).add(Duration(days: i)),
        ),
      );
      recorder.responses.add(textResponse(_validSummaryJson));

      await service.summarizeHealthLogs(
        SummaryRequest(plantName: 'Monstera', healthLogs: entries),
      );

      final prompt =
          (recorder.lastContent!.single.parts.single as TextPart).text;
      expect(prompt, contains('5 older entries omitted'));
      expect(prompt, isNot(contains('Entry 0')));
      expect(prompt, contains('Entry 44'));
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

    test('parses a well-formed summary response', () async {
      recorder.responses.add(textResponse(_validSummaryJson));

      final summary = await service.summarizeHealthLogs(buildSummaryRequest());

      expect(summary.overallHealth, 'Healthy and growing steadily.');
      expect(summary.notableChanges, [
        'New leaf unfurled',
        'Moved to a brighter spot',
      ]);
      expect(summary.anomalies, ['Two yellowing lower leaves']);
      expect(summary.suggestions, [
        'Water when the top two centimetres are dry',
      ]);
    });

    test('tolerates missing optional summary fields', () async {
      recorder.responses.add(textResponse('{"overallHealth":"Doing well."}'));

      final summary = await service.summarizeHealthLogs(buildSummaryRequest());

      expect(summary.overallHealth, 'Doing well.');
      expect(summary.notableChanges, isEmpty);
      expect(summary.anomalies, isEmpty);
      expect(summary.suggestions, isEmpty);
    });

    test('throws MalformedOutputError when the summary is not valid JSON',
        () async {
      recorder.responses.add(textResponse('definitely not json'));

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when the summary is not an object',
        () async {
      recorder.responses.add(textResponse('["overallHealth"]'));

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when overallHealth is missing',
        () async {
      recorder.responses.add(textResponse('{"suggestions":["Water more."]}'));

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when the summary has no text', () async {
      recorder.responses.add(GenerateContentResponse(const [], null));

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });
  });

  group('HealthLogSummary.fromJson', () {
    test('parses a valid fixture', () {
      final summary = HealthLogSummary.fromJson(
        {
          'overallHealth': 'Doing well.',
          'notableChanges': ['New growth'],
          'anomalies': ['Browning tips'],
          'suggestions': ['Repot soon'],
        },
      );

      expect(summary.overallHealth, 'Doing well.');
      expect(summary.notableChanges, ['New growth']);
      expect(summary.anomalies, ['Browning tips']);
      expect(summary.suggestions, ['Repot soon']);
    });

    test('defaults missing optional lists to empty', () {
      final summary = HealthLogSummary.fromJson({
        'overallHealth': 'Doing well.',
      });

      expect(summary.notableChanges, isEmpty);
      expect(summary.anomalies, isEmpty);
      expect(summary.suggestions, isEmpty);
    });

    test('rejects a non-string overallHealth', () {
      expect(
        () => HealthLogSummary.fromJson({'overallHealth': 42}),
        throwsFormatException,
      );
    });

    test('rejects a missing overallHealth', () {
      expect(
        () => HealthLogSummary.fromJson({'anomalies': <String>[]}),
        throwsFormatException,
      );
    });

    test('rejects list items that are not strings', () {
      expect(
        () => HealthLogSummary.fromJson({
          'overallHealth': 'Doing well.',
          'anomalies': [1, 2],
        }),
        throwsFormatException,
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

    test('maps a quota exceeded chat failure to QuotaExceededError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => throw QuotaExceeded('quota exceeded'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(buildChatRequest()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('maps a quota limited schedule call to QuotaExceededError', () async {
      recorder.errors.add(QuotaExceeded('Quota exhausted for project'));

      expect(
        () => service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('maps a quota limited reminder call to QuotaExceededError', () async {
      recorder.errors.add(QuotaExceeded('Quota exhausted for project'));

      expect(
        () => service.reminderTextFor(buildReminderRequest()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('maps a quota limited summary call to QuotaExceededError', () async {
      recorder.errors.add(QuotaExceeded('Quota exceeded'));

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('maps a resource exhausted message to QuotaExceededError', () async {
      recorder.errors.add(FirebaseAIException(
        'RESOURCE_EXHAUSTED: monthly free-tier quota reached',
      ));

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
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

    test('maps a blocked summary exception to BlockedError', () async {
      recorder.errors
          .add(FirebaseAIException('Response was blocked due to safety'));

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
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

    test('maps a schedule timeout to TimeoutError', () async {
      recorder.errors.add(TimeoutException('took too long'));

      expect(
        () => service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<TimeoutError>()),
      );
    });

    test('maps a summary timeout to TimeoutError', () async {
      recorder.errors.add(TimeoutException('timed out'));

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<TimeoutError>()),
      );
    });

    test('maps a connection failure to OfflineError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) =>
            throw http.ClientException('Connection failed'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(buildChatRequest()),
        throwsA(isA<OfflineError>()),
      );
    });

    test('maps a chat timeout to TimeoutError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => throw TimeoutException('took too long'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(buildChatRequest()),
        throwsA(isA<TimeoutError>()),
      );
    });

    test('maps a safety-blocked chat response to BlockedError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => Future.value(blockedResponse()),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(buildChatRequest()),
        throwsA(isA<BlockedError>()),
      );
    });

    test('maps a blocked chat FirebaseAIException to BlockedError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) =>
            throw FirebaseAIException('Candidate was blocked due to safety'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(buildChatRequest()),
        throwsA(isA<BlockedError>()),
      );
    });

    test('maps an empty chat response to MalformedOutputError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) =>
            Future.value(GenerateContentResponse(const [], null)),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(buildChatRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('maps an unknown model failure to UnknownError', () async {
      recorder.errors.add(StateError('boom'));

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<UnknownError>()),
      );
    });

    test('maps an unexpected chat failure to UnknownError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => throw Exception('boom'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(buildChatRequest()),
        throwsA(isA<UnknownError>()),
      );
    });

    test('maps a generic server failure to UnknownError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => throw ServerException('server error'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(buildChatRequest()),
        throwsA(isA<UnknownError>()),
      );
    });

    test('maps an unclassified schedule failure to UnknownError', () async {
      recorder.errors.add(StateError('boom'));

      expect(
        () => service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<UnknownError>()),
      );
    });

    test('maps an unknown summary failure to UnknownError', () async {
      recorder.errors.add(StateError('boom'));

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<UnknownError>()),
      );
    });

    test('passes PlantAiException from the model call through unchanged',
        () async {
      recorder.errors.add(const MalformedOutputError());

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('trims whitespace from the chat reply text', () async {
      recorder = RecordingModelCall(
        responder: (content, config) =>
            Future.value(textResponse('  Water weekly.  ')),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      final reply = await service.chatAboutPlant(buildChatRequest());
      expect(reply, 'Water weekly.');
    });
  });

  group('offline handling', () {
    test('throws OfflineError before calling the model when offline',
        () async {
      ConnectivityPlatform.instance =
          FakeConnectivityPlatform(isOffline: true);

      expect(
        () => service.diagnosePlant(buildRequest()),
        throwsA(isA<OfflineError>()),
      );
      expect(recorder.callCount, 0);
    });

    test('skips the schedule model call when offline', () async {
      ConnectivityPlatform.instance =
          FakeConnectivityPlatform(isOffline: true);

      expect(
        () => service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<OfflineError>()),
      );
      expect(recorder.callCount, 0);
    });

    test('skips the reminder model call when offline', () async {
      ConnectivityPlatform.instance =
          FakeConnectivityPlatform(isOffline: true);

      expect(
        () => service.reminderTextFor(buildReminderRequest()),
        throwsA(isA<OfflineError>()),
      );
      expect(recorder.callCount, 0);
    });

    test('skips the summary model call when offline', () async {
      ConnectivityPlatform.instance =
          FakeConnectivityPlatform(isOffline: true);

      expect(
        () => service.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<OfflineError>()),
      );
      expect(recorder.callCount, 0);
    });

    test('reports unavailable when offline', () async {
      ConnectivityPlatform.instance =
          FakeConnectivityPlatform(isOffline: true);

      expect(await service.isAvailable(), isFalse);
    });
  });

  group('ScheduleSuggestion', () {
    test('toCareScheduleMap returns the schedule fields', () {
      final suggestion = ScheduleSuggestion(
        wateringFrequency: 9,
        fertilizingEnabled: true,
        fertilizingFrequency: 40,
        mistingEnabled: true,
        mistingFrequency: 4,
        rotatingEnabled: false,
        rotatingFrequency: 7,
      );

      final map = suggestion.toCareScheduleMap();

      expect(map['wateringFrequency'], 9);
      expect(map['fertilizingEnabled'], isTrue);
      expect(map['fertilizingFrequency'], 40);
      expect(map['mistingEnabled'], isTrue);
      expect(map['mistingFrequency'], 4);
      expect(map['rotatingEnabled'], isFalse);
      expect(map['rotatingFrequency'], 7);
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

    test('chatAboutPlant throws UnknownError', () async {
      const stub = StubPlantAiService();

      expect(
        () => stub.chatAboutPlant(const ChatRequest(plantName: 'Cactus')),
        throwsA(isA<UnknownError>()),
      );
    });

    test('suggestWateringSchedule throws UnsupportedError', () async {
      const stub = StubPlantAiService();

      expect(
        () => stub.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('reminderTextFor throws UnsupportedError', () async {
      const stub = StubPlantAiService();

      expect(
        () => stub.reminderTextFor(buildReminderRequest()),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('summarizeHealthLogs throws UnsupportedError', () async {
      const stub = StubPlantAiService();

      expect(
        () => stub.summarizeHealthLogs(buildSummaryRequest()),
        throwsA(isA<UnsupportedError>()),
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

const String _validSummaryJson = '''
{
  "overallHealth": "Healthy and growing steadily.",
  "notableChanges": ["New leaf unfurled", "Moved to a brighter spot"],
  "anomalies": ["Two yellowing lower leaves"],
  "suggestions": ["Water when the top two centimetres are dry"]
}
''';