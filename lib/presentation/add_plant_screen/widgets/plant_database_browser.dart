import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PlantDatabaseBrowser extends StatefulWidget {
  final Function(Map<String, dynamic>) onPlantSelected;

  const PlantDatabaseBrowser({
    super.key,
    required this.onPlantSelected,
  });

  @override
  State<PlantDatabaseBrowser> createState() => _PlantDatabaseBrowserState();
}

class _PlantDatabaseBrowserState extends State<PlantDatabaseBrowser> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';
  String _selectedCareLevel = 'All';
  String _selectedLightRequirement = 'All';
  List<Map<String, dynamic>> _filteredPlants = [];

  final List<String> _plantTypes = [
    'All',
    'Houseplant',
    'Succulent',
    'Herb',
    'Flowering',
    'Fern',
    'Tropical'
  ];
  final List<String> _careLevels = ['All', 'Easy', 'Moderate', 'Advanced'];
  final List<String> _lightRequirements = [
    'All',
    'Low Light',
    'Medium Light',
    'Bright Light',
    'Direct Sun'
  ];

  final List<Map<String, dynamic>> _plantDatabase = [
    {
      'id': 1,
      'name': 'Monstera Deliciosa',
      'commonName': 'Swiss Cheese Plant',
      'type': 'Houseplant',
      'careLevel': 'Easy',
      'lightRequirement': 'Medium Light',
      'wateringFrequency': 7,
      'description': 'Popular houseplant with distinctive split leaves',
      'image':
          'https://images.pexels.com/photos/6208086/pexels-photo-6208086.jpeg?auto=compress&cs=tinysrgb&w=800',
      'tips': 'Loves humidity and bright, indirect light'
    },
    {
      'id': 2,
      'name': 'Sansevieria Trifasciata',
      'commonName': 'Snake Plant',
      'type': 'Houseplant',
      'careLevel': 'Easy',
      'lightRequirement': 'Low Light',
      'wateringFrequency': 14,
      'description': 'Hardy plant perfect for beginners',
      'image':
          'https://images.pexels.com/photos/2123482/pexels-photo-2123482.jpeg?auto=compress&cs=tinysrgb&w=800',
      'tips': 'Very drought tolerant, avoid overwatering'
    },
    {
      'id': 3,
      'name': 'Epipremnum Aureum',
      'commonName': 'Golden Pothos',
      'type': 'Houseplant',
      'careLevel': 'Easy',
      'lightRequirement': 'Medium Light',
      'wateringFrequency': 7,
      'description': 'Trailing vine with heart-shaped leaves',
      'image':
          'https://images.pexels.com/photos/4751978/pexels-photo-4751978.jpeg?auto=compress&cs=tinysrgb&w=800',
      'tips': 'Great for hanging baskets or climbing'
    },
    {
      'id': 4,
      'name': 'Ficus Lyrata',
      'commonName': 'Fiddle Leaf Fig',
      'type': 'Houseplant',
      'careLevel': 'Advanced',
      'lightRequirement': 'Bright Light',
      'wateringFrequency': 7,
      'description': 'Statement plant with large, violin-shaped leaves',
      'image':
          'https://images.pexels.com/photos/6208087/pexels-photo-6208087.jpeg?auto=compress&cs=tinysrgb&w=800',
      'tips': 'Sensitive to changes in environment'
    },
    {
      'id': 5,
      'name': 'Spathiphyllum',
      'commonName': 'Peace Lily',
      'type': 'Flowering',
      'careLevel': 'Moderate',
      'lightRequirement': 'Medium Light',
      'wateringFrequency': 5,
      'description': 'Elegant plant with white flowers',
      'image':
          'https://images.pexels.com/photos/7084308/pexels-photo-7084308.jpeg?auto=compress&cs=tinysrgb&w=800',
      'tips': 'Droops when thirsty, making watering easy'
    },
    {
      'id': 6,
      'name': 'Aloe Vera',
      'commonName': 'Aloe',
      'type': 'Succulent',
      'careLevel': 'Easy',
      'lightRequirement': 'Bright Light',
      'wateringFrequency': 14,
      'description': 'Medicinal succulent with healing properties',
      'image':
          'https://images.pexels.com/photos/4503821/pexels-photo-4503821.jpeg?auto=compress&cs=tinysrgb&w=800',
      'tips': 'Use gel from leaves for minor burns'
    },
    {
      'id': 7,
      'name': 'Zamioculcas Zamiifolia',
      'commonName': 'ZZ Plant',
      'type': 'Houseplant',
      'careLevel': 'Easy',
      'lightRequirement': 'Low Light',
      'wateringFrequency': 21,
      'description': 'Glossy, drought-tolerant houseplant',
      'image':
          'https://images.pexels.com/photos/6208083/pexels-photo-6208083.jpeg?auto=compress&cs=tinysrgb&w=800',
      'tips': 'Perfect for low-light offices'
    },
    {
      'id': 8,
      'name': 'Basil',
      'commonName': 'Sweet Basil',
      'type': 'Herb',
      'careLevel': 'Moderate',
      'lightRequirement': 'Direct Sun',
      'wateringFrequency': 3,
      'description': 'Aromatic herb perfect for cooking',
      'image':
          'https://images.pexels.com/photos/4750270/pexels-photo-4750270.jpeg?auto=compress&cs=tinysrgb&w=800',
      'tips': 'Pinch flowers to keep leaves tender'
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredPlants = List.from(_plantDatabase);
    _searchController.addListener(_filterPlants);
  }

  void _filterPlants() {
    setState(() {
      _filteredPlants = _plantDatabase.where((plant) {
        final matchesSearch = _searchController.text.isEmpty ||
            (plant['name'] as String)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            (plant['commonName'] as String)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        final matchesType =
            _selectedType == 'All' || plant['type'] == _selectedType;
        final matchesCareLevel = _selectedCareLevel == 'All' ||
            plant['careLevel'] == _selectedCareLevel;
        final matchesLight = _selectedLightRequirement == 'All' ||
            plant['lightRequirement'] == _selectedLightRequirement;

        return matchesSearch && matchesType && matchesCareLevel && matchesLight;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse Plant Database',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Find your plant from our curated collection',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 2.h),

          // Search Bar
          TextFormField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search plants...',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _filterPlants();
                      },
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 5.w,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 2.h),

          // Filter Chips
          _buildFilterChips(),
          SizedBox(height: 2.h),

          // Results Count
          Text(
            '${_filteredPlants.length} plants found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          SizedBox(height: 1.h),

          // Plant List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPlants.length,
              itemBuilder: (context, index) {
                final plant = _filteredPlants[index];
                return _buildPlantCard(plant);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plant Type Filter
        Text(
          'Plant Type',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 0.5.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _plantTypes.map((type) {
              final isSelected = _selectedType == type;
              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                    _filterPlants();
                  },
                  backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                  selectedColor: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 1.h),

        // Care Level Filter
        Text(
          'Care Level',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 0.5.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _careLevels.map((level) {
              final isSelected = _selectedCareLevel == level;
              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCareLevel = level;
                    });
                    _filterPlants();
                  },
                  backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                  selectedColor: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: () => widget.onPlantSelected(plant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              // Plant Image
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.lightTheme.colorScheme.surface,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageWidget(
                    imageUrl: plant['image'] as String,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 4.w),

              // Plant Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant['commonName'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      plant['name'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    SizedBox(height: 0.5.h),

                    // Care Info Tags
                    Wrap(
                      spacing: 1.w,
                      runSpacing: 0.5.h,
                      children: [
                        _buildInfoTag(
                            plant['careLevel'] as String, 'psychology'),
                        _buildInfoTag(
                            plant['lightRequirement'] as String, 'wb_sunny'),
                        _buildInfoTag(
                            '${plant['wateringFrequency']} days', 'water_drop'),
                      ],
                    ),
                    SizedBox(height: 1.h),

                    Text(
                      plant['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Select Button
              CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(String text, String iconName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 3.w,
          ),
          SizedBox(width: 1.w),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
