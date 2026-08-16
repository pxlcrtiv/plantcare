import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PlantInfoWidget extends StatefulWidget {
  final String plantName;
  final String species;
  final String difficulty;
  final int? humidity;
  final String? light;
  final int? wateringFrequency;
  final VoidCallback onNameEdit;

  const PlantInfoWidget({
    Key? key,
    required this.plantName,
    required this.species,
    required this.difficulty,
    this.humidity,
    this.light,
    this.wateringFrequency,
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
        return AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.dark);
      case 'medium':
        return AppTheme.getWarningColor(
            Theme.of(context).brightness == Brightness.dark);
      case 'hard':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildStatTile(
      {required Widget icon,
      required String value,
      required String label}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: 0.8.h),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 0.3.h),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.h),
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
                        style: Theme.of(context).textTheme.headlineSmall,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
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
                        style: Theme.of(context).textTheme.headlineSmall
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
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),

          SizedBox(height: 0.5.h),

          // Species + difficulty
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.species,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getDifficultyColor(), width: 1),
                ),
                child: Text(
                  widget.difficulty.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getDifficultyColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // Stats row
          Row(
            children: [
              _buildStatTile(
                icon: Icon(
                  Icons.water_drop,
                  size: 22,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.dropletDark
                      : AppTheme.dropletLight,
                ),
                value: '${widget.humidity ?? 65}%',
                label: 'Humidity',
              ),
              SizedBox(width: 2.5.w),
              _buildStatTile(
                icon: Icon(
                  Icons.wb_sunny,
                  size: 22,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.sunDark
                      : AppTheme.sunLight,
                ),
                value: widget.light ?? 'Sunny',
                label: 'Light',
              ),
              SizedBox(width: 2.5.w),
              _buildStatTile(
                icon: Icon(
                  Icons.water_drop_outlined,
                  size: 22,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.dropletDark
                      : AppTheme.dropletLight,
                ),
                value: '${widget.wateringFrequency ?? 7} days',
                label: 'Watering',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
