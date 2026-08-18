import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart' as http;

abstract class PlantAiService {
  Future<bool> isAvailable();

  Future<String> chatAboutPlant(ChatRequest request);
}

class StubPlantAiService implements PlantAiService {
  const StubPlantAiService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<String> chatAboutPlant(ChatRequest request) async {
    throw const UnknownError();
  }
}

typedef ModelCall = Future<GenerateContentResponse> Function(
  List<Content> content,
  GenerationConfig config,
);

const String plantAiChatModelName = 'gemini-3.7-flash';
const double plantAiChatTemperature = 0.8;
const int plantAiChatMaxOutputTokens = 1024;
const int plantAiChatHistoryLimit = 12;

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

sealed class PlantAiError implements Exception {
  const PlantAiError();

  String get message;
}

final class QuotaExceededError extends PlantAiError {
  const QuotaExceededError();

  @override
  String get message => 'The daily AI quota is used up. Try again in a moment.';
}

final class BlockedError extends PlantAiError {
  const BlockedError();

  @override
  String get message =>
      "The assistant couldn't answer that one. Try rephrasing your question.";
}

final class TimeoutError extends PlantAiError {
  const TimeoutError();

  @override
  String get message =>
      'The assistant took too long to reply. Try again in a moment.';
}

final class MalformedOutputError extends PlantAiError {
  const MalformedOutputError();

  @override
  String get message =>
      "The assistant's reply didn't come through. Try again in a moment.";
}

final class OfflineError extends PlantAiError {
  const OfflineError();

  @override
  String get message => "You're offline — AI features need a connection.";
}

final class UnknownError extends PlantAiError {
  const UnknownError();

  @override
  String get message => 'Something went wrong. Try again in a moment.';
}

class GeminiPlantAiService implements PlantAiService {
  GeminiPlantAiService({required ModelCall modelCall}) : _modelCall = modelCall;

  final ModelCall _modelCall;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> chatAboutPlant(ChatRequest request) async {
    final GenerateContentResponse response;
    try {
      response = await _modelCall(
        _buildChatPrompt(request),
        GenerationConfig(
          temperature: plantAiChatTemperature,
          maxOutputTokens: plantAiChatMaxOutputTokens,
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

  PlantAiError _mapFirebaseError(FirebaseAIException error) {
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
}
