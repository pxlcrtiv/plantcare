import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/plant_card_widget.dart';
import './widgets/quick_actions_sheet_widget.dart';
import './widgets/search_bar_widget.dart';

class MyPlantsDashboard extends StatefulWidget {
  const MyPlantsDashboard({Key? key}) : super(key: key);

  @override
  State<MyPlantsDashboard> createState() => _MyPlantsDashboardState();
}

class _MyPlantsDashboardState extends State<MyPlantsDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentBottomNavIndex = 0;
  String _searchQuery = '';
  bool _isRefreshing = false;

  // Mock data for plants
  final List<Map<String, dynamic>> _allPlants = [
    {
      "id": 1,
      "name": "Monstera Deliciosa",
      "species": "Monstera deliciosa",
      "image":
          "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "status": "healthy",
      "lastWatered": "2 days ago",
      "nextWatering": "Tomorrow",
      "careNotes": "Loves bright, indirect light",
    },
    {
      "id": 2,
      "name": "Snake Plant",
      "species": "Sansevieria trifasciata",
      "image":
          "https://images.unsplash.com/photo-1593691509543-c55fb32d8de5?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "status": "needs_attention",
      "lastWatered": "1 week ago",
      "nextWatering": "Today",
      "careNotes": "Very low maintenance, drought tolerant",
    },
    {
      "id": 3,
      "name": "Fiddle Leaf Fig",
      "species": "Ficus lyrata",
      "image":
          "https://images.unsplash.com/photo-1586093248292-4e6636b4e3b8?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "status": "overdue",
      "lastWatered": "10 days ago",
      "nextWatering": "Overdue",
      "careNotes": "Needs consistent watering schedule",
    },
    {
      "id": 4,
      "name": "Peace Lily",
      "species": "Spathiphyllum wallisii",
      "image":
          "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "status": "healthy",
      "lastWatered": "3 days ago",
      "nextWatering": "In 4 days",
      "careNotes": "Droops when thirsty",
    },
    {
      "id": 5,
      "name": "Rubber Plant",
      "species": "Ficus elastica",
      "image":
          "https://images.unsplash.com/photo-1509423350716-97f2360af2e4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "status": "healthy",
      "lastWatered": "1 day ago",
      "nextWatering": "In 6 days",
      "careNotes": "Wipe leaves regularly for shine",
    },
    {
      "id": 6,
      "name": "Pothos",
      "species": "Epipremnum aureum",
      "image":
          "https://images.unsplash.com/photo-1586093248292-4e6636b4e3b8?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "status": "needs_attention",
      "lastWatered": "5 days ago",
      "nextWatering": "Today",
      "careNotes": "Great for beginners, very forgiving",
    },
  ];

  List<Map<String, dynamic>> get _filteredPlants {
    if (_searchQuery.isEmpty) {
      return _allPlants;
    }
    return _allPlants.where((plant) {
      final name = (plant['name'] as String).toLowerCase();
      final species = (plant['species'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || species.contains(query);
    }).toList();
  }

  int get _plantsNeedingCare {
    return _allPlants
        .where((plant) =>
            plant['status'] == 'needs_attention' ||
            plant['status'] == 'overdue')
        .length;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    Fluttertoast.showToast(
      msg: "Plants data refreshed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handlePlantTap(Map<String, dynamic> plant) {
    Navigator.pushNamed(context, '/plant-detail-screen', arguments: plant);
  }

  void _handlePlantLongPress(Map<String, dynamic> plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsSheetWidget(
        plant: plant,
        onWaterNow: () => _handleWaterPlant(plant),
        onViewDetails: () => _handlePlantTap(plant),
        onEdit: () => _handleEditPlant(plant),
        onRemove: () => _handleRemovePlant(plant),
      ),
    );
  }

  void _handleWaterPlant(Map<String, dynamic> plant) {
    setState(() {
      final index = _allPlants.indexWhere((p) => p['id'] == plant['id']);
      if (index != -1) {
        _allPlants[index]['status'] = 'healthy';
        _allPlants[index]['lastWatered'] = 'Just now';
        _allPlants[index]['nextWatering'] = 'In 7 days';
      }
    });

    Fluttertoast.showToast(
      msg: "${plant['name']} watered successfully! 💧",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleEditPlant(Map<String, dynamic> plant) {
    Navigator.pushNamed(context, '/add-plant-screen', arguments: plant);
  }

  void _handleRemovePlant(Map<String, dynamic> plant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Plant'),
        content: Text(
            'Are you sure you want to remove ${plant['name']} from your collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allPlants.removeWhere((p) => p['id'] == plant['id']);
              });
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "${plant['name']} removed from collection",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
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
        // Navigate to Profile (placeholder)
        Fluttertoast.showToast(
          msg: "Profile feature coming soon!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                            plant: plant,
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
