import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_ai/firebase_ai.dart';

abstract class PlantAiService {
  Future<bool> isAvailable();

  Future<ScheduleSuggestion> suggestWateringSchedule(ScheduleRequest request);

  Future<String> reminderTextFor(ReminderTextRequest request);
}

class StubPlantAiService implements PlantAiService {
  const StubPlantAiService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<ScheduleSuggestion> suggestWateringSchedule(ScheduleRequest request) {
    throw UnsupportedError('StubPlantAiService does not generate schedules');
  }

  @override
  Future<String> reminderTextFor(ReminderTextRequest request) {
    throw UnsupportedError(
      'StubPlantAiService does not generate reminder text',
    );
  }
}

sealed class PlantAiException implements Exception {
  const PlantAiException();
}

final class QuotaExceededError extends PlantAiException {
  const QuotaExceededError();
}

final class BlockedError extends PlantAiException {
  const BlockedError();
}

final class TimeoutError extends PlantAiException {
  const TimeoutError();
}

final class MalformedOutputError extends PlantAiException {
  const MalformedOutputError();
}

final class OfflineError extends PlantAiException {
  const OfflineError();
}

final class UnknownError extends PlantAiException {
  const UnknownError();
}

typedef ModelCall = Future<GenerateContentResponse> Function(
  List<Content> content,
  GenerationConfig config,
);

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

class GeminiPlantAiService implements PlantAiService {
  GeminiPlantAiService({required ModelCall modelCall, Connectivity? connectivity})
      : _modelCall = modelCall,
        _connectivity = connectivity ?? Connectivity();

  final ModelCall _modelCall;
  final Connectivity _connectivity;

  static const String _schedulePrompt = '''
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

  static const String _reminderTextPrompt = '''
You are a houseplant care assistant. Write the notification body for a watering reminder.

The message should be friendly, specific to the plant, and short (one or two sentences). Reference the plant's care schedule so the reminder feels personal.

Respond with plain text only. Do not use JSON, quotes, or emoji.
''';

  static final Schema _scheduleResponseSchema = Schema.object(
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

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ScheduleSuggestion> suggestWateringSchedule(
    ScheduleRequest request,
  ) async {
    try {
      await _ensureOnline();
      final response = await _modelCall(
        [Content.text('$_schedulePrompt\n\n${_scheduleGrounding(request)}')],
        GenerationConfig(
          temperature: 0.5,
          maxOutputTokens: 1024,
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
    } on PlantAiException {
      rethrow;
    } on QuotaExceeded {
      throw const QuotaExceededError();
    } on FirebaseAIException catch (error) {
      if (error.message.toLowerCase().contains('blocked')) {
        throw const BlockedError();
      }
      throw const UnknownError();
    } on TimeoutException {
      throw const TimeoutError();
    } on FormatException {
      throw const MalformedOutputError();
    } catch (_) {
      throw const UnknownError();
    }
  }

  @override
  Future<String> reminderTextFor(ReminderTextRequest request) async {
    try {
      await _ensureOnline();
      final response = await _modelCall(
        [Content.text('$_reminderTextPrompt\n\n${_reminderGrounding(request)}')],
        GenerationConfig(temperature: 0.8, maxOutputTokens: 256),
      );
      if (response.promptFeedback?.blockReason != null) {
        throw const BlockedError();
      }
      final text = response.text;
      if (text == null) {
        throw const MalformedOutputError();
      }
      return text.trim();
    } on PlantAiException {
      rethrow;
    } on QuotaExceeded {
      throw const QuotaExceededError();
    } on FirebaseAIException catch (error) {
      if (error.message.toLowerCase().contains('blocked')) {
        throw const BlockedError();
      }
      throw const UnknownError();
    } on TimeoutException {
      throw const TimeoutError();
    } catch (_) {
      throw const UnknownError();
    }
  }

  Future<void> _ensureOnline() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      throw const OfflineError();
    }
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