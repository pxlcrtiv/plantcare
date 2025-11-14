import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';
import '../services/notification_service.dart';
import '../repositories/plant_repository.dart';

class PlantCareService {
  final PlantRepository _plantRepository;
  final NotificationService _notificationService;

  PlantCareService(this._plantRepository, this._notificationService);

  /// Schedule care reminders for a plant when added or updated
  Future<void> scheduleCareReminders(Plant plant) async {
    // Cancel existing reminders
    await _notificationService.cancelPlantReminders(plant.id);
    
    // Schedule new reminders based on care schedule
    await _notificationService.scheduleWateringReminder(plant);
    
    if (plant.careSchedule['fertilizingEnabled'] == true) {
      await _notificationService.scheduleFertilizingReminder(plant);
    }
  }

  /// Log a care event and update plant status
  Future<void> logCareEvent(String plantId, String eventType, {String? notes}) async {
    final event = {
      'type': eventType,
      'date': Timestamp.now(),
      'notes': notes ?? '',
      'createdAt': Timestamp.now(),
    };

    await _plantRepository.addCareEvent(plantId, event);

    // Update plant status based on care event
    if (eventType == 'watering') {
      await _plantRepository.updatePlant(plantId, {
        'status': 'healthy',
        'lastWatered': Timestamp.now(),
        'nextWatering': Timestamp.fromDate(
          DateTime.now().add(Duration(days: 7)) // Default, should come from care schedule
        ),
      });
    }
  }

  /// Check for overdue plants and send notifications
  Future<void> checkOverduePlants() async {
    // This could be called periodically to check for plants that need care
    // In a real implementation, this would be handled by Cloud Functions
  }

  /// Generate plant care tips based on plant type
  Map<String, String> getCareTips(String plantSpecies) {
    // This would be populated with actual care tips
    final tips = {
      'Monstera deliciosa': 'Provide bright, indirect light and water when top 2 inches of soil are dry.',
      'Sansevieria trifasciata': 'Very drought tolerant, water only when soil is completely dry.',
      'Ficus lyrata': 'Provide bright, indirect light and maintain consistent watering schedule.',
    };

    return {
      'tip': tips[plantSpecies] ?? 'Maintain appropriate light and water conditions for your plant.',
      'watering': 'Water when the top inch of soil is dry',
      'light': 'Provide appropriate light based on plant needs',
      'fertilizing': 'Fertilize during growing season',
    };
  }

  /// Calculate next care event date
  DateTime calculateNextCareDate(Plant plant, String eventType) {
    int frequency = 7; // default frequency

    switch (eventType) {
      case 'watering':
        frequency = plant.careSchedule['wateringFrequency'] ?? 7;
        break;
      case 'fertilizing':
        frequency = plant.careSchedule['fertilizingFrequency'] ?? 30;
        break;
      case 'misting':
        frequency = plant.careSchedule['mistingFrequency'] ?? 3;
        break;
      case 'rotating':
        frequency = plant.careSchedule['rotatingFrequency'] ?? 7;
        break;
    }

    return DateTime.now().add(Duration(days: frequency));
  }
}