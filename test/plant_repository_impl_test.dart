import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plantcare/models/plant.dart';
import 'package:plantcare/repositories/plant_repository_impl.dart';
import 'package:plantcare/services/firebase_service.dart';

class MockFirebaseService extends Mock implements FirebaseService {}

Plant buildPlant({String id = 'plant-1'}) {
  return Plant(
    id: id,
    name: 'Monstera',
    species: 'Monstera deliciosa',
    imageUrl: '',
    status: 'healthy',
    dateAdded: DateTime(2026, 1, 1),
    careSchedule: const {},
    photos: const [],
  );
}

void main() {
  late MockFirebaseService firebase;
  late PlantRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(buildPlant());
  });

  setUp(() {
    firebase = MockFirebaseService();
    repository = PlantRepositoryImpl(firebase);
  });

  group('getPlants', () {
    test('forwards the firebase plant stream unchanged', () {
      final plants = [buildPlant(), buildPlant(id: 'plant-2')];
      when(() => firebase.getPlants())
          .thenAnswer((_) => Stream.value(plants));

      expect(
        repository.getPlants(),
        emits(plants),
      );
    });
  });

  group('mutations', () {
    test('addPlant forwards the plant to the backend', () async {
      when(() => firebase.addPlant(any())).thenAnswer((_) async {});
      final plant = buildPlant();

      await repository.addPlant(plant);

      verify(() => firebase.addPlant(plant)).called(1);
    });

    test('updatePlant forwards plantId and data', () async {
      when(() => firebase.updatePlant(any(), any())).thenAnswer((_) async {});

      await repository.updatePlant('plant-1', {'status': 'healthy'});

      verify(() => firebase.updatePlant('plant-1', {'status': 'healthy'}))
          .called(1);
    });

    test('deletePlant forwards plantId', () async {
      when(() => firebase.deletePlant(any())).thenAnswer((_) async {});

      await repository.deletePlant('plant-1');

      verify(() => firebase.deletePlant('plant-1')).called(1);
    });

    test('addCareEvent forwards plantId and the event', () async {
      when(() => firebase.addCareEvent(any(), any())).thenAnswer((_) async {});
      final event = {'type': 'watering', 'notes': 'done'};

      await repository.addCareEvent('plant-1', event);

      verify(() => firebase.addCareEvent('plant-1', event)).called(1);
    });

    test('addHealthLog forwards plantId and the log', () async {
      when(() => firebase.addHealthLog(any(), any())).thenAnswer((_) async {});
      final log = {'type': 'note'};

      await repository.addHealthLog('plant-1', log);

      verify(() => firebase.addHealthLog('plant-1', log)).called(1);
    });
  });
}