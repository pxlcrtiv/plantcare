import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare/services/plant_ai_service.dart';

class FakeConnectivityPlatform extends ConnectivityPlatform {
  FakeConnectivityPlatform({this.results = const [ConnectivityResult.wifi]});

  List<ConnectivityResult> results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

class RecordingModel {
  RecordingModel({this.onCall});

  Future<GenerateContentResponse> Function(
    List<Content> content,
    GenerationConfig config,
  )? onCall;

  List<Content>? lastContent;
  GenerationConfig? lastConfig;
  int callCount = 0;

  Future<GenerateContentResponse> call(
    List<Content> content,
    GenerationConfig config,
  ) {
    lastContent = content;
    lastConfig = config;
    callCount++;
    return onCall!(content, config);
  }
}

GenerateContentResponse jsonResponse(String json) {
  return GenerateContentResponse(
    [Candidate(Content.text(json), null, null, FinishReason.stop, null)],
    null,
  );
}

GenerateContentResponse textResponse(String text) {
  return GenerateContentResponse(
    [Candidate(Content.text(text), null, null, FinishReason.stop, null)],
    null,
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

void main() {
  late ConnectivityPlatform originalPlatform;
  late RecordingModel recording;

  setUpAll(() {
    originalPlatform = ConnectivityPlatform.instance;
  });

  setUp(() {
    ConnectivityPlatform.instance = FakeConnectivityPlatform();
    recording = RecordingModel();
  });

  tearDown(() {
    ConnectivityPlatform.instance = originalPlatform;
  });

  GeminiPlantAiService buildService() {
    return GeminiPlantAiService(
      modelCall: recording.call,
      connectivity: Connectivity(),
    );
  }

  group('GeminiPlantAiService.suggestWateringSchedule', () {
    test('sends the grounded schedule prompt with a JSON schema config',
        () async {
      recording.onCall = (content, config) async =>
          jsonResponse('{"wateringFrequency": 5}');
      final service = buildService();

      await service.suggestWateringSchedule(buildScheduleRequest());

      expect(recording.callCount, 1);
      final content = recording.lastContent!;
      expect(content, hasLength(1));
      final prompt = (content.single.parts.single as TextPart).text;
      expect(prompt, contains('Monstera deliciosa'));
      expect(prompt, contains('Bright indirect'));
      expect(prompt, contains('60'));
      expect(prompt, contains('Living room'));
      expect(prompt, contains('wateringFrequency'));
      final config = recording.lastConfig!;
      expect(config.temperature, 0.5);
      expect(config.maxOutputTokens, 1024);
      expect(config.responseMimeType, 'application/json');
      expect(config.responseSchema, isNotNull);
    });

    test('parses a valid JSON suggestion', () async {
      recording.onCall = (content, config) async => jsonResponse(jsonEncode({
            'wateringFrequency': 10,
            'fertilizingEnabled': true,
            'fertilizingFrequency': 45,
            'mistingEnabled': true,
            'mistingFrequency': 2,
            'rotatingEnabled': true,
            'rotatingFrequency': 14,
            'reason': 'Bright light dries the soil faster',
          }));
      final service = buildService();

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
      recording.onCall = (content, config) async =>
          jsonResponse('{"wateringFrequency": 4}');
      final service = buildService();

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
      recording.onCall = (content, config) async =>
          textResponse('sure, water it weekly');
      final service = buildService();

      await expectLater(
        service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when the JSON is not an object',
        () async {
      recording.onCall = (content, config) async => jsonResponse('[1, 2, 3]');
      final service = buildService();

      await expectLater(
        service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when the watering frequency is invalid',
        () async {
      recording.onCall = (content, config) async =>
          jsonResponse('{"fertilizingEnabled": true}');
      final service = buildService();

      await expectLater(
        service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws QuotaExceededError when the model call is quota limited',
        () async {
      recording.onCall = (content, config) async =>
          throw QuotaExceeded('Quota exhausted for project');
      final service = buildService();

      await expectLater(
        service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('throws BlockedError when the response is blocked', () async {
      recording.onCall = (content, config) async =>
          throw FirebaseAIException('Response was blocked due to safety');
      final service = buildService();

      await expectLater(
        service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<BlockedError>()),
      );
    });

    test('throws TimeoutError when the model call times out', () async {
      recording.onCall = (content, config) async =>
          throw TimeoutException('timed out');
      final service = buildService();

      await expectLater(
        service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<TimeoutError>()),
      );
    });

    test('throws OfflineError without calling the model when offline',
        () async {
      ConnectivityPlatform.instance =
          FakeConnectivityPlatform(results: [ConnectivityResult.none]);
      final service = buildService();

      await expectLater(
        service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<OfflineError>()),
      );
      expect(recording.callCount, 0);
    });

    test('throws UnknownError for unclassified failures', () async {
      recording.onCall = (content, config) async => throw StateError('boom');
      final service = buildService();

      await expectLater(
        service.suggestWateringSchedule(buildScheduleRequest()),
        throwsA(isA<UnknownError>()),
      );
    });
  });

  group('GeminiPlantAiService.reminderTextFor', () {
    test('sends the reminder prompt with a plain text config', () async {
      recording.onCall = (content, config) async =>
          textResponse('Monstera is thirsty — water it today!');
      final service = buildService();

      final text = await service.reminderTextFor(buildReminderRequest());

      expect(text, 'Monstera is thirsty — water it today!');
      final content = recording.lastContent!;
      final prompt = (content.single.parts.single as TextPart).text;
      expect(prompt, contains('wateringFrequency'));
      expect(prompt, contains('7'));
      final config = recording.lastConfig!;
      expect(config.temperature, 0.8);
      expect(config.maxOutputTokens, 256);
      expect(config.responseMimeType, isNull);
      expect(config.responseSchema, isNull);
    });

    test('throws QuotaExceededError when the model call is quota limited',
        () async {
      recording.onCall = (content, config) async =>
          throw QuotaExceeded('Quota exhausted for project');
      final service = buildService();

      await expectLater(
        service.reminderTextFor(buildReminderRequest()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('throws OfflineError without calling the model when offline',
        () async {
      ConnectivityPlatform.instance =
          FakeConnectivityPlatform(results: [ConnectivityResult.none]);
      final service = buildService();

      await expectLater(
        service.reminderTextFor(buildReminderRequest()),
        throwsA(isA<OfflineError>()),
      );
      expect(recording.callCount, 0);
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
}