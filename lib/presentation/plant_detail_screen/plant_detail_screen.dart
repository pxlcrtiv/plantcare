import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

import '../../core/app_export.dart';
import '../../providers/plant_ai_service_provider.dart';
import '../../repositories/plant_repository.dart';
import '../../repositories/plant_repository_impl.dart';
import '../../services/firebase_service.dart';
import '../../services/plant_ai_service.dart';
import '../../services/plant_care_service.dart';
import '../../services/notification_service.dart';
import '../../models/plant.dart';
import './widgets/bottom_action_bar_widget.dart';
import './widgets/care_schedule_tab_widget.dart';
import './widgets/health_log_tab_widget.dart';
import './widgets/notes_tab_widget.dart';
import './widgets/photos_tab_widget.dart';
import './widgets/plant_hero_image_widget.dart';
import './widgets/plant_info_widget.dart';
import './widgets/reminder_settings_sheet.dart';

class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({
    Key? key,
    this.plantRepository,
    this.notificationService,
  }) : super(key: key);

  /// Optional repository override; defaults to the Firestore-backed
  /// implementation. Injectable so the screen can be built in tests without
  /// booting Firebase.
  final PlantRepository? plantRepository;

  /// Optional notification service override; defaults to the shared
  /// NotificationService.
  final NotificationService? notificationService;

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PlantRepository _plantRepository;
  late PlantCareService _plantCareService;
  
  Plant? _plant;
  List<Map<String, dynamic>> _careHistory = [];
  List<Map<String, dynamic>> _healthLogs = [];
  List<Map<String, dynamic>> _photos = [];
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _plantRepository =
        widget.plantRepository ?? PlantRepositoryImpl(FirebaseService());
    _plantCareService = PlantCareService(
      _plantRepository,
      widget.notificationService ?? NotificationService(),
    );
    
    // Load plant data from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlantData();
    });
  }

  Future<void> _loadPlantData() async {
    try {
      // Get the plant data from arguments passed from the previous screen
      final plantData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      if (plantData != null) {
        // Convert the map back to a Plant object
        setState(() {
          _plant = Plant(
            id: plantData['id'] ?? '',
            name: plantData['name'] ?? '',
            species: plantData['species'] ?? '',
            imageUrl: plantData['imageUrl'] ?? '',
            status: plantData['status'] ?? 'healthy',
            lastWatered: plantData['lastWatered'],
            nextWatering: plantData['nextWatering'],
            careNotes: plantData['careNotes'],
            location: plantData['location'],
            dateAdded: DateTime.parse(plantData['dateAdded'] ?? DateTime.now().toIso8601String()),
            careSchedule: Map<String, dynamic>.from(plantData['careSchedule'] ?? {}),
            photos: List<String>.from(plantData['photos'] ?? []),
          );
          
          _isLoading = false;
        });
      } else {
        // If no data was passed, go back to previous screen
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error loading plant data: $e");
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleEditPhoto() async {
    if (_plant == null || _isUploadingPhoto) return;

    // Let the user choose where the new photo comes from.
    final ImageSource? source = await _showPhotoSourceSheet();
    if (source == null || !mounted) return;

    final XFile? image;
    try {
      image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      if (mounted) {
        _showPhotoError('Failed to pick photo: ${e.toString()}');
      }
      return;
    }

    if (image == null || !mounted) return;

    setState(() {
      _isUploadingPhoto = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 30),
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
            SizedBox(width: 3.w),
            Text('Uploading photo…'),
          ],
        ),
      ),
    );

    try {
      // Upload the picked image to Firebase Storage, then persist the
      // resulting download URL on the plant via the repository.
      final String downloadUrl = await _uploadPhotoToStorage(image);
      await _plantRepository.updatePlant(_plant!.id, {
        'imageUrl': downloadUrl,
      });

      if (!mounted) return;

      // Refresh the local plant data with the new image.
      setState(() {
        _plant = Plant(
          id: _plant!.id,
          name: _plant!.name,
          species: _plant!.species,
          imageUrl: downloadUrl,
          status: _plant!.status,
          lastWatered: _plant!.lastWatered,
          nextWatering: _plant!.nextWatering,
          careNotes: _plant!.careNotes,
          location: _plant!.location,
          humidity: _plant!.humidity,
          light: _plant!.light,
          dateAdded: _plant!.dateAdded,
          careSchedule: _plant!.careSchedule,
          photos: _plant!.photos,
        );
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo updated successfully'),
          backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showPhotoError('Failed to update photo: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  /// Bottom sheet offering the photo sources; pops with the chosen
  /// [ImageSource], or null when dismissed.
  Future<ImageSource?> _showPhotoSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 12.w,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Edit Photo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 2.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text('Take Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'photo_library',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  title: Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Uploads the picked image to Firebase Storage under
  /// `plant-photos/{userId}/{plantId}/{timestamp}.jpg` (mirrors the
  /// Firestore `users/{userId}/plants/{plantId}` layout) and returns the
  /// download URL. Uses [putData] so it works on both mobile and web.
  Future<String> _uploadPhotoToStorage(XFile image) async {
    final String? userId = FirebaseService().currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final Reference ref = FirebaseStorage.instance.ref(
      'plant-photos/$userId/${_plant!.id}/'
      '${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await ref.putData(
      await image.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  void _showPhotoError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _handleSharePlant() async {
    final plant = _plant;
    if (plant == null) return;

    final buffer = StringBuffer()
      ..writeln('🌿 ${plant.name}'
          '${plant.species.isNotEmpty ? ' (${plant.species})' : ''}')
      ..writeln();

    final light = plant.light;
    if (light != null && light.isNotEmpty) {
      buffer.writeln('💡 Light: $light');
    }

    final humidity = plant.humidity;
    if (humidity != null) {
      buffer.writeln('💧 Humidity: $humidity%');
    }

    final wateringFrequency =
        (plant.careSchedule['wateringFrequency'] as num?)?.toInt();
    if (wateringFrequency != null) {
      buffer.writeln(
        '🚿 Water: '
        '${wateringFrequency == 1 ? 'daily' : 'every $wateringFrequency days'}',
      );
    }

    try {
      await SharePlus.instance.share(ShareParams(text: buffer.toString()));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share plant: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleNameEdit() async {
    if (_plant == null) return;

    final String? newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _NameEditDialog(
        initialName: _plant!.name,
      ),
    );

    if (newName == null || !mounted) return;

    try {
      // Persist the rename through the same repository used by other
      // updates (e.g. _handleWaterNow).
      await _plantRepository.updatePlant(_plant!.id, {'name': newName});

      if (!mounted) return;

      // Reload the local plant data so the UI reflects the new name.
      setState(() {
        _plant = Plant(
          id: _plant!.id,
          name: newName,
          species: _plant!.species,
          imageUrl: _plant!.imageUrl,
          status: _plant!.status,
          lastWatered: _plant!.lastWatered,
          nextWatering: _plant!.nextWatering,
          careNotes: _plant!.careNotes,
          location: _plant!.location,
          dateAdded: _plant!.dateAdded,
          careSchedule: _plant!.careSchedule,
          photos: _plant!.photos,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plant name updated'),
          backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update plant name: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleWaterNow() async {
    if (_plant == null) return;
    
    try {
      // Log watering event in Firebase
      await _plantRepository.addCareEvent(_plant!.id, {
        'type': 'watering',
        'date': DateTime.now().toIso8601String(),
        'notes': 'Watered via app',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Update plant status
      await _plantRepository.updatePlant(_plant!.id, {
        'status': 'healthy',
        'lastWatered': DateTime.now().toIso8601String(),
        'nextWatering': DateTime.now()
            .add(Duration(days: _plant!.careSchedule['wateringFrequency'] ?? 7))
            .toIso8601String(),
      });

      // Schedule next reminder
      await _plantCareService.scheduleCareReminders(_plant!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plant watered! Next watering scheduled.'),
            backgroundColor: AppTheme.getSuccessColor(Theme.of(context).brightness == Brightness.dark),
          ),
        );
        
        // Refresh local plant data
        setState(() {
          _plant = Plant(
            id: _plant!.id,
            name: _plant!.name,
            species: _plant!.species,
            imageUrl: _plant!.imageUrl,
            status: 'healthy',
            lastWatered: DateTime.now().toIso8601String(),
            nextWatering: DateTime.now()
                .add(Duration(days: _plant!.careSchedule['wateringFrequency'] ?? 7))
                .toIso8601String(),
            careNotes: _plant!.careNotes,
            location: _plant!.location,
            dateAdded: _plant!.dateAdded,
            careSchedule: _plant!.careSchedule,
            photos: _plant!.photos,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update watering: ${e.toString()}')),
      );
    }
  }

  void _handleAddPhoto() {
    // Navigate to camera or photo picker
    Navigator.pushNamed(context, '/plant-identification-camera');
  }

  void _handleLogCareEvent() {
    _showCareEventBottomSheet();
  }

  void _handleAddNote(String note) {
    // Save note to Firebase
    if (_plant != null) {
      _plantRepository.addHealthLog(_plant!.id, {
        'type': 'note',
        'title': 'Personal Note',
        'description': note,
        'date': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    
    setState(() {
      _notes.insert(0, {
        "date": DateTime.now(),
        "content": note,
        "isImportant": false,
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note added successfully')),
    );
  }

Future<void> _handleAddLog(
      String type, String notes, DateTime date) async {
    if (_plant == null) return;

    final log = {
      'type': type,
      'title': _capitalizeLogType(type),
      'description': notes,
      'date': date.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      // Persist through the same health-log mechanism the timeline uses
      // (the healthLogs subcollection is created on first write).
      await _plantRepository.addHealthLog(_plant!.id, log);

      if (mounted) {
        // Reload the timeline with the new entry.
        setState(() {
          _healthLogs.insert(0, log);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health log added successfully'),
            backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add health log: ${e.toString()}'),
          ),
        );
      }
    }
  }

  String _capitalizeLogType(String type) {
    if (type.isEmpty) return type;
    return type[0].toUpperCase() + type.substring(1);
  }

  void _handleEditNote(int index, String newContent) {
    if (index < 0 || index >= _notes.length) return;
    setState(() {
      _notes[index]['content'] = newContent;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note updated successfully')),
    );
  }

  void _handleToggleImportant(int index) {
    if (index < 0 || index >= _notes.length) return;
    setState(() {
      _notes[index]['isImportant'] =
          !(_notes[index]['isImportant'] as bool? ?? false);
    });
  }

  void _handleDeleteNote(int index) {
    if (index < 0 || index >= _notes.length) return;
    setState(() {
      _notes.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note deleted successfully')),
    );
  }

  void _showCareEventBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 54.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              Text(
                'Log Care Event',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),

              // Care event options
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.w,
                  childAspectRatio: 1.5,
                  children: [
                    _buildCareEventOption(
                      'Watering',
                      'water_drop',
                      Colors.blue,
                      () => _logCareEvent('watering'),
                    ),
                    _buildCareEventOption(
                      'Fertilizing',
                      'eco',
                      Colors.green,
                      () => _logCareEvent('fertilizing'),
                    ),
                    _buildCareEventOption(
                      'Pruning',
                      'content_cut',
                      Colors.orange,
                      () => _logCareEvent('pruning'),
                    ),
                    _buildCareEventOption(
                      'Repotting',
                      'home_work',
                      Colors.brown,
                      () => _logCareEvent('repotting'),
                    ),
                    _buildCareEventOption(
                      'Pest Treatment',
                      'bug_report',
                      Colors.red,
                      () => _logCareEvent('pest_treatment'),
                    ),
                    _buildCareEventOption(
                      'Other',
                      'more_horiz',
                      Theme.of(context).colorScheme.primary,
                      () => _logCareEvent('other'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildCareEventOption(
      String title, String iconName, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logCareEvent(String eventType) async {
    Navigator.pop(context);
    
    if (_plant != null) {
      try {
        await _plantRepository.addCareEvent(_plant!.id, {
          'type': eventType,
          'date': DateTime.now().toIso8601String(),
          'notes': 'Logged via app',
          'createdAt': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$eventType event logged successfully'),
              backgroundColor: AppTheme.getSuccessColor(Theme.of(context).brightness == Brightness.dark),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log care event: ${e.toString()}'),
          ),
        );
      }
    }
  }

  void _showHowToWater() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.water_drop,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'How to water',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 1.5.h),

              Text(
                'Water when the top 2–3 cm of soil feels dry to the '
                'touch. Pour slowly until water drains from the bottom, '
                'then empty the saucer so the roots never sit in water.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 3.h),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleLogCareEvent();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Add details',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReminderSettings() {
    final plant = _plant;
    if (plant == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReminderSettingsSheet(
        plant: plant,
        aiService: _aiService,
        onCareScheduleUpdated: _persistCareScheduleUpdate,
        onScheduleCareReminders: _plantCareService.scheduleCareReminders,
        onCancelPlantReminders: _plantCareService.cancelReminders,
        onReminderTimeTap: _handleReminderTime,
      ),
    );
  }

  Future<void> _persistCareScheduleUpdate(
    String plantId,
    Map<String, dynamic> updates,
  ) async {
    await _plantRepository.updatePlant(plantId, updates);
    final plant = _plant;
    if (plant == null || plant.id != plantId) return;
    final updatedSchedule = Map<String, dynamic>.from(plant.careSchedule);
    for (final entry in updates.entries) {
      updatedSchedule[entry.key.split('.').last] = entry.value;
    }
    final updatedPlant = _copyPlantWithSchedule(updatedSchedule);
    setState(() {
      _plant = updatedPlant;
    });
    try {
      await _plantCareService.scheduleCareReminders(updatedPlant);
    } catch (_) {}
  }

  Future<void> _handleReminderTime() async {
    if (_plant == null) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: _initialReminderTime(),
    );

    if (picked == null || !mounted) return;

    final reminderTime =
        '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';

    try {
      await _plantRepository.updatePlant(_plant!.id, {
        'careSchedule.reminderTime': reminderTime,
      });

      if (!mounted) return;

      final updatedSchedule = Map<String, dynamic>.from(_plant!.careSchedule)
        ..['reminderTime'] = reminderTime;

      setState(() {
        _plant = Plant(
          id: _plant!.id,
          name: _plant!.name,
          species: _plant!.species,
          imageUrl: _plant!.imageUrl,
          status: _plant!.status,
          lastWatered: _plant!.lastWatered,
          nextWatering: _plant!.nextWatering,
          careNotes: _plant!.careNotes,
          location: _plant!.location,
          dateAdded: _plant!.dateAdded,
          careSchedule: updatedSchedule,
          photos: _plant!.photos,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update reminder time: ${e.toString()}')),
      );
    }
  }

  TimeOfDay _initialReminderTime() {
    final saved = _plant?.careSchedule['reminderTime'];
    if (saved is String) {
      final parts = saved.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null &&
            minute != null &&
            hour >= 0 &&
            hour <= 23 &&
            minute >= 0 &&
            minute <= 59) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  PlantAiService get _aiService => PlantAiServiceProvider.of(context);

  Plant _copyPlantWithSchedule(Map<String, dynamic> schedule) {
    final plant = _plant!;
    return Plant(
      id: plant.id,
      name: plant.name,
      species: plant.species,
      imageUrl: plant.imageUrl,
      status: plant.status,
      lastWatered: plant.lastWatered,
      nextWatering: plant.nextWatering,
      careNotes: plant.careNotes,
      location: plant.location,
      humidity: plant.humidity,
      light: plant.light,
      dateAdded: plant.dateAdded,
      careSchedule: schedule,
      photos: plant.photos,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _plant == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Hero image section
          PlantHeroImageWidget(
            imageUrl: _plant!.imageUrl,
            plantName: _plant!.name,
            onEditPhoto: _handleEditPhoto,
            onSharePlant: _handleSharePlant,
          ),

          // Plant info section
          PlantInfoWidget(
            plantName: _plant!.name,
            species: _plant!.species,
            difficulty: _plant!.careSchedule['difficulty'] ?? 'Medium',
            humidity: _plant!.humidity,
            light: _plant!.light,
            wateringFrequency:
                (_plant!.careSchedule['wateringFrequency'] as num?)?.toInt(),
            onNameEdit: _handleNameEdit,
          ),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelPadding: EdgeInsets.symmetric(horizontal: 2.w),
              tabs: [
                Tab(text: 'Schedule'),
                Tab(text: 'Health'),
                Tab(text: 'Photos'),
                Tab(text: 'Notes'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CareScheduleTabWidget(
                  nextWateringDate: _plant!.nextWatering != null 
                      ? DateTime.parse(_plant!.nextWatering!) 
                      : DateTime.now().add(Duration(days: 7)),
                  onWaterNow: _handleWaterNow,
                  careHistory: _careHistory,
                ),
                HealthLogTabWidget(
                  healthLogs: _healthLogs,
                  onAddLog: _handleAddLog,
                ),
                PhotosTabWidget(
                  photos: _photos,
                  onAddPhoto: _handleAddPhoto,
                ),
                NotesTabWidget(
                  notes: _notes,
                  onAddNote: _handleAddNote,
                  onEditNote: _handleEditNote,
                  onToggleImportant: _handleToggleImportant,
                  onDeleteNote: _handleDeleteNote,
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: BottomActionBarWidget(
        onWaterPlant: _handleWaterNow,
        onAddPhoto: _handleAddPhoto,
        onLogCareEvent: _handleLogCareEvent,
        onHowToWater: _showHowToWater,
      ),

      // Floating action button for reminder settings
      floatingActionButton: FloatingActionButton(
        onPressed: _showReminderSettings,
        child: const Icon(Icons.notifications, color: Colors.white, size: 24),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Dialog used by [_PlantDetailScreenState._handleNameEdit] to collect a new
/// plant name. Owns its [TextEditingController] so the controller lifecycle
/// stays clean while the dialog route is being dismissed.
class _NameEditDialog extends StatefulWidget {
  const _NameEditDialog({required this.initialName});

  final String initialName;

  @override
  State<_NameEditDialog> createState() => _NameEditDialogState();
}

class _NameEditDialogState extends State<_NameEditDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    final newName = _controller.text.trim();
    if (newName.isEmpty) {
      setState(() {
        _errorText = 'Plant name cannot be empty';
      });
      return;
    }
    Navigator.of(context).pop(newName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Edit Plant Name',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _handleSave(),
        onChanged: (_) {
          if (_errorText != null) {
            setState(() {
              _errorText = null;
            });
          }
        },
        decoration: InputDecoration(
          labelText: 'Plant name',
          errorText: _errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: Text('Save'),
        ),
      ],
    );
  }
}
