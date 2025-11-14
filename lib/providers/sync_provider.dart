import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/sync_service.dart';
import '../services/firebase_service.dart';

class SyncProvider extends ChangeNotifier {
  final SyncService _syncService;
  final FirebaseService _firebaseService;
  
  bool _isConnected = true;
  bool _isSyncing = false;
  String _syncStatus = "Synced";

  SyncProvider(this._syncService, this._firebaseService) {
    _initConnectivityListener();
  }

  bool get isConnected => _isConnected;
  bool get isSyncing => _isSyncing;
  String get syncStatus => _syncStatus;

  void _initConnectivityListener() {
    _syncService.connectionStream.listen((ConnectivityResult result) {
      final wasConnected = _isConnected;
      _isConnected = result != ConnectivityResult.none;
      
      if (wasConnected != _isConnected) {
        if (_isConnected) {
          // Connection restored, sync data
          _syncStatus = "Connecting...";
          notifyListeners();
          _syncService.handleOnlineMode().then((_) {
            _syncStatus = "Syncing...";
            notifyListeners();
            // Wait a moment then show synced
            Future.delayed(Duration(seconds: 2), () {
              if (_isConnected) {
                _syncStatus = "Synced";
              } else {
                _syncStatus = "Offline";
              }
              notifyListeners();
            });
          });
        } else {
          // Connection lost, switch to offline mode
          _syncService.handleOfflineMode();
          _syncStatus = "Offline";
          notifyListeners();
        }
      }
    });
  }

  Future<void> manualSync() async {
    if (!_isConnected) {
      _syncStatus = "Offline - Cannot sync";
      notifyListeners();
      return;
    }

    _isSyncing = true;
    _syncStatus = "Syncing...";
    notifyListeners();

    try {
      await _syncService.syncFromServer();
      _syncStatus = "Synced";
    } catch (e) {
      _syncStatus = "Sync failed: ${e.toString()}";
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void updateStatus(String status) {
    _syncStatus = status;
    notifyListeners();
  }
}