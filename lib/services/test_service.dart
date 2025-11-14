import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';

class TestService {
  static Future<void> runTests() async {
    print("Starting end-to-end functionality tests...");
    
    // Test 1: Verify Plant model can be converted to/from Firestore map
    await _testPlantModel();
    
    // Test 2: Verify Firebase connectivity
    await _testFirebaseConnection();
    
    print("All tests completed!");
  }
  
  static Future<void> _testPlantModel() async {
    print("\n--- Testing Plant Model ---");
    
    // Create a sample plant
    final samplePlant = Plant(
      id: "test_id_123",
      name: "Test Plant",
      species: "Test Species",
      imageUrl: "https://example.com/test-plant.jpg",
      status: "healthy",
      lastWatered: DateTime.now().toIso8601String(),
      nextWatering: DateTime.now().add(Duration(days: 7)).toIso8601String(),
      careNotes: "This is a test plant",
      location: "Living room",
      dateAdded: DateTime.now(),
      careSchedule: {
        'wateringFrequency': 7,
        'fertilizingEnabled': true,
        'fertilizingFrequency': 30,
      },
      photos: ["https://example.com/photo1.jpg"],
    );
    
    // Convert to map
    final plantMap = samplePlant.toMap();
    print("✓ Plant converted to map successfully");
    
    // Convert back from map
    final plantFromMap = Plant.fromMap(plantMap);
    print("✓ Plant recreated from map successfully");
    
    // Verify data integrity
    assert(plantFromMap.id == samplePlant.id);
    assert(plantFromMap.name == samplePlant.name);
    assert(plantFromMap.species == samplePlant.species);
    assert(plantFromMap.status == samplePlant.status);
    print("✓ Data integrity verified");
  }
  
  static Future<void> _testFirebaseConnection() async {
    print("\n--- Testing Firebase Connection ---");
    
    try {
      // Attempt to access Firestore
      final collection = FirebaseFirestore.instance.collection('test');
      
      // Try to get a document (this will fail if not connected properly)
      await collection.limit(1).get();
      
      print("✓ Firebase connection established successfully");
    } catch (e) {
      print("✗ Firebase connection failed: $e");
    }
  }
}