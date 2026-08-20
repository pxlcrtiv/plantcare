import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare/services/plant_ai_model_call.dart';
import 'package:plantcare/services/plant_ai_service.dart';

GenerateContentResponse _response(String text) => GenerateContentResponse(
      [Candidate(Content('user', [TextPart(text)]), null, null,
          FinishReason.stop, null)],
      null,
    );

void main() {
  group('fallbackModelCall', () {
    test('returns the first model response when it succeeds', () async {
      var firstCalls = 0;
      var secondCalls = 0;
      final first = (List<Content> content, GenerationConfig config) async {
        firstCalls++;
        return _response('first');
      };
      final second = (List<Content> content, GenerationConfig config) async {
        secondCalls++;
        return _response('second');
      };

      final call = fallbackModelCall([first, second]);
      final response = await call([], GenerationConfig());

      expect(response.text, 'first');
      expect(firstCalls, 1);
      expect(secondCalls, 0);
    });

    test('falls back to the next model on high-demand overload', () async {
      var healthyCalls = 0;
      final overloaded = (List<Content> content, GenerationConfig config) async {
        throw FirebaseAIException(
            'Server Error [500]: This model is currently experiencing high demand.');
      };
      final healthy = (List<Content> content, GenerationConfig config) async {
        healthyCalls++;
        return _response('ok');
      };

      final call = fallbackModelCall([overloaded, healthy]);
      final response = await call([], GenerationConfig());

      expect(response.text, 'ok');
      expect(healthyCalls, 1);
    });

    test('walks the whole chain and rethrows the last overload error',
        () async {
      final a = (List<Content> content, GenerationConfig config) async {
        throw FirebaseAIException('Server Error [500]: high demand');
      };
      final b = (List<Content> content, GenerationConfig config) async {
        throw FirebaseAIException('Server Error [500]: INTERNAL');
      };
      final c = (List<Content> content, GenerationConfig config) async {
        throw FirebaseAIException('Server Error [500]: high demand');
      };

      final call = fallbackModelCall([a, b, c]);

      expect(
        () => call([], GenerationConfig()),
        throwsA(isA<FirebaseAIException>()),
      );
    });

    test('rethrows non-transient errors immediately without falling back',
        () async {
      var fallbackCalls = 0;
      final badKey = (List<Content> content, GenerationConfig config) async {
        throw FirebaseAIException(
            'API key not valid. Please pass a valid API key.');
      };
      final fallback = (List<Content> content, GenerationConfig config) async {
        fallbackCalls++;
        return _response('never');
      };

      final call = fallbackModelCall([badKey, fallback]);

      expect(
        () => call([], GenerationConfig()),
        throwsA(isA<FirebaseAIException>()),
      );
      expect(fallbackCalls, 0);
    });

    test('plantAiModelCall builds a working ModelCall', () {
      expect(plantAiModelCall(), isA<ModelCall>());
    });
  });
}