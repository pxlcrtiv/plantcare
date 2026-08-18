import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_ai/firebase_ai.dart';

abstract class PlantAiService {
  Future<bool> isAvailable();

  Future<HealthLogSummary> summarizeHealthLogs(SummaryRequest request);
}

class StubPlantAiService implements PlantAiService {
  const StubPlantAiService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<HealthLogSummary> summarizeHealthLogs(SummaryRequest request) {
    throw UnimplementedError('StubPlantAiService has no AI backend.');
  }
}

typedef ModelCall =
    Future<GenerateContentResponse> Function(
        List<Content> content, GenerationConfig config);

sealed class PlantAiException implements Exception {
  const PlantAiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class QuotaExceededError extends PlantAiException {
  const QuotaExceededError(super.message);
}

final class BlockedError extends PlantAiException {
  const BlockedError(super.message);
}

final class TimeoutError extends PlantAiException {
  const TimeoutError(super.message);
}

final class MalformedOutputError extends PlantAiException {
  const MalformedOutputError(super.message);
}

final class OfflineError extends PlantAiException {
  const OfflineError(super.message);
}

final class UnknownError extends PlantAiException {
  const UnknownError(super.message);
}

class HealthLogSummary {
  const HealthLogSummary({
    required this.overallHealth,
    this.notableChanges = const [],
    this.anomalies = const [],
    this.suggestions = const [],
  });

  factory HealthLogSummary.fromJson(Map<String, dynamic> json) {
    final overallHealth = json['overallHealth'];
    if (overallHealth is! String || overallHealth.trim().isEmpty) {
      throw const FormatException('overallHealth must be a non-empty string.');
    }
    return HealthLogSummary(
      overallHealth: overallHealth,
      notableChanges: _stringList(json['notableChanges'], 'notableChanges'),
      anomalies: _stringList(json['anomalies'], 'anomalies'),
      suggestions: _stringList(json['suggestions'], 'suggestions'),
    );
  }

  static List<String> _stringList(Object? value, String field) {
    if (value == null) return const [];
    if (value is! List) {
      throw FormatException('$field must be an array of strings.');
    }
    final items = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException('$field must contain only strings.');
      }
      items.add(item);
    }
    return items;
  }

  final String overallHealth;
  final List<String> notableChanges;
  final List<String> anomalies;
  final List<String> suggestions;
}

class SummaryRequest {
  const SummaryRequest({
    required this.plantName,
    this.species = '',
    this.humidity,
    this.light,
    this.location,
    this.careNotes,
    this.careSchedule = const {},
    this.healthLogs = const [],
  });

  final String plantName;
  final String species;
  final int? humidity;
  final String? light;
  final String? location;
  final String? careNotes;
  final Map<String, dynamic> careSchedule;
  final List<HealthLogEntry> healthLogs;
}

class HealthLogEntry {
  const HealthLogEntry({
    required this.type,
    required this.title,
    required this.description,
    required this.date,
  });

  factory HealthLogEntry.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    final DateTime date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is DateTime) {
      date = rawDate;
    } else {
      date = DateTime.now();
    }
    final description = map['description'] ?? map['content'];
    return HealthLogEntry(
      type: map['type'] as String? ?? 'note',
      title: map['title'] as String? ?? '',
      description: description is String ? description : '',
      date: date,
    );
  }

  final String type;
  final String title;
  final String description;
  final DateTime date;
}

class GeminiPlantAiService implements PlantAiService {
  GeminiPlantAiService({
    required ModelCall modelCall,
    Future<bool> Function()? checkOffline,
    Duration timeout = const Duration(seconds: 30),
  })  : _modelCall = modelCall,
        _checkOffline = checkOffline ?? _defaultOfflineCheck,
        _timeout = timeout;

  static Future<bool> _defaultOfflineCheck() async {
    final results = await Connectivity().checkConnectivity();
    return results.contains(ConnectivityResult.none);
  }

  static const String modelName = 'gemini-3.7-flash';
  static const int maxSummaryLogEntries = 40;

  final ModelCall _modelCall;
  final Future<bool> Function() _checkOffline;
  final Duration _timeout;

  static const String _summaryPromptTemplate = '''
You are a plant-care assistant writing a health summary for the plant owner. Base your summary ONLY on the plant profile and care log entries provided below. Never invent facts that are not present in the data.

Plant profile:
- Name: {plantName}
- Species: {species}
- Location: {location}
- Humidity: {humidity}%
- Light: {light}
- Care schedule: {careSchedule}
- Care notes: {careNotes}

Care log entries (most recent first):
{logEntries}

Respond with a single JSON object using exactly these fields:
- "overallHealth": a short string (1-2 sentences) describing the overall health of the plant over the logged period.
- "notableChanges": an array of strings describing notable changes during the period.
- "anomalies": an array of strings describing anything that needs attention.
- "suggestions": an array of strings with concrete care suggestions.

Return only the JSON object with no surrounding text.''';

  static final Schema _summaryResponseSchema = Schema.object(
    properties: {
      'overallHealth': Schema.string(
        description: 'Overall health of the plant over the logged period.',
      ),
      'notableChanges': Schema.array(
        items: Schema.string(),
        description: 'Notable changes during the period.',
      ),
      'anomalies': Schema.array(
        items: Schema.string(),
        description: 'Anything that needs attention.',
      ),
      'suggestions': Schema.array(
        items: Schema.string(),
        description: 'Concrete care suggestions.',
      ),
    },
    optionalProperties: ['notableChanges', 'anomalies', 'suggestions'],
  );

  @override
  Future<bool> isAvailable() async => !await _checkOffline();

  @override
  Future<HealthLogSummary> summarizeHealthLogs(SummaryRequest request) async {
    if (await _checkOffline()) {
      throw const OfflineError('AI features need an internet connection.');
    }

    final prompt = _buildSummaryPrompt(request);
    final config = GenerationConfig(
      temperature: 0.4,
      maxOutputTokens: 1024,
      responseMimeType: 'application/json',
      responseSchema: _summaryResponseSchema,
    );

    final GenerateContentResponse response;
    try {
      response = await _modelCall([Content.text(prompt)], config)
          .timeout(_timeout);
    } on TimeoutException {
      throw const TimeoutError('The summary request took too long.');
    } on PlantAiException {
      rethrow;
    } catch (error) {
      throw _classifyError(error);
    }

    final String? text;
    try {
      text = response.text;
    } on FirebaseAIException catch (error) {
      throw _classifyError(error);
    }

    if (text == null || text.trim().isEmpty) {
      throw const MalformedOutputError('The model returned no summary text.');
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const MalformedOutputError(
          'The summary output was not a JSON object.',
        );
      }
      return HealthLogSummary.fromJson(decoded);
    } on FormatException {
      throw const MalformedOutputError(
        'The summary output could not be parsed.',
      );
    }
  }

  String _buildSummaryPrompt(SummaryRequest request) {
    final sorted = [...request.healthLogs]
      ..sort((a, b) => a.date.compareTo(b.date));
    final omitted = sorted.length > maxSummaryLogEntries
        ? sorted.length - maxSummaryLogEntries
        : 0;
    final kept = omitted > 0
        ? sorted.sublist(sorted.length - maxSummaryLogEntries)
        : sorted;

    final buffer = StringBuffer();
    if (omitted > 0) {
      buffer.writeln('($omitted older entries omitted for brevity)');
    }
    for (final entry in kept.reversed) {
      final month = entry.date.month.toString().padLeft(2, '0');
      final day = entry.date.day.toString().padLeft(2, '0');
      buffer.writeln(
        '- ${entry.date.year}-$month-$day [${entry.type}] '
        '${entry.title}: ${entry.description}',
      );
    }

    final schedule = request.careSchedule.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');

    return _summaryPromptTemplate
        .replaceAll('{plantName}', request.plantName)
        .replaceAll('{species}', request.species)
        .replaceAll('{location}', request.location ?? 'Unknown')
        .replaceAll('{humidity}', request.humidity?.toString() ?? 'Unknown')
        .replaceAll('{light}', request.light ?? 'Unknown')
        .replaceAll(
          '{careSchedule}',
          schedule.isEmpty ? 'None' : schedule,
        )
        .replaceAll('{careNotes}', request.careNotes ?? 'None')
        .replaceAll('{logEntries}', buffer.toString().trim());
  }

  PlantAiException _classifyError(Object error) {
    if (error is PlantAiException) return error;
    if (error is QuotaExceeded) {
      return QuotaExceededError(error.message);
    }
    if (error is FirebaseAIException) {
      final message = error.message.toLowerCase();
      if (message.contains('quota') ||
          message.contains('resource_exhausted') ||
          message.contains('429')) {
        return QuotaExceededError(error.message);
      }
      if (message.contains('blocked') ||
          message.contains('safety') ||
          message.contains('recitation')) {
        return BlockedError(error.message);
      }
      return UnknownError(error.message);
    }
    return UnknownError(error.toString());
  }
}