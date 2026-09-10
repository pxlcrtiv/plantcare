import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/plant.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Authentication methods
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      return null;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Create user error: ${e.message}');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = 
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Sign in with the credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Google sign in error: ${e.message}');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // Plants data methods
  Stream<List<Plant>> getPlants() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => Plant.fromMap(doc.data())).toList()
        );
  }

  Future<void> addPlant(Plant plant) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .add(plant.toMap());
  }

  Future<void> updatePlant(String plantId, Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .update(data);
  }

  Future<void> deletePlant(String plantId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .delete();
  }

  // Care events methods
  Future<void> addCareEvent(String plantId, Map<String, dynamic> event) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .collection('careEvents')
        .add(event);
  }

  // Health logs methods
  Future<void> addHealthLog(String plantId, Map<String, dynamic> log) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .collection('healthLogs')
        .add(log);
  }

  // Account deletion — batched to minimize Firestore reads/writes
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userId = user.uid;
    final plantsRef = _firestore.collection('users').doc(userId).collection('plants');
    final plants = await plantsRef.get();

    var batch = _firestore.batch();
    var ops = 0;

    for (final plant in plants.docs) {
      final careEvents = await plant.reference.collection('careEvents').get();
      for (final doc in careEvents.docs) {
        batch.delete(doc.reference);
        ops++;
      }
      final healthLogs = await plant.reference.collection('healthLogs').get();
      for (final doc in healthLogs.docs) {
        batch.delete(doc.reference);
        ops++;
      }
      batch.delete(plant.reference);
      ops++;

      if (ops >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        ops = 0;
      }
    }

    batch.delete(_firestore.collection('users').doc(userId));
    await batch.commit();

    await user.delete();
  }
}