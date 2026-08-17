import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../../core/app_export.dart';
import '../../repositories/plant_repository.dart';
import '../../repositories/plant_repository_impl.dart';
import '../../services/firebase_service.dart';
import '../../models/plant.dart';
import '../../widgets/floating_dock.dart';
import '../calendar/calendar_screen.dart';
import '../add_plant_screen/widgets/plant_database_browser.dart';
import '../care_assistant_hub/care_assistant_hub.dart';
import './widgets/home_tab.dart';
import './widgets/plant_list_tab.dart';
import './widgets/placeholder_tabs.dart';
import './widgets/quick_actions_sheet_widget.dart';

/// App shell: hosts the reference design's 5-tab dock (Home / Plant /
/// Search / Flask / Target) over an IndexedStack. Calendar + Profile are
/// reached from the Home header menu.
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

  int _currentNavIndex = 0;
  int _environmentIndex = 0;
  String _searchQuery = '';

  late PlantRepository _plantRepository;
  StreamSubscription<List<Plant>>? _plantsSubscription;
  List<Plant> _allPlants = [];
  List<Plant> _filteredPlants = [];

  @override
  void initState() {
    super.initState();

    _plantRepository =
        widget.plantRepository ?? PlantRepositoryImpl(FirebaseService());

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
    await Future.delayed(const Duration(milliseconds: 500));
    Fluttertoast.showToast(
      msg: "Plants data refreshed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  String get _userName {
    try {
      final displayName = FirebaseAuth.instance.currentUser?.displayName;
      if (displayName != null && displayName.isNotEmpty) return displayName;
    } catch (_) {
      // No Firebase app in test/detached contexts — fall back to default.
    }
    return 'Plant Parent';
  }

  String get _locationLabel {
    final code = Localizations.localeOf(context).countryCode;
    const names = {
      'US': 'United States',
      'GB': 'United Kingdom',
      'CA': 'Canada',
      'AU': 'Australia',
      'DE': 'Germany',
      'FR': 'France',
      'ES': 'Spain',
      'IT': 'Italy',
      'NL': 'Netherlands',
      'JP': 'Japan',
      'KR': 'South Korea',
      'CN': 'China',
      'IN': 'India',
      'BR': 'Brazil',
      'MX': 'Mexico',
      'SE': 'Sweden',
      'PL': 'Poland',
      'TR': 'Turkey',
      'VN': 'Vietnam',
      'TH': 'Thailand',
      'ID': 'Indonesia',
      'SG': 'Singapore',
      'PH': 'Philippines',
      'PT': 'Portugal',
      'IE': 'Ireland',
      'CH': 'Switzerland',
      'AT': 'Austria',
      'BE': 'Belgium',
      'DK': 'Denmark',
      'NO': 'Norway',
      'FI': 'Finland',
      'GR': 'Greece',
      'CZ': 'Czechia',
      'RO': 'Romania',
      'HU': 'Hungary',
      'IL': 'Israel',
      'SA': 'Saudi Arabia',
      'AE': 'United Arab Emirates',
      'ZA': 'South Africa',
      'NG': 'Nigeria',
      'EG': 'Egypt',
    };
    return names[code] ?? (code != null ? code : 'My Garden');
  }

  void _handlePlantTap(Plant plant) {
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
      'humidity': plant.humidity,
      'light': plant.light,
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
        'nextWatering': Timestamp.fromDate(DateTime.now().add(Duration(
            days: plant.careSchedule['wateringFrequency'] ?? 7))),
      });

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
      'humidity': plant.humidity,
      'light': plant.light,
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
              title: const Text('Camera Identification'),
              subtitle: const Text('Take a photo to identify your plant'),
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
              title: const Text('Browse Database'),
              subtitle: const Text('Search from our plant database'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentNavIndex = 2);
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
              title: const Text('Manual Entry'),
              subtitle: const Text('Add plant details manually'),
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

  void _handleAddFromDatabase(Map<String, dynamic> plant) {
    Navigator.pushNamed(context, '/add-plant-screen', arguments: {
      'database': plant,
    });
  }

  void _handleCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarScreen(plants: _allPlants),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentNavIndex,
          children: [
            HomeTab(
              userName: _userName,
              locationLabel: _locationLabel,
              plants: _allPlants,
              environmentIndex: _environmentIndex,
              onEnvironmentChanged: (i) => setState(() => _environmentIndex = i),
              onPlantTap: _handlePlantTap,
              onAddPlant: _handleAddPlant,
              onAddFromDatabase: _handleAddFromDatabase,
              onViewAllPlants: () => setState(() => _currentNavIndex = 1),
              onViewAllPopular: () => setState(() => _currentNavIndex = 2),
              onProfile: () =>
                  Navigator.pushNamed(context, '/profile-screen'),
              onCalendar: _handleCalendar,
              onScan: () =>
                  Navigator.pushNamed(context, '/plant-identification-camera'),
            ),
            PlantListTab(
              searchController: _searchController,
              plants: _filteredPlants,
              hasQuery: _searchQuery.isNotEmpty,
              onPlantTap: _handlePlantTap,
              onPlantLongPress: _handlePlantLongPress,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applySearchFilter();
                });
              },
              onClearSearch: _clearSearch,
              onAddPlant: _handleAddPlant,
              onRefresh: _handleRefresh,
            ),
            _buildSearchTab(),
            const CareAssistantHub(),
            IdentifyTab(
              onScan: () =>
                  Navigator.pushNamed(context, '/plant-identification-camera'),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentNavIndex == 1 && _filteredPlants.isNotEmpty
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
      bottomNavigationBar: FloatingDock(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        destinations: const [
          (icon: Icons.home, label: 'Home'),
          (icon: Icons.local_florist, label: 'Plant'),
          (icon: Icons.search, label: 'Search'),
          (icon: Icons.science, label: 'Flask'),
          (icon: Icons.qr_code_scanner, label: 'Target'),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 1.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Browse plants',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
        ),
        Expanded(
          child: PlantDatabaseBrowser(
            onPlantSelected: _handleAddFromDatabase,
          ),
        ),
      ],
    );
  }
}