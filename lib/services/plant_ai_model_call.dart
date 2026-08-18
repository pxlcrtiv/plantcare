import 'package:firebase_ai/firebase_ai.dart';

import 'plant_ai_service.dart';

ModelCall plantAiModelCall() {
  final model = FirebaseAI.googleAI().generativeModel(model: plantAiModelName);
  return (List<Content> content, GenerationConfig config) =>
      model.generateContent(content, generationConfig: config);
}