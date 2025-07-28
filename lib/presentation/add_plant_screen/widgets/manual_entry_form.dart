import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ManualEntryForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;

  const ManualEntryForm({
    super.key,
    required this.onFormChanged,
  });

  @override
  State<ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<ManualEntryForm> {
  final TextEditingController _plantNameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  String _selectedLocation = '';

  final List<String> _commonLocations = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Bathroom',
    'Balcony',
    'Office',
    'Dining Room',
    'Custom Location'
  ];

  final List<String> _plantSuggestions = [
    'Monstera Deliciosa',
    'Snake Plant',
    'Pothos',
    'Fiddle Leaf Fig',
    'Peace Lily',
    'Rubber Plant',
    'ZZ Plant',
    'Philodendron',
    'Spider Plant',
    'Aloe Vera'
  ];

  @override
  void initState() {
    super.initState();
    _plantNameController.addListener(_updateForm);
    _speciesController.addListener(_updateForm);
  }

  void _updateForm() {
    widget.onFormChanged({
      'plantName': _plantNameController.text,
      'species': _speciesController.text,
      'location': _selectedLocation,
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
            'Plant Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 3.h),

          // Plant Name Field
          TextFormField(
            controller: _plantNameController,
            decoration: InputDecoration(
              labelText: 'Plant Name *',
              hintText: 'Enter a name for your plant',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'local_florist',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 2.h),

          // Species Field with Autocomplete
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return _plantSuggestions.where((String option) {
                return option
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _speciesController.text = selection;
              _updateForm();
            },
            fieldViewBuilder:
                (context, controller, focusNode, onEditingComplete) {
              _speciesController.text = controller.text;
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                onEditingComplete: onEditingComplete,
                decoration: InputDecoration(
                  labelText: 'Species (Optional)',
                  hintText: 'e.g., Monstera Deliciosa',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  _speciesController.text = value;
                  _updateForm();
                },
              );
            },
          ),
          SizedBox(height: 3.h),

          // Location Selection
          Text(
            'Location in Home',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 1.h),

          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _commonLocations.map((location) {
              final isSelected = _selectedLocation == location;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLocation = location;
                  });
                  _updateForm();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    location,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.onPrimary
                              : AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    _speciesController.dispose();
    super.dispose();
  }
}
