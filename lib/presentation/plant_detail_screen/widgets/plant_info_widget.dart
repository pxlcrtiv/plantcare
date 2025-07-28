import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PlantInfoWidget extends StatefulWidget {
  final String plantName;
  final String species;
  final String difficulty;
  final VoidCallback onNameEdit;

  const PlantInfoWidget({
    Key? key,
    required this.plantName,
    required this.species,
    required this.difficulty,
    required this.onNameEdit,
  }) : super(key: key);

  @override
  State<PlantInfoWidget> createState() => _PlantInfoWidgetState();
}

class _PlantInfoWidgetState extends State<PlantInfoWidget> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plantName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.getSuccessColor(true);
      case 'medium':
        return AppTheme.getWarningColor(true);
      case 'hard':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant name (editable)
          Row(
            children: [
              Expanded(
                child: _isEditing
                    ? TextField(
                        controller: _nameController,
                        style: AppTheme.lightTheme.textTheme.headlineSmall,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            _isEditing = false;
                          });
                          widget.onNameEdit();
                        },
                      )
                    : Text(
                        widget.plantName,
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                  });
                  if (!_isEditing) {
                    widget.onNameEdit();
                  }
                },
                icon: CustomIconWidget(
                  iconName: _isEditing ? 'check' : 'edit',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Species information
          Text(
            'Species: $widget.species}',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 1.h),

          // Care difficulty indicator
          Row(
            children: [
              Text(
                'Care Difficulty: ',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getDifficultyColor(),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.difficulty.toUpperCase(),
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: _getDifficultyColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
