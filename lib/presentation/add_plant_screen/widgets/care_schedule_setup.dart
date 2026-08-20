import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CareScheduleSetup extends StatefulWidget {
  final Function(Map<String, dynamic>) onScheduleChanged;

  const CareScheduleSetup({
    super.key,
    required this.onScheduleChanged,
  });

  @override
  State<CareScheduleSetup> createState() => _CareScheduleSetupState();
}

class _CareScheduleSetupState extends State<CareScheduleSetup> {
  double _wateringFrequency = 7.0; // days
  bool _fertilizingEnabled = false;
  bool _mistingEnabled = false;
  bool _rotatingEnabled = false;
  double _fertilizingFrequency = 30.0; // days
  double _mistingFrequency = 3.0; // days
  double _rotatingFrequency = 7.0; // days

  @override
  void initState() {
    super.initState();
    _updateSchedule();
  }

  void _updateSchedule() {
    widget.onScheduleChanged({
      'wateringFrequency': _wateringFrequency.round(),
      'fertilizingEnabled': _fertilizingEnabled,
      'fertilizingFrequency': _fertilizingFrequency.round(),
      'mistingEnabled': _mistingEnabled,
      'mistingFrequency': _mistingFrequency.round(),
      'rotatingEnabled': _rotatingEnabled,
      'rotatingFrequency': _rotatingFrequency.round(),
    });
  }

  String _getFrequencyText(double days) {
    if (days == 1) return 'Daily';
    if (days == 7) return 'Weekly';
    if (days == 14) return 'Bi-weekly';
    if (days == 30) return 'Monthly';
    return 'Every ${days.round()} days';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Care Schedule',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Set up automated reminders for plant care tasks',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 3.h),

          // Watering Schedule
          _buildWateringSchedule(),
          SizedBox(height: 3.h),

          // Additional Care Options
          _buildCareOption(
            title: 'Fertilizing',
            description: 'Nutrient feeding schedule',
            iconName: 'eco',
            isEnabled: _fertilizingEnabled,
            frequency: _fertilizingFrequency,
            minFrequency: 7,
            maxFrequency: 90,
            onToggle: (value) {
              setState(() {
                _fertilizingEnabled = value;
              });
              _updateSchedule();
            },
            onFrequencyChanged: (value) {
              setState(() {
                _fertilizingFrequency = value;
              });
              _updateSchedule();
            },
          ),
          SizedBox(height: 2.h),

          _buildCareOption(
            title: 'Misting',
            description: 'Humidity maintenance',
            iconName: 'water_drop',
            isEnabled: _mistingEnabled,
            frequency: _mistingFrequency,
            minFrequency: 1,
            maxFrequency: 14,
            onToggle: (value) {
              setState(() {
                _mistingEnabled = value;
              });
              _updateSchedule();
            },
            onFrequencyChanged: (value) {
              setState(() {
                _mistingFrequency = value;
              });
              _updateSchedule();
            },
          ),
          SizedBox(height: 2.h),

          _buildCareOption(
            title: 'Rotating',
            description: 'Even light exposure',
            iconName: 'rotate_right',
            isEnabled: _rotatingEnabled,
            frequency: _rotatingFrequency,
            minFrequency: 3,
            maxFrequency: 30,
            onToggle: (value) {
              setState(() {
                _rotatingEnabled = value;
              });
              _updateSchedule();
            },
            onFrequencyChanged: (value) {
              setState(() {
                _rotatingFrequency = value;
              });
              _updateSchedule();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWateringSchedule() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'water_drop',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watering Schedule',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      'Essential for plant health',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Frequency: ${_getFrequencyText(_wateringFrequency)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.lightTheme.colorScheme.primary,
              thumbColor: AppTheme.lightTheme.colorScheme.primary,
              overlayColor: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.2),
              inactiveTrackColor: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.3),
            ),
            child: Slider(
              value: _wateringFrequency,
              min: 1,
              max: 30,
              divisions: 29,
              onChanged: (value) {
                setState(() {
                  _wateringFrequency = value;
                });
                _updateSchedule();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                'Monthly',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCareOption({
    required String title,
    required String description,
    required String iconName,
    required bool isEnabled,
    required double frequency,
    required double minFrequency,
    required double maxFrequency,
    required Function(bool) onToggle,
    required Function(double) onFrequencyChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: isEnabled
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
              ),
            ],
          ),
          if (isEnabled) ...[
            SizedBox(height: 2.h),
            Text(
              'Frequency: ${_getFrequencyText(frequency)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: 1.h),
            Slider(
              value: frequency,
              min: minFrequency,
              max: maxFrequency,
              divisions: (maxFrequency - minFrequency).round(),
              onChanged: onFrequencyChanged,
            ),
          ],
        ],
      ),
    );
  }
}
