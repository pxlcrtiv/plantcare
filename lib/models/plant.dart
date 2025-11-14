import 'package:cloud_firestore/cloud_firestore.dart';

class Plant {
  final String id;
  final String name;
  final String species;
  final String imageUrl;
  final String status; // healthy, needs_attention, overdue
  final String? lastWatered;
  final String? nextWatering;
  final String? careNotes;
  final String? location;
  final DateTime dateAdded;
  final Map<String, dynamic> careSchedule;
  final List<String> photos;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.imageUrl,
    required this.status,
    this.lastWatered,
    this.nextWatering,
    this.careNotes,
    this.location,
    required this.dateAdded,
    required this.careSchedule,
    required this.photos,
  });

  // Convert from Firestore document
  factory Plant.fromMap(Map<String, dynamic> data) {
    return Plant(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      species: data['species'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'healthy',
      lastWatered: data['lastWatered'],
      nextWatering: data['nextWatering'],
      careNotes: data['careNotes'],
      location: data['location'],
      dateAdded: (data['dateAdded'] as Timestamp?)?.toDate() ?? DateTime.now(),
      careSchedule: Map<String, dynamic>.from(data['careSchedule'] ?? {}),
      photos: List<String>.from(data['photos'] ?? []),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'imageUrl': imageUrl,
      'status': status,
      'lastWatered': lastWatered,
      'nextWatering': nextWatering,
      'careNotes': careNotes,
      'location': location,
      'dateAdded': Timestamp.fromDate(dateAdded),
      'careSchedule': careSchedule,
      'photos': photos,
    };
  }
  
  // Helper method to format dates for display
  String getFormattedLastWatered() {
    if (lastWatered != null) {
      DateTime date;
      try {
        // Try parsing as ISO string first
        date = DateTime.parse(lastWatered!);
      } catch (e) {
        // If that fails, it might already be a timestamp field
        return 'Unknown';
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return 'Today';
      }
    }
    return 'Never';
  }
  
  String getFormattedNextWatering() {
    if (nextWatering != null) {
      DateTime date;
      try {
        // Try parsing as ISO string first
        date = DateTime.parse(nextWatering!);
      } catch (e) {
        // If that fails, it might already be a timestamp field
        return 'TBD';
      }
      
      final now = DateTime.now();
      final difference = date.difference(now);
      
      if (difference.inDays < 0) {
        return 'Overdue';
      } else if (difference.inDays == 0) {
        return 'Today';
      } else {
        return 'In ${difference.inDays} days';
      }
    }
    return 'TBD';
  }
}