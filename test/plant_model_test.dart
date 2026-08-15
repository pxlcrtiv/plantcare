import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare/models/plant.dart';

final _fixtureDate = DateTime(2026, 6, 1);

Plant buildPlant({
  String? lastWatered,
  String? nextWatering,
  String status = 'healthy',
}) {
  return Plant(
    id: 'plant-1',
    name: 'Monstera',
    species: 'Monstera deliciosa',
    imageUrl: 'https://example.com/m.jpg',
    status: status,
    lastWatered: lastWatered,
    nextWatering: nextWatering,
    careNotes: 'keep moist',
    location: 'Living room',
    dateAdded: _fixtureDate,
    careSchedule: const {'wateringFrequency': 5},
    photos: const ['p1.jpg'],
  );
}

void main() {
  group('fromMap / toMap', () {
    test('maps every field and round-trips through toMap', () {
      final plant = buildPlant(lastWatered: '2026-06-01T08:00:00.000');

      final map = plant.toMap();
      final restored = Plant.fromMap(map);

      expect(restored.id, 'plant-1');
      expect(restored.name, 'Monstera');
      expect(restored.species, 'Monstera deliciosa');
      expect(restored.imageUrl, 'https://example.com/m.jpg');
      expect(restored.status, 'healthy');
      expect(restored.lastWatered, '2026-06-01T08:00:00.000');
      expect(restored.careNotes, 'keep moist');
      expect(restored.location, 'Living room');
      expect(restored.dateAdded, _fixtureDate);
      expect(restored.careSchedule, {'wateringFrequency': 5});
      expect(restored.photos, ['p1.jpg']);
    });

    test('applies healthy status, empty text and empty collections when '
        'fields are missing', () {
      final plant = Plant.fromMap(const {});

      expect(plant.id, '');
      expect(plant.name, '');
      expect(plant.species, '');
      expect(plant.imageUrl, '');
      expect(plant.status, 'healthy');
      expect(plant.careSchedule, isEmpty);
      expect(plant.photos, isEmpty);
      expect(plant.lastWatered, isNull);
      expect(plant.dateAdded, isA<DateTime>());
    });
  });

  group('getFormattedLastWatered', () {
    test('returns Never when never watered', () {
      expect(buildPlant().getFormattedLastWatered(), 'Never');
    });

    test('reports days ago for dates more than a day in the past', () {
      final twoDaysAgo =
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
      final plant = buildPlant(lastWatered: twoDaysAgo);

      expect(plant.getFormattedLastWatered(), '2 days ago');
    });

    test('reports hours ago for recent waterings', () {
      final threeHoursAgo =
          DateTime.now().subtract(const Duration(hours: 3)).toIso8601String();
      final plant = buildPlant(lastWatered: threeHoursAgo);

      expect(plant.getFormattedLastWatered(), '3 hours ago');
    });

    test('reports Today for waterings within the last hour', () {
      final minutesAgo =
          DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String();
      final plant = buildPlant(lastWatered: minutesAgo);

      expect(plant.getFormattedLastWatered(), 'Today');
    });

    test('reports Unknown when the stored value is not a datetime', () {
      final plant = buildPlant(lastWatered: 'not-a-date');

      expect(plant.getFormattedLastWatered(), 'Unknown');
    });
  });

  group('getFormattedNextWatering', () {
    test('returns TBD when no watering date is set', () {
      expect(buildPlant().getFormattedNextWatering(), 'TBD');
    });

    test('reports Overdue for dates in the past', () {
      final twoDaysAgo =
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
      final plant = buildPlant(nextWatering: twoDaysAgo);

      expect(plant.getFormattedNextWatering(), 'Overdue');
    });

    test('reports Today for today', () {
      final laterToday =
          DateTime.now().add(const Duration(hours: 6)).toIso8601String();
      final plant = buildPlant(nextWatering: laterToday);

      expect(plant.getFormattedNextWatering(), 'Today');
    });

    test('reports the day count for upcoming waterings', () {
      final inThreeDays = DateTime.now()
          .add(const Duration(days: 3, hours: 12))
          .toIso8601String();
      final plant = buildPlant(nextWatering: inThreeDays);

      expect(plant.getFormattedNextWatering(), 'In 3 days');
    });

    test('returns TBD when the stored value is not a datetime', () {
      final plant = buildPlant(nextWatering: 'not-a-date');

      expect(plant.getFormattedNextWatering(), 'TBD');
    });
  });
}