import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart' as http;

abstract class PlantAiService {
  Future<bool> isAvailable();

  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request);

  Future<String> chatAboutPlant(ChatRequest request);

  Future<ScheduleSuggestion> suggestWateringSchedule(ScheduleRequest request);

  Future<String> reminderTextFor(ReminderTextRequest request);
}

class StubPlantAiService implements PlantAiService {
  const StubPlantAiService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<DiagnosisResult> diagnosePlant(DiagnosisRequest request) async {
    throw const UnknownError();
  }

  @override
  Future<String> chatAboutPlant(ChatRequest request) async {
    throw const UnknownError();
  }

  @override
  Future<ScheduleSuggestion> suggestWateringSchedule(
    ScheduleRequest request,
  ) {
    throw UnsupportedError('StubPlantAiService does not generate schedules');
  }

  @override
  Future<String> reminderTextFor(ReminderTextRequest request) {
    throw UnsupportedError(
      'StubPlantAiService does not generate reminder text',
    );
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
      : super("The assistant couldn't answer that one. Try rephrasing.");
}

final class TimeoutError extends PlantAiException {
  const TimeoutError()
      : super('The assistant took too long to respond. Try again in a moment.');
}

final class MalformedOutputError extends PlantAiException {
  const MalformedOutputError()
      : super("The assistant's reply didn't come through. Try again in a moment.");
}

final class OfflineError extends PlantAiException {
  const OfflineError()
      : super("You're offline — AI features need a connection.");
}

final class UnknownError extends PlantAiException {
  const UnknownError() : super('Something went wrong. Try again in a moment.');
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

const int plantAiChatHistoryLimit = 12;

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

class ChatMessage {
  const ChatMessage({required this.role, required this.text});

  final String role;
  final String text;
}

class ChatRequest {
  const ChatRequest({
    required this.plantName,
    this.species,
    this.light,
    this.humidity,
    this.location,
    this.careSchedule = const {},
    this.healthLogs = const [],
    this.notes,
    this.messages = const [],
  });

  final String plantName;
  final String? species;
  final String? light;
  final int? humidity;
  final String? location;
  final Map<String, dynamic> careSchedule;
  final List<Map<String, dynamic>> healthLogs;
  final String? notes;
  final List<ChatMessage> messages;
}

class ScheduleRequest {
  const ScheduleRequest({
    required this.species,
    this.light,
    this.humidity,
    this.location,
    this.careSchedule = const {},
  });

  final String species;
  final String? light;
  final int? humidity;
  final String? location;
  final Map<String, dynamic> careSchedule;
}

class ReminderTextRequest {
  const ReminderTextRequest({this.careSchedule = const {}});

  final Map<String, dynamic> careSchedule;
}

class ScheduleSuggestion {
  const ScheduleSuggestion({
    required this.wateringFrequency,
    this.fertilizingEnabled = false,
    this.fertilizingFrequency = 30,
    this.mistingEnabled = false,
    this.mistingFrequency = 3,
    this.rotatingEnabled = false,
    this.rotatingFrequency = 7,
    this.reason,
  });

  factory ScheduleSuggestion.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Schedule suggestion is not an object');
    }
    final rawWatering = json['wateringFrequency'];
    int? wateringFrequency;
    if (rawWatering is num) {
      wateringFrequency = rawWatering.toInt();
    } else if (rawWatering is String) {
      wateringFrequency = int.tryParse(rawWatering);
    }
    if (wateringFrequency == null ||
        wateringFrequency < 1 ||
        wateringFrequency > 30) {
      throw const FormatException('Invalid watering frequency');
    }
    return ScheduleSuggestion(
      wateringFrequency: wateringFrequency,
      fertilizingEnabled: json['fertilizingEnabled'] == true,
      fertilizingFrequency:
          _readInt(json['fertilizingFrequency'], fallback: 30),
      mistingEnabled: json['mistingEnabled'] == true,
      mistingFrequency: _readInt(json['mistingFrequency'], fallback: 3),
      rotatingEnabled: json['rotatingEnabled'] == true,
      rotatingFrequency: _readInt(json['rotatingFrequency'], fallback: 7),
      reason: json['reason'] is String ? json['reason'] as String : null,
    );
  }

