import '../models/plant.dart';

abstract class PlantRepository {
  Stream<List<Plant>> getPlants();
  Future<void> addPlant(Plant plant);
  Future<void> updatePlant(String plantId, Map<String, dynamic> data);
  Future<void> deletePlant(String plantId);
  Future<void> addCareEvent(String plantId, Map<String, dynamic> event);
  Future<void> addHealthLog(String plantId, Map<String, dynamic> log);
}