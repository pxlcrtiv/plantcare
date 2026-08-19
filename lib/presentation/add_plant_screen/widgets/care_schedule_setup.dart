import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../../providers/plant_ai_service_provider.dart';
import '../../../../services/plant_ai_service.dart';
import '../../../../widgets/ai_error_card.dart';
import '../../../../widgets/ai_schedule_suggestion_card.dart';

class CareScheduleSetup extends StatefulWidget {
  final Function(Map<String, dynamic>) onScheduleChanged;

  /// Values used to prefill the schedule (e.g. when editing an existing plant).
  final Map<String, dynamic>? initialData;

  final String species;
  final String? light;
  final int? humidity;
  final String? location;

  const CareScheduleSetup({
    super.key,
    required this.onScheduleChanged,
    this.initialData,
    this.species = '',
    this.light,
    this.humidity,
    this.location,
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

  PlantAiService _service = const StubPlantAiService();
  ScheduleSuggestion? _proposal;
  PlantAiException? _proposalError;
  bool _isProposing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = PlantAiServiceProvider.of(context);
    if (!identical(service, _service)) {
      _service = service;
    }
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData;
    if (initial != null) {
      double clamped(num? value, double min, double max) =>
          (value ?? 0).toDouble().clamp(min, max);
      _wateringFrequency = clamped(
          initial['wateringFrequency'] as num?, 1, 30);
      _fertilizingEnabled = initial['fertilizingEnabled'] == true;
      _mistingEnabled = initial['mistingEnabled'] == true;
      _rotatingEnabled = initial['rotatingEnabled'] == true;
      _fertilizingFrequency =
          clamped(initial['fertilizingFrequency'] as num?, 7, 90);
      _mistingFrequency =
          clamped(initial['mistingFrequency'] as num?, 1, 14);
      _rotatingFrequency =
          clamped(initial['rotatingFrequency'] as num?, 3, 30);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSchedule();
    });
  }

  Map<String, dynamic> _currentSchedule() {
    return {
      'wateringFrequency': _wateringFrequency.round(),
      'fertilizingEnabled': _fertilizingEnabled,
      'fertilizingFrequency': _fertilizingFrequency.round(),
      'mistingEnabled': _mistingEnabled,
      'mistingFrequency': _mistingFrequency.round(),
      'rotatingEnabled': _rotatingEnabled,
      'rotatingFrequency': _rotatingFrequency.round(),
    };
  }

  void _updateSchedule() {
    widget.onScheduleChanged(_currentSchedule());
  }

  Future<void> _proposeSchedule() async {
    setState(() {
      _isProposing = true;
      _proposalError = null;
    });
    try {
      final suggestion = await _service.suggestWateringSchedule(
        ScheduleRequest(
          species: widget.species,
          light: widget.light,
          humidity: widget.humidity,
          location: widget.location,
          careSchedule: _currentSchedule(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _proposal = suggestion;
        _isProposing = false;
      });
    } on PlantAiException catch (error) {
      if (!mounted) return;
      setState(() {
        _proposalError = error;
        _isProposing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _proposalError = const UnknownError();
        _isProposing = false;
      });
    }
  }

  void _confirmProposal() {
    final proposal = _proposal;
    if (proposal == null) return;
    double clamp(double value, double min, double max) =>
        value.clamp(min, max);
    setState(() {
      _wateringFrequency = clamp(
          proposal.wateringFrequency.toDouble(), 1, 30);
      _fertilizingEnabled = proposal.fertilizingEnabled;
      _fertilizingFrequency = clamp(
          proposal.fertilizingFrequency.toDouble(), 7, 90);
      _mistingEnabled = proposal.mistingEnabled;
      _mistingFrequency = clamp(
          proposal.mistingFrequency.toDouble(), 1, 14);
      _rotatingEnabled = proposal.rotatingEnabled;
      _rotatingFrequency = clamp(
          proposal.rotatingFrequency.toDouble(), 3, 30);
      _proposal = null;
    });
    _updateSchedule();
  }

  void _retryProposal() {
    setState(() {
      _proposal = null;
      _proposalError = null;
    });
    _proposeSchedule();
  }

  void _cancelProposal() {
    setState(() {
      _proposal = null;
      _proposalError = null;
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Set up automated reminders for plant care tasks',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 3.h),

          _buildAiScheduleProposal(),
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

  Widget _buildAiScheduleProposal() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isProposing ? null : _proposeSchedule,
            icon: _isProposing
                ? SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(Icons.auto_awesome, size: 5.w),
            label: Text(_isProposing ? 'Proposing…' : 'Generate AI schedule'),
          ),
        ),
        if (_proposalError != null) ...[
          SizedBox(height: 2.h),
          AiErrorCard(error: _proposalError!, onRetry: _retryProposal),
        ],
        if (_proposal != null) ...[
          SizedBox(height: 2.h),
          AiScheduleSuggestionCard(
            suggestion: _proposal!,
            onConfirm: _confirmProposal,
            onTryAgain: _retryProposal,
            onCancel: _cancelProposal,
          ),
        ],
      ],
    );
  }

  Widget _buildWateringSchedule() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'water_drop',
                  color: Theme.of(context).colorScheme.onPrimary,
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
                            color: Theme.of(context).colorScheme.onSurface,
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.2),
              inactiveTrackColor: Theme.of(context).colorScheme.primary
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                'Monthly',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
                      ? Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
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
                            color: Theme.of(context).colorScheme.onSurface,
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
                    color: Theme.of(context).colorScheme.onSurface,
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