  static int _readInt(Object? value, {required int fallback}) {
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  final int wateringFrequency;
  final bool fertilizingEnabled;
  final int fertilizingFrequency;
  final bool mistingEnabled;
  final int mistingFrequency;
  final bool rotatingEnabled;
  final int rotatingFrequency;
  final String? reason;

  Map<String, dynamic> toCareScheduleMap() {
    return {
      'wateringFrequency': wateringFrequency,
      'fertilizingEnabled': fertilizingEnabled,
      'fertilizingFrequency': fertilizingFrequency,
      'mistingEnabled': mistingEnabled,
      'mistingFrequency': mistingFrequency,
      'rotatingEnabled': rotatingEnabled,
      'rotatingFrequency': rotatingFrequency,
    };
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

const String _schedulePrompt = '''
You are a houseplant care expert. Propose an updated watering and care schedule for a plant.

Consider the species, the environment it lives in, and the current schedule. Suggest frequencies that keep the plant healthy without overwatering. Keep fertilizing, misting and rotating enabled exactly as they are in the current schedule; only the frequencies may change.

Respond with JSON only, matching this shape:
{
  "wateringFrequency": days between waterings, an integer between 1 and 30,
  "fertilizingEnabled": true or false,
  "fertilizingFrequency": days between fertilizing,
  "mistingEnabled": true or false,
  "mistingFrequency": days between misting,
  "rotatingEnabled": true or false,
  "rotatingFrequency": days between rotating,
  "reason": a short explanation of the proposed changes
}

Always include every field.
''';

const String _reminderTextPrompt = '''
You are a houseplant care assistant. Write the notification body for a watering reminder.

The message should be friendly, specific to the plant, and short (one or two sentences). Reference the plant's care schedule so the reminder feels personal.

Respond with plain text only. Do not use JSON, quotes, or emoji.
''';

final Schema _scheduleResponseSchema = Schema.object(
  description: 'Proposed plant care schedule',
  properties: {
    'wateringFrequency': Schema.integer(
      description: 'Days between waterings, between 1 and 30',
    ),
    'fertilizingEnabled': Schema.boolean(
      description: 'Whether fertilizing is part of the schedule',
    ),
    'fertilizingFrequency': Schema.integer(
      description: 'Days between fertilizing',
    ),
    'mistingEnabled': Schema.boolean(
      description: 'Whether misting is part of the schedule',
    ),
    'mistingFrequency': Schema.integer(description: 'Days between misting'),
    'rotatingEnabled': Schema.boolean(
      description: 'Whether rotating is part of the schedule',
    ),
    'rotatingFrequency': Schema.integer(
      description: 'Days between rotating',
    ),
    'reason': Schema.string(description: 'Short rationale for the proposal'),
  },
  optionalProperties: [
    'fertilizingEnabled',
    'fertilizingFrequency',
    'mistingEnabled',
    'mistingFrequency',
    'rotatingEnabled',
    'rotatingFrequency',
    'reason',
  ],
);

class GeminiPlantAiService implements PlantAiService {
  GeminiPlantAiService({required ModelCall modelCall, Connectivity? connectivity})
      : _modelCall = modelCall,
        _connectivity = connectivity ?? Connectivity();

  final ModelCall _modelCall;
  final Connectivity _connectivity;

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
    } on http.ClientException {
      throw const OfflineError();
    } on TimeoutException {
      throw const TimeoutError();
    } on PlantAiException {
      rethrow;
    } on FirebaseAIException catch (error) {
      throw _mapFirebaseError(error);
    } on FormatException {
      throw const MalformedOutputError();
    } catch (_) {
      throw const UnknownError();
    }
  }

  @override
  Future<String> chatAboutPlant(ChatRequest request) async {
    if (await _isOffline()) {
      throw const OfflineError();
    }
    final GenerateContentResponse response;
    try {
      response = await _modelCall(
        _buildChatPrompt(request),
        GenerationConfig(
          temperature: plantAiFeatureConfigs['chat']!.temperature,
          maxOutputTokens: plantAiFeatureConfigs['chat']!.maxOutputTokens,
        ),
      );
    } on QuotaExceeded {
      throw const QuotaExceededError();
    } on http.ClientException {
      throw const OfflineError();
    } on TimeoutException {
      throw const TimeoutError();
    } on FirebaseAIException catch (error) {
      throw _mapFirebaseError(error);
    } catch (_) {
      throw const UnknownError();
    }

    final String? text;
    try {
      text = response.text;
    } on FirebaseAIException catch (error) {
      throw _mapFirebaseError(error);
    }
    if (text == null || text.trim().isEmpty) {
      throw const MalformedOutputError();
    }
    return text.trim();
  }

  @override
  Future<ScheduleSuggestion> suggestWateringSchedule(
    ScheduleRequest request,
  ) async {
    if (await _isOffline()) {
      throw const OfflineError();
    }
    final featureConfig = plantAiFeatureConfigs['schedule']!;
    try {
      final response = await _modelCall(
        [Content.text('$_schedulePrompt\n\n${_scheduleGrounding(request)}')],
        GenerationConfig(
          temperature: featureConfig.temperature,
          maxOutputTokens: featureConfig.maxOutputTokens,
          responseMimeType: 'application/json',
          responseSchema: _scheduleResponseSchema,
        ),
      );
      if (response.promptFeedback?.blockReason != null) {
        throw const BlockedError();
      }
      final text = response.text;
      if (text == null) {
        throw const MalformedOutputError();
      }
      return ScheduleSuggestion.fromJson(jsonDecode(text));
    } on QuotaExceeded {
      throw const QuotaExceededError();
    } on http.ClientException {
      throw const OfflineError();
    } on TimeoutException {
      throw const TimeoutError();
    } on PlantAiException {
      rethrow;
    } on FirebaseAIException catch (error) {
      throw _mapFirebaseError(error);
    } on FormatException {
      throw const MalformedOutputError();
    } catch (_) {
      throw const UnknownError();
    }
  }

  @override
  Future<String> reminderTextFor(ReminderTextRequest request) async {
    if (await _isOffline()) {
      throw const OfflineError();
    }
    final featureConfig = plantAiFeatureConfigs['reminderText']!;
    try {
      final response = await _modelCall(
        [Content.text('$_reminderTextPrompt\n\n${_reminderGrounding(request)}')],
        GenerationConfig(
          temperature: featureConfig.temperature,
          maxOutputTokens: featureConfig.maxOutputTokens,
        ),
      );
      if (response.promptFeedback?.blockReason != null) {
        throw const BlockedError();
      }
      final text = response.text;
      if (text == null) {
        throw const MalformedOutputError();
      }
      return text.trim();
    } on QuotaExceeded {
      throw const QuotaExceededError();
    } on http.ClientException {
      throw const OfflineError();
    } on TimeoutException {
      throw const TimeoutError();
    } on PlantAiException {
      rethrow;
    } on FirebaseAIException catch (error) {
      throw _mapFirebaseError(error);
    } catch (_) {
      throw const UnknownError();
    }
  }

  Future<bool> _isOffline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.contains(ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  PlantAiException _mapFirebaseError(FirebaseAIException error) {
    if (error is QuotaExceeded) {
      return const QuotaExceededError();
    }
    final message = error.message.toLowerCase();
    if (message.contains('blocked') ||
        message.contains('safety') ||
        message.contains('recitation')) {
      return const BlockedError();
    }
    return const UnknownError();
  }

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

  List<Content> _buildChatPrompt(ChatRequest request) {
    final history = request.messages.length > plantAiChatHistoryLimit
        ? request.messages.sublist(
            request.messages.length - plantAiChatHistoryLimit,
          )
        : request.messages;
    return [
      Content.system(_buildSystemPrompt(request)),
      for (final message in history)
        if (message.role == 'assistant')
          Content.model([TextPart(message.text)])
        else
          Content.text(message.text),
    ];
  }

  String _buildSystemPrompt(ChatRequest request) {
    final buffer = StringBuffer()
      ..writeln(
        'You are a plant care assistant in the plantcare app. '
        'Answer the user about their plant in plain, practical language. '
        'Use the plant facts below and general plant-care knowledge. '
        'Keep replies concise and friendly.',
      )
      ..writeln()
      ..writeln('PLANT PROFILE')
      ..writeln('Name: ${request.plantName}');
    final species = request.species;
    if (species != null && species.isNotEmpty) {
      buffer.writeln('Species: $species');
    }
    final light = request.light;
    if (light != null && light.isNotEmpty) {
      buffer.writeln('Light: $light');
    }
    final humidity = request.humidity;
    if (humidity != null) {
      buffer.writeln('Humidity: $humidity%');
    }
    final location = request.location;
    if (location != null && location.isNotEmpty) {
      buffer.writeln('Location: $location');
    }
    buffer
      ..writeln()
      ..writeln('CARE SCHEDULE');
    if (request.careSchedule.isEmpty) {
      buffer.writeln('No care schedule set.');
    } else {
      request.careSchedule.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }
    buffer
      ..writeln()
      ..writeln('RECENT HEALTH LOGS');
    if (request.healthLogs.isEmpty) {
      buffer.writeln('No health logs yet.');
    } else {
      for (final log in request.healthLogs) {
        final type = log['type'] ?? 'note';
        final title = log['title'] ?? log['description'] ?? '';
        final detail = log['notes'] ?? log['content'] ?? '';
        buffer.writeln('- $type: $title $detail'.trim());
      }
    }
    buffer
      ..writeln()
      ..writeln('NOTES');
    final notes = request.notes;
    if (notes == null || notes.isEmpty) {
      buffer.writeln('No additional notes.');
    } else {
      buffer.writeln(notes);
    }
    return buffer.toString();
  }

  String _scheduleGrounding(ScheduleRequest request) {
    return '''
Species: ${request.species.isEmpty ? 'Unknown' : request.species}
Light: ${request.light ?? 'Unknown'}
Humidity: ${request.humidity?.toString() ?? 'Unknown'}
Location: ${request.location?.isNotEmpty == true ? request.location : 'Unknown'}
Current schedule: ${jsonEncode(request.careSchedule)}
''';
  }

  String _reminderGrounding(ReminderTextRequest request) {
    return '''
Care schedule: ${jsonEncode(request.careSchedule)}
''';
  }
}