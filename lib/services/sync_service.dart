import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/plant_repository.dart';

class SyncService {
  final PlantRepository _repository;
  final FirebaseFirestore _firestore;

  SyncService(this._repository, this._firestore);

  /// Check if device has internet connection
  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  /// Force sync data from server
  Future<void> syncFromServer() async {
    try {
      // This will trigger the real-time listener to update data
      // In Firestore, the real-time listeners already keep data updated
      // This method could be used to force refresh specific collections if needed
      print("Sync initiated from server");
    } catch (e) {
      throw Exception("Sync failed: $e");
    }
  }

  /// Sync local changes to server (normally handled automatically by Firestore)
  Future<void> syncToServer() async {
    // Firestore handles this automatically, but we could implement 
    // specific logic if needed for batch operations
    print("Sync data to server");
  }

  /// Handle offline mode
  Future<void> handleOfflineMode() async {
    // Configure Firestore to work offline
    await _firestore.disableNetwork();
  }

  /// Handle online mode
  Future<void> handleOnlineMode() async {
    // Re-enable network for Firestore
    await _firestore.enableNetwork();
  }

  /// Monitor connection status
  Stream<ConnectivityResult> get connectionStream => 
      Connectivity().onConnectivityChanged;
}