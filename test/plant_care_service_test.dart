import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plantcare/models/plant.dart';
import 'package:plantcare/repositories/plant_repository.dart';
import 'package:plantcare/services/notification_service.dart';
import 'package:plantcare/services/plant_care_service.dart';

class MockPlantRepository extends Mock implements PlantRepository {}

class MockNotificationService extends Mock implements NotificationService {}

Plant buildPlant({
  Map<String, dynamic> careSchedule = const {},
  String status = 'healthy',
}) {
  return Plant(
    id: 'plant-1',
    name: 'Monstera',
    species: 'Monstera deliciosa',
    imageUrl: '',
    status: status,
    dateAdded: DateTime(2026, 1, 1),
    careSchedule: careSchedule,
    photos: const [],
  );
}

void main() {
  late MockPlantRepository repository;
  late MockNotificationService notifications;
  late PlantCareService service;

  setUpAll(() {
    registerFallbackValue(buildPlant());
  });

  setUp(() {
    repository = MockPlantRepository();
    notifications = MockNotificationService();
    when(() => notifications.cancelPlantReminders(any()))
        .thenAnswer((_) async {});
    when(() => notifications.scheduleWateringReminder(any()))
        .thenAnswer((_) async {});
    when(() => notifications.scheduleFertilizingReminder(any()))
        .thenAnswer((_) async {});
    when(() => repository.addCareEvent(any(), any()))
        .thenAnswer((_) async {});
    when(() => repository.updatePlant(any(), any()))
        .thenAnswer((_) async {});
    service = PlantCareService(repository, notifications);
  });

  group('calculateNextCareDate', () {
    test('defaults to 7 days ahead for watering with an empty schedule',
        () async {
      final before = DateTime.now();

      final next = service.calculateNextCareDate(buildPlant(), 'watering');

      expect(next.isAfter(before), isTrue);
      expect(next.difference(before).inDays, 7);
    });

    test('uses the configured wateringFrequency instead of the default',
        () async {
      final before = DateTime.now();

      final next = service.calculateNextCareDate(
        buildPlant(careSchedule: {'wateringFrequency': 3}),
        'watering',
      );

      expect(next.difference(before).inDays, 3);
    });

    test('defaults to 30 days for fertilizing and 3 for misting', () async {
      final before = DateTime.now();

      final fertilizing =
          service.calculateNextCareDate(buildPlant(), 'fertilizing');
      final misting = service.calculateNextCareDate(buildPlant(), 'misting');

      expect(fertilizing.difference(before).inDays, 30);
      expect(misting.difference(before).inDays, 3);
    });
  });

  group('getCareTips', () {
    test('returns species-specific and standard care tips for a known species',
        () {
      final tips = service.getCareTips('Monstera deliciosa');

      expect(
        tips['tip'],
        'Provide bright, indirect light and water when top 2 inches of soil are dry.',
      );
      expect(tips['watering'], 'Water when the top inch of soil is dry');
      expect(tips['light'], 'Provide appropriate light based on plant needs');
      expect(
        tips['fertilizing'],
        'Fertilize during growing season',
      );
    });

    test('falls back to a generic tip for unknown species', () {
      final tips = service.getCareTips('Fakeus plantus');

      expect(
        tips['tip'],
        'Maintain appropriate light and water conditions for your plant.',
      );
    });
  });

  group('scheduleCareReminders', () {
    test('cancels existing reminders then schedules watering and fertilizing '
        'when fertilizing is enabled', () async {
      await service.scheduleCareReminders(
        buildPlant(careSchedule: {'fertilizingEnabled': true}),
      );

      verify(() => notifications.cancelPlantReminders('plant-1')).called(1);
      verify(() => notifications.scheduleWateringReminder(any())).called(1);
      verify(() => notifications.scheduleFertilizingReminder(any())).called(1);
    });

    test('skips the fertilizing reminder when fertilizing is disabled',
        () async {
      await service.scheduleCareReminders(
        buildPlant(careSchedule: {'fertilizingEnabled': false}),
      );

      verify(() => notifications.scheduleWateringReminder(any())).called(1);
      verifyNever(
        () => notifications.scheduleFertilizingReminder(any()),
      );
    });
  });

  group('logCareEvent', () {
    test('records the event and marks the plant healthy after watering',
        () async {
      await service.logCareEvent('plant-1', 'watering', notes: 'tank refill');

      final event =
          verify(() => repository.addCareEvent('plant-1', captureAny()))
              .captured
              .single as Map<String, dynamic>;
      expect(event['type'], 'watering');
      expect(event['notes'], 'tank refill');

      final update =
          verify(() => repository.updatePlant('plant-1', captureAny()))
              .captured
              .single as Map<String, dynamic>;
      expect(update['status'], 'healthy');
      expect(update, contains('lastWatered'));
      expect(update, contains('nextWatering'));
    });

    test('does not touch the plant when a non-watering event is logged',
        () async {
      await service.logCareEvent('plant-1', 'pruning');

      verify(() => repository.addCareEvent('plant-1', captureAny())).called(1);
      verifyNever(() => repository.updatePlant(any(), any()));
    });
  });
}