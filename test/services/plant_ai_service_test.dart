import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:plantcare/services/plant_ai_service.dart';

class RecordingModelCall {
  RecordingModelCall({this.responder});

  final Future<GenerateContentResponse> Function(List<Content>, GenerationConfig)?
      responder;
  List<Content>? lastContent;
  GenerationConfig? lastConfig;

  Future<GenerateContentResponse> call(
    List<Content> content,
    GenerationConfig config,
  ) {
    lastContent = content;
    lastConfig = config;
    if (responder != null) {
      return responder!(content, config);
    }
    return Future.value(_textResponse('Water it weekly.'));
  }
}

GenerateContentResponse _textResponse(String text) {
  return GenerateContentResponse(
    [
      Candidate(
        Content('model', [TextPart(text)]),
        null,
        null,
        FinishReason.stop,
        null,
      ),
    ],
    null,
  );
}

GenerateContentResponse _blockedResponse() {
  return GenerateContentResponse(
    const [],
    PromptFeedback(BlockReason.safety, 'blocked message', const []),
  );
}

ChatRequest _request({
  int messageCount = 3,
}) {
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

void main() {
  late RecordingModelCall recorder;
  late GeminiPlantAiService service;

  setUp(() {
    recorder = RecordingModelCall();
    service = GeminiPlantAiService(modelCall: recorder.call);
  });

  group('chatAboutPlant prompt assembly', () {
    test('sends a system prompt grounded in the request and a full history',
        () async {
      final reply = await service.chatAboutPlant(_request());

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
      await service.chatAboutPlant(_request(messageCount: 18));

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
      await service.chatAboutPlant(_request());

      expect(recorder.lastConfig!.temperature, plantAiChatTemperature);
      expect(recorder.lastConfig!.maxOutputTokens, plantAiChatMaxOutputTokens);
    });
  });

  group('chatAboutPlant error mapping', () {
    test('maps a quota exceeded failure to QuotaExceededError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => throw QuotaExceeded('quota exceeded'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(_request()),
        throwsA(isA<QuotaExceededError>()),
      );
    });

    test('maps a connection failure to OfflineError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => throw http.ClientException('Connection failed'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(_request()),
        throwsA(isA<OfflineError>()),
      );
    });

    test('maps a timeout to TimeoutError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => throw TimeoutException('took too long'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(_request()),
        throwsA(isA<TimeoutError>()),
      );
    });

    test('maps a safety-blocked response to BlockedError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => Future.value(_blockedResponse()),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(_request()),
        throwsA(isA<BlockedError>()),
      );
    });

    test('maps a blocked FirebaseAIException to BlockedError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) =>
            throw FirebaseAIException('Candidate was blocked due to safety'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(_request()),
        throwsA(isA<BlockedError>()),
      );
    });

    test('maps an empty response to MalformedOutputError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => Future.value(
          GenerateContentResponse(const [], null),
        ),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(_request()),
        throwsA(isA<MalformedOutputError>()),
      );
    });

    test('maps an unexpected failure to UnknownError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => throw Exception('boom'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(_request()),
        throwsA(isA<UnknownError>()),
      );
    });

    test('maps a generic server failure to UnknownError', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => throw ServerException('server error'),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      expect(
        () => service.chatAboutPlant(_request()),
        throwsA(isA<UnknownError>()),
      );
    });

    test('trims whitespace from the reply text', () async {
      recorder = RecordingModelCall(
        responder: (content, config) => Future.value(_textResponse('  Water weekly.  ')),
      );
      service = GeminiPlantAiService(modelCall: recorder.call);

      final reply = await service.chatAboutPlant(_request());
      expect(reply, 'Water weekly.');
    });
  });

  group('StubPlantAiService', () {
    test('is never available', () async {
      expect(await const StubPlantAiService().isAvailable(), isFalse);
    });

    test('throws UnknownError for chat requests', () async {
      expect(
        () => const StubPlantAiService().chatAboutPlant(
          const ChatRequest(plantName: 'Cactus'),
        ),
        throwsA(isA<UnknownError>()),
      );
    });
  });
}