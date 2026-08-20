import 'package:firebase_ai/firebase_ai.dart';

import 'plant_ai_service.dart';

const List<String> plantAiModelFallbackOrder = [
  'gemini-3.7-flash',
  'gemini-3.6-flash',
  'gemini-3.5-flash',
  'gemini-3.1-flash',
];

ModelCall plantAiModelCall() => fallbackModelCall([
      for (final name in plantAiModelFallbackOrder)
        (content, config) => FirebaseAI.googleAI()
            .generativeModel(model: name)
            .generateContent(content, generationConfig: config),
    ]);

ModelCall fallbackModelCall(List<ModelCall> modelCalls) {
  return (List<Content> content, GenerationConfig config) async {
    FirebaseAIException? lastError;
    for (final call in modelCalls) {
      try {
        return await call(content, config);
      } on FirebaseAIException catch (error) {
        if (!_isTransientOverload(error.message)) rethrow;
        lastError = error;
      }
    }
    throw lastError!;
  };
}

bool _isTransientOverload(String message) {
  final lower = message.toLowerCase();
  return lower.contains('high demand') ||
      lower.contains('internal') ||
      lower.contains('server error [500]') ||
      lower.contains(' 500');
}
