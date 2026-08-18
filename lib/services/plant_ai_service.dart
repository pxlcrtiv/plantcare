import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_ai/firebase_ai.dart';

abstract class PlantAiService {
  Future<bool> isAvailable();

  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request);
}

class StubPlantAiService implements PlantAiService {
  const StubPlantAiService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request) async {
    throw const UnknownError();
  }
}

typedef ModelCall = Future<GenerateContentResponse> Function(
  List<Content> content,
  GenerationConfig config,
);

sealed class PlantAiException implements Exception {
  const PlantAiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class QuotaExceededError extends PlantAiException {
  const QuotaExceededError()
      : super('The AI assistant has reached its free usage limit.');
}

final class BlockedError extends PlantAiException {
  const BlockedError()
      : super('The AI assistant could not review the provided photo.');
}

final class TimeoutError extends PlantAiException {
  const TimeoutError()
      : super('The AI assistant took too long to respond.');
}

final class MalformedOutputError extends PlantAiException {
  const MalformedOutputError()
      : super('The AI assistant returned an unreadable diagnosis.');
}

final class OfflineError extends PlantAiException {
  const OfflineError()
      : super('A network connection is required for the AI assistant.');
}

final class UnknownError extends PlantAiException {
  const UnknownError() : super('Something went wrong with the AI assistant.');
}

const String plantAiModelName = 'gemini-3.7-flash';

class PlantAiFeatureConfig {
  const PlantAiFeatureConfig({
    required this.temperature,
    required this.maxOutputTokens,
  });

  final double temperature;
  final int maxOutputTokens;
}

const Map<String, PlantAiFeatureConfig> plantAiFeatureConfigs = {
  'diagnosis': PlantAiFeatureConfig(temperature: 0.3, maxOutputTokens: 1024),
  'schedule': PlantAiFeatureConfig(temperature: 0.5, maxOutputTokens: 1024),
  'summary': PlantAiFeatureConfig(temperature: 0.4, maxOutputTokens: 1024),
  'chat': PlantAiFeatureConfig(temperature: 0.8, maxOutputTokens: 1024),
  'reminderText': PlantAiFeatureConfig(temperature: 0.8, maxOutputTokens: 256),
};

class DiagnosisRequest {
  const DiagnosisRequest({
    required this.photoBytes,
    this.photoMimeType = 'image/jpeg',
    this.species,
    this.light,
    this.humidity,
    this.location,
  });

  final Uint8List photoBytes;
  final String photoMimeType;
  final String? species;
  final String? light;
  final int? humidity;
  final String? location;
}

class DiagnosisResult {
  const DiagnosisResult({
    required this.condition,
    required this.severity,
    this.confidence = 0.0,
    this.causes = const [],
    this.careSteps = const [],
  });

  final String condition;
  final String severity;
  final double confidence;
  final List<String> causes;
  final List<String> careSteps;

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    final condition = json['condition'];
    final severity = json['severity'];
    final confidence = json['confidence'];
    final causes = json['causes'];
    final careSteps = json['careSteps'];
    if (condition is! String || condition.trim().isEmpty) {
      throw const MalformedOutputError();
    }
    if (severity is! String || severity.trim().isEmpty) {
      throw const MalformedOutputError();
    }
    if (confidence != null && confidence is! num) {
      throw const MalformedOutputError();
    }
    if (causes != null && causes is! List) {
      throw const MalformedOutputError();
    }
    if (careSteps != null && careSteps is! List) {
      throw const MalformedOutputError();
    }
    return DiagnosisResult(
      condition: condition,
      severity: severity,
      confidence: (confidence as num?)?.toDouble() ?? 0.0,
      causes: causes == null
          ? const []
          : causes.whereType<String>().toList(),
      careSteps: careSteps == null
          ? const []
          : careSteps.whereType<String>().toList(),
    );
  }
}

const String _diagnosisPromptTemplate = '''
You are a Plant Doctor assistant. Diagnose the plant shown in the photo and respond in JSON.

Use the caller-provided plant context as ground truth. If the species is unknown, still diagnose from the photo alone.

Respond with exactly:
- condition: short name of the diagnosed condition
- severity: one of "mild", "moderate", "severe"
- confidence: number between 0 and 1
- causes: array of likely causes
- careSteps: array of clear step-by-step treatment actions

Plant context:
- Species: {species}
- Light: {light}
- Humidity: {humidity}
- Location: {location}
''';

final Schema _diagnosisSchema = Schema.object(
  properties: {
    'condition': Schema.string(
      description: 'Short name of the diagnosed condition.',
    ),
    'severity': Schema.string(
      description: 'One of: mild, moderate, severe.',
    ),
    'confidence': Schema.number(
      description: 'Confidence of the diagnosis from 0.0 to 1.0.',
    ),
    'causes': Schema.array(
      items: Schema.string(),
      description: 'Likely causes of the condition.',
    ),
    'careSteps': Schema.array(
      items: Schema.string(),
      description: 'Step-by-step treatment advice.',
    ),
  },
  optionalProperties: ['confidence', 'causes', 'careSteps'],
);

List<Content> _buildDiagnosisContent(DiagnosisRequest request) {
  final prompt = _diagnosisPromptTemplate
      .replaceAll('{species}', request.species ?? 'Unknown')
      .replaceAll('{light}', request.light ?? 'Unknown')
      .replaceAll('{humidity}', request.humidity?.toString() ?? 'Unknown')
      .replaceAll('{location}', request.location ?? 'Unknown');
  return [
    Content.multi([
      TextPart(prompt),
      InlineDataPart(request.photoMimeType, request.photoBytes),
    ]),
  ];
}

class FirebasePlantAiService implements PlantAiService {
  FirebasePlantAiService(this._modelCall);

  final ModelCall _modelCall;

  @override
  Future<bool> isAvailable() async => !await _isOffline();

  @override
  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request) async {
    if (await _isOffline()) {
      throw const OfflineError();
    }
    final featureConfig = plantAiFeatureConfigs['diagnosis']!;
    final config = GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: _diagnosisSchema,
      temperature: featureConfig.temperature,
      maxOutputTokens: featureConfig.maxOutputTokens,
    );
    try {
      final response = await _modelCall(
        _buildDiagnosisContent(request),
        config,
      );
      if (response.promptFeedback?.blockReason != null) {
        throw const BlockedError();
      }
      final text = response.text;
      if (text == null) {
        throw const MalformedOutputError();
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const MalformedOutputError();
      }
      return DiagnosisResult.fromJson(decoded);
    } on QuotaExceeded {
      throw const QuotaExceededError();
    } on TimeoutException {
      throw const TimeoutError();
    } on PlantAiException {
      rethrow;
    } on FirebaseAIException catch (error) {
      if (error.message.toLowerCase().contains('blocked')) {
        throw const BlockedError();
      }
      throw const UnknownError();
    } on FormatException {
      throw const MalformedOutputError();
    } catch (_) {
      throw const UnknownError();
    }
  }

  Future<bool> _isOffline() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return results.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }
}