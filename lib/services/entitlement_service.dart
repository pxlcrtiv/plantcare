import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserTier { free, pro }

class EntitlementService {
  static final EntitlementService _instance = EntitlementService._internal();
  factory EntitlementService() => _instance;
  EntitlementService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserTier _currentTier = UserTier.free;

  UserTier get currentTier => _currentTier;
  bool get isPro => _currentTier == UserTier.pro;

  static const int freePlantLimit = 3;
  static const int freeDailyIdentifications = 5;

  Future<void> loadTier() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null && data['tier'] == 'pro') {
      _currentTier = UserTier.pro;
    } else {
      _currentTier = UserTier.free;
    }
  }

  Future<void> setTier(UserTier tier) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _currentTier = tier;
    await _firestore.collection('users').doc(user.uid).set(
      {'tier': tier.name},
      SetOptions(merge: true),
    );
  }

  bool canAddPlant(int currentPlantCount) {
    if (isPro) return true;
    return currentPlantCount < freePlantLimit;
  }

  bool canIdentify() {
    if (isPro) return true;
    return true;
  }

  int get maxPlants => isPro ? 9999 : freePlantLimit;
  int get maxDailyIdentifications =>
      isPro ? 9999 : freeDailyIdentifications;
}
