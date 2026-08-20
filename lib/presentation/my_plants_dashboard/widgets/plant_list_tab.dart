import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/plant.dart';
import 'empty_state_widget.dart';
import 'plant_card_widget.dart';
import 'search_bar_widget.dart';

/// "Plant" dock tab: the collection list with search — the old dashboard
/// body, minus the greeting header (now on Home).
class PlantListTab extends StatelessWidget {
  final TextEditingController searchController;
  final List<Plant> plants;
  final bool hasQuery;
  final void Function(Plant) onPlantTap;
  final void Function(Plant) onPlantLongPress;
  final void Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onAddPlant;
  final Future<void> Function() onRefresh;

  const PlantListTab({
    super.key,
    required this.searchController,
    required this.plants,
    required this.hasQuery,
    required this.onPlantTap,
    required this.onPlantLongPress,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onAddPlant,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 0),
          child: SearchBarWidget(
            controller: searchController,
            onChanged: onSearchChanged,
            onClear: onClearSearch,
          ),
        ),
        Expanded(
          child: plants.isEmpty
              ? hasQuery
                  ? _buildNoResults(context)
                  : EmptyStateWidget(onAddPlant: onAddPlant)
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: 4.w, vertical: 2.h),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(context),
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 3.w,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];
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
                        onTap: () => onPlantTap(plant),
                        onLongPress: () => onPlantLongPress(plant),
                        onWaterTap: () => onPlantTap(plant),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNoResults(BuildContext context) {
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
              onPressed: onClearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 3; // Tablet
    }
    return 2; // Phone
  }
}