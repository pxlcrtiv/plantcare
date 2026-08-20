import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../core/app_export.dart';
import '../../repositories/plant_repository.dart';
import '../../repositories/plant_repository_impl.dart';
import '../../services/firebase_service.dart';
import '../../models/plant.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/plant_card_widget.dart';
import './widgets/quick_actions_sheet_widget.dart';
import './widgets/search_bar_widget.dart';

class MyPlantsDashboard extends StatefulWidget {
  const MyPlantsDashboard({Key? key, this.plantRepository}) : super(key: key);

  /// Optional repository override; defaults to the Firestore-backed
  /// implementation. Injectable so screens can be driven in tests without
  /// booting Firebase.
  final PlantRepository? plantRepository;

  @override
  State<MyPlantsDashboard> createState() => _MyPlantsDashboardState();
}

class _MyPlantsDashboardState extends State<MyPlantsDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentBottomNavIndex = 0;
  String _searchQuery = '';

  late PlantRepository _plantRepository;
  StreamSubscription<List<Plant>>? _plantsSubscription;
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = [];

  int get _plantsNeedingCare {
    return _allPlants
        .where((plant) =>
            plant.status == 'needs_attention' ||
            plant.status == 'overdue')
        .length;
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize the repository
    _plantRepository =
        widget.plantRepository ?? PlantRepositoryImpl(FirebaseService());
    
    // Listen to plant changes
    _plantsSubscription = _plantRepository.getPlants().listen((plants) {
      setState(() {
        _allPlants = plants;
        _applySearchFilter();
      });
    });
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _applySearchFilter();
      });
    });
  }
  
  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredPlants = _allPlants;
    } else {
      _filteredPlants = _allPlants.where((plant) {
        final name = plant.name.toLowerCase();
        final species = plant.species.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || species.contains(query);
      }).toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _plantsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // In a real implementation, we could force refresh from server if needed
    // For Firestore, the real-time listener already keeps data updated
    await Future.delayed(Duration(milliseconds: 500));

    Fluttertoast.showToast(
      msg: "Plants data refreshed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handlePlantTap(Plant plant) {
    // Convert Plant object to Map for navigation (for compatibility with existing detail screen)
    final plantMap = {
      'id': plant.id,
      'name': plant.name,
      'species': plant.species,
      'imageUrl': plant.imageUrl,
      'status': plant.status,
      'lastWatered': plant.lastWatered,
      'nextWatering': plant.nextWatering,
      'careNotes': plant.careNotes,
      'location': plant.location,
      'dateAdded': plant.dateAdded.toString(),
      'careSchedule': plant.careSchedule,
      'photos': plant.photos,
    };
    Navigator.pushNamed(context, '/plant-detail-screen', arguments: plantMap);
  }

  void _handlePlantLongPress(Plant plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsSheetWidget(
        plant: {
          'id': plant.id,
          'name': plant.name,
          'species': plant.species,
          'imageUrl': plant.imageUrl,
          'status': plant.status,
          'lastWatered': plant.lastWatered,
          'nextWatering': plant.nextWatering,
          'careNotes': plant.careNotes,
          'location': plant.location,
        },
        onWaterNow: () => _handleWaterPlant(plant),
        onViewDetails: () => _handlePlantTap(plant),
        onEdit: () => _handleEditPlant(plant),
        onRemove: () => _handleRemovePlant(plant),
      ),
    );
  }

  Future<void> _handleWaterPlant(Plant plant) async {
    try {
      await _plantRepository.updatePlant(plant.id, {
        'status': 'healthy',
        'lastWatered': Timestamp.now(),
        'nextWatering': Timestamp.fromDate(DateTime.now().add(Duration(days: plant.careSchedule['wateringFrequency'] ?? 7))),
      });

      // Add care event
      await _plantRepository.addCareEvent(plant.id, {
        'type': 'watering',
        'date': Timestamp.now(),
        'notes': 'Watered via app',
        'createdAt': Timestamp.now(),
      });

      Fluttertoast.showToast(
        msg: "${plant.name} watered successfully! 💧",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update plant: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _handleEditPlant(Plant plant) {
    // Convert Plant object to Map for navigation
    final plantMap = {
      'id': plant.id,
      'name': plant.name,
      'species': plant.species,
      'imageUrl': plant.imageUrl,
      'status': plant.status,
      'lastWatered': plant.lastWatered,
      'nextWatering': plant.nextWatering,
      'careNotes': plant.careNotes,
      'location': plant.location,
      'careSchedule': plant.careSchedule,
    };
    Navigator.pushNamed(context, '/add-plant-screen', arguments: plantMap);
  }

  Future<void> _handleRemovePlant(Plant plant) async {
    try {
      await _plantRepository.deletePlant(plant.id);
      
      Fluttertoast.showToast(
        msg: "${plant.name} removed from collection",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to remove plant: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _handleAddPlant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomSheetTheme.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Add New Plant',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: Theme.of(context).colorScheme.primary,
                  size: 6.w,
                ),
              ),
              title: Text('Camera Identification'),
              subtitle: Text('Take a photo to identify your plant'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/plant-identification-camera');
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: Theme.of(context).colorScheme.secondary,
                  size: 6.w,
                ),
              ),
              title: Text('Browse Database'),
              subtitle: Text('Search from our plant database'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-plant-screen');
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.getAccentColor(
                          Theme.of(context).brightness == Brightness.dark)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.getAccentColor(
                      Theme.of(context).brightness == Brightness.dark),
                  size: 6.w,
                ),
              ),
              title: Text('Manual Entry'),
              subtitle: Text('Add plant details manually'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-plant-screen',
                    arguments: {'manual': true});
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on My Plants
        break;
      case 1:
        // Navigate to Calendar (placeholder)
        Fluttertoast.showToast(
          msg: "Calendar feature coming soon!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/plant-identification-camera');
        break;
      case 3:
        // Navigate to Profile
        Navigator.pushNamed(context, '/profile-screen');
        break;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String currentDate = "${now.month}/${now.day}/${now.year}";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Greeting Header
            GreetingHeaderWidget(
              userName: "Plant Parent",
              currentDate: currentDate,
              weatherInfo: "72°F",
              plantsNeedingCare: _plantsNeedingCare,
            ),

            // Search Bar
            SearchBarWidget(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applySearchFilter();
                });
              },
              onClear: _clearSearch,
            ),

            // Main Content
            Expanded(
              child: _filteredPlants.isEmpty
                  ? _searchQuery.isNotEmpty
                      ? _buildNoSearchResults()
                      : EmptyStateWidget(onAddPlant: _handleAddPlant)
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getCrossAxisCount(),
                          crossAxisSpacing: 3.w,
                          mainAxisSpacing: 3.w,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredPlants.length,
                        itemBuilder: (context, index) {
                          final plant = _filteredPlants[index];
                          return PlantCardWidget(
                            plant: {
                              'id': plant.id,
                              'name': plant.name,
                              'species': plant.species,
                              'imageUrl': plant.imageUrl,
                              'status': plant.status,
                              'lastWatered': plant.lastWatered,
                              'nextWatering': plant.nextWatering,
                              'careNotes': plant.careNotes,
                            },
                            onTap: () => _handlePlantTap(plant),
                            onLongPress: () => _handlePlantLongPress(plant),
                            onWaterTap: () => _handleWaterPlant(plant),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: _filteredPlants.isNotEmpty
          ? FloatingActionButton(
              onPressed: _handleAddPlant,
              child: CustomIconWidget(
                iconName: 'add',
                color: Theme.of(context)
                    .floatingActionButtonTheme
                    .foregroundColor!,
                size: 7.w,
              ),
            )
          : null,

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Plants Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try searching with different keywords or add a new plant to your collection.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _clearSearch,
              child: Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 3; // Tablet
    }
    return 2; // Phone
  }
}
