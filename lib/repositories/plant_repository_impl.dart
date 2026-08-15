import '../models/plant.dart';
import '../repositories/plant_repository.dart';
import '../services/firebase_service.dart';

class PlantRepositoryImpl implements PlantRepository {
  final FirebaseService _firebaseService;

  PlantRepositoryImpl(this._firebaseService);

  @override
  Stream<List<Plant>> getPlants() {
    return _firebaseService.getPlants();
  }

  @override
  Future<void> addPlant(Plant plant) async {
    await _firebaseService.addPlant(plant);
  }

  @override
  Future<void> updatePlant(String plantId, Map<String, dynamic> data) async {
    await _firebaseService.updatePlant(plantId, data);
  }

  @override
  Future<void> deletePlant(String plantId) async {
    await _firebaseService.deletePlant(plantId);
  }

  @override
  Future<void> addCareEvent(String plantId, Map<String, dynamic> event) async {
    await _firebaseService.addCareEvent(plantId, event);
  }

  @override
  Future<void> addHealthLog(String plantId, Map<String, dynamic> log) async {
    await _firebaseService.addHealthLog(plantId, log);
  }
}