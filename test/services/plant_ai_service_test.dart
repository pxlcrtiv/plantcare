import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare/services/plant_ai_service.dart';

const _validSummaryJson = '''
{
  "overallHealth": "Healthy and growing steadily.",
  "notableChanges": ["New leaf unfurled", "Moved to a brighter spot"],
  "anomalies": ["Two yellowing lower leaves"],
  "suggestions": ["Water when the top two centimetres are dry"]
}
''';

GenerateContentResponse _jsonResponse(String body) {
  return GenerateContentResponse(
    [
      Candidate(
        Content('model', [TextPart(body)]),
        null,
        null,
        null,
        null,
      ),
    ],
    null,
  );
}

GeminiPlantAiService buildService(
  Future<GenerateContentResponse> Function(
    List<Content> content,
    GenerationConfig config,
  ) modelCall, {
  bool offline = false,
}) {
  return GeminiPlantAiService(
    modelCall: modelCall,
    checkOffline: () async => offline,
  );
}

SummaryRequest buildRequest() {
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
  group('GeminiPlantAiService summarizeHealthLogs', () {
    test('assembles a grounded prompt with the profile and log entries',
        () async {
      List<Content>? capturedContent;
      final service = buildService((content, config) async {
        capturedContent = content;
        return _jsonResponse(_validSummaryJson);
      });

      final summary = await service.summarizeHealthLogs(buildRequest());

      expect(summary.overallHealth, 'Healthy and growing steadily.');
      final prompt =
          (capturedContent!.single.parts.single as TextPart).text;
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
      GenerationConfig? capturedConfig;
      final service = buildService((content, config) async {
        capturedConfig = config;
        return _jsonResponse(_validSummaryJson);
      });

      await service.summarizeHealthLogs(buildRequest());

      expect(capturedConfig!.temperature, 0.4);
      expect(capturedConfig!.maxOutputTokens, 1024);
      expect(capturedConfig!.responseMimeType, 'application/json');
      expect(capturedConfig!.responseSchema, isNotNull);
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
      String? prompt;
      final service = buildService((content, config) async {
        prompt = (content.single.parts.single as TextPart).text;
        return _jsonResponse(_validSummaryJson);
      });

      await service.summarizeHealthLogs(
        SummaryRequest(plantName: 'Monstera', healthLogs: entries),
      );

      expect(prompt, contains('5 older entries omitted'));
      expect(prompt, isNot(contains('Entry 0')));
      expect(prompt, contains('Entry 44'));
    });

    test('throws OfflineError without calling the model when offline',
        () async {
      var modelCalls = 0;
      final service = buildService(
        (content, config) async {
          modelCalls++;
          return _jsonResponse(_validSummaryJson);
        },
        offline: true,
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(isA<OfflineError>()),
      );
      expect(modelCalls, 0);
    });
  });

  group('summary parsing', () {
    test('parses a well-formed summary response', () async {
      final service = buildService(
        (content, config) async => _jsonResponse(_validSummaryJson),
      );

      final summary = await service.summarizeHealthLogs(buildRequest());

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

    test('tolerates missing optional fields', () async {
      final service = buildService(
        (content, config) async => _jsonResponse('{"overallHealth":"Doing well."}'),
      );

      final summary = await service.summarizeHealthLogs(buildRequest());

      expect(summary.overallHealth, 'Doing well.');
      expect(summary.notableChanges, isEmpty);
      expect(summary.anomalies, isEmpty);
      expect(summary.suggestions, isEmpty);
    });

    test('throws MalformedOutputError when the output is not valid JSON',
        () async {
      final service = buildService(
        (content, config) async => _jsonResponse('definitely not json'),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when the output is not a JSON object',
        () async {
      final service = buildService(
        (content, config) async => _jsonResponse('["overallHealth"]'),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when overallHealth is missing',
        () async {
      final service = buildService(
        (content, config) async =>
            _jsonResponse('{"suggestions":["Water more."]}'),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('throws MalformedOutputError when the model returns no text',
        () async {
      final service = buildService(
        (content, config) async =>
            GenerateContentResponse(const [], null),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
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

  group('error taxonomy mapping', () {
    test('maps QuotaExceeded to QuotaExceededError', () async {
      final service = buildService(
        (content, config) async => throw QuotaExceeded('Quota exceeded'),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('maps a resource exhausted message to QuotaExceededError',
        () async {
      final service = buildService(
        (content, config) async => throw FirebaseAIException(
          'RESOURCE_EXHAUSTED: monthly free-tier quota reached',
        ),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('maps a blocked response to BlockedError', () async {
      final service = buildService(
        (content, config) async =>
            throw FirebaseAIException('Response was blocked due to safety'),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(isA<BlockedError>()),
      );
    });

    test('maps a TimeoutException to TimeoutError', () async {
      final service = buildService(
        (content, config) async => throw TimeoutException('timed out'),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(isA<TimeoutError>()),
      );
    });

    test('maps an unknown failure to UnknownError', () async {
      final service = buildService(
        (content, config) async => throw StateError('boom'),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(isA<UnknownError>()),
      );
    });

    test('passes PlantAiException from the model call through unchanged',
        () async {
      final service = buildService(
        (content, config) async =>
            throw const MalformedOutputError('already typed'),
      );

      expect(
        () => service.summarizeHealthLogs(buildRequest()),
        throwsA(
          isA<MalformedOutputError>().having(
            (e) => e.message,
            'message',
            'already typed',
          ),
        ),
      );
    });
  });
}