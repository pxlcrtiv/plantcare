import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/plant.dart';
import '../../../services/plant_ai_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/ai_error_card.dart';
import '../../../widgets/ai_reminder_text_card.dart';
import '../../../widgets/ai_schedule_suggestion_card.dart';
import '../../../widgets/custom_icon_widget.dart';

class ReminderSettingsSheet extends StatefulWidget {
  const ReminderSettingsSheet({
    super.key,
    required this.plant,
    required this.aiService,
    required this.onCareScheduleUpdated,
    required this.onScheduleCareReminders,
    required this.onCancelPlantReminders,
    required this.onReminderTimeTap,
  });

  final Plant plant;
  final PlantAiService aiService;

  /// Persists dot-notation careSchedule updates (e.g. 'careSchedule.wateringFrequency')
  /// and refreshes local plant state. Throws on failure.
  final Future<void> Function(String plantId, Map<String, dynamic> updates)
      onCareScheduleUpdated;

  final Future<void> Function(Plant plant) onScheduleCareReminders;
  final Future<void> Function(String plantId) onCancelPlantReminders;
  final VoidCallback onReminderTimeTap;

  @override
  State<ReminderSettingsSheet> createState() => _ReminderSettingsSheetState();
}

class _ReminderSettingsSheetState extends State<ReminderSettingsSheet> {
  bool _careRemindersEnabled = true;

  ScheduleSuggestion? _scheduleProposal;
  PlantAiException? _scheduleProposalError;
  bool _isProposingSchedule = false;

  String? _reminderTextProposal;
  PlantAiException? _reminderTextError;
  bool _isGeneratingReminderText = false;
  String? _appliedReminderText;

  String? get _reminderTime {
    final saved = widget.plant.careSchedule['reminderTime'];
    return saved is String && saved.trim().isNotEmpty ? saved : null;
  }

  String get _currentReminderText {
    final applied = _appliedReminderText;
    if (applied != null && applied.trim().isNotEmpty) {
      return applied;
    }
    final stored = widget.plant.careSchedule['reminderText'];
    if (stored is String && stored.trim().isNotEmpty) {
      return stored;
    }
    return 'Time to water ${widget.plant.name}!';
  }

  String _formatReminderTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = parts[1].padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:$minute $period';
  }

  Future<void> _proposeScheduleForPlant() async {
    final plant = widget.plant;
    setState(() {
      _isProposingSchedule = true;
      _scheduleProposalError = null;
    });
    try {
      final suggestion = await widget.aiService.suggestWateringSchedule(
        ScheduleRequest(
          species: plant.species,
          light: plant.light,
          humidity: plant.humidity,
          location: plant.location,
          careSchedule: plant.careSchedule,
        ),
      );
      if (!mounted) return;
      setState(() {
        _scheduleProposal = suggestion;
        _isProposingSchedule = false;
      });
    } on PlantAiException catch (error) {
      if (!mounted) return;
      setState(() {
        _scheduleProposalError = error;
        _isProposingSchedule = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _scheduleProposalError = const UnknownError();
        _isProposingSchedule = false;
      });
    }
  }

  Future<void> _confirmScheduleProposal() async {
    final proposal = _scheduleProposal;
    if (proposal == null) return;
    try {
      await widget.onCareScheduleUpdated(widget.plant.id, {
        'careSchedule.wateringFrequency': proposal.wateringFrequency,
        'careSchedule.fertilizingEnabled': proposal.fertilizingEnabled,
        'careSchedule.fertilizingFrequency': proposal.fertilizingFrequency,
        'careSchedule.mistingEnabled': proposal.mistingEnabled,
        'careSchedule.mistingFrequency': proposal.mistingFrequency,
        'careSchedule.rotatingEnabled': proposal.rotatingEnabled,
        'careSchedule.rotatingFrequency': proposal.rotatingFrequency,
      });
      if (!mounted) return;
      setState(() {
        _scheduleProposal = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('AI schedule applied'),
          backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply AI schedule: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _retryScheduleProposal() {
    setState(() {
      _scheduleProposal = null;
      _scheduleProposalError = null;
    });
    _proposeScheduleForPlant();
  }

  void _cancelScheduleProposal() {
    setState(() {
      _scheduleProposal = null;
    });
  }

  Future<void> _generateReminderText() async {
    final plant = widget.plant;
    setState(() {
      _isGeneratingReminderText = true;
      _reminderTextError = null;
    });
    try {
      final text = await widget.aiService.reminderTextFor(
        ReminderTextRequest(careSchedule: plant.careSchedule),
      );
      if (!mounted) return;
      setState(() {
        _reminderTextProposal = text;
        _isGeneratingReminderText = false;
      });
    } on PlantAiException catch (error) {
      if (!mounted) return;
      setState(() {
        _reminderTextError = error;
        _isGeneratingReminderText = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reminderTextError = const UnknownError();
        _isGeneratingReminderText = false;
      });
    }
  }

  Future<void> _confirmReminderText() async {
    final text = _reminderTextProposal;
    if (text == null) return;
    try {
      await widget.onCareScheduleUpdated(widget.plant.id, {
        'careSchedule.reminderText': text,
      });
      if (!mounted) return;
      setState(() {
        _reminderTextProposal = null;
        _appliedReminderText = text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reminder message updated'),
          backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update reminder message: ${e.toString()}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _retryReminderText() {
    setState(() {
      _reminderTextProposal = null;
      _reminderTextError = null;
    });
    _generateReminderText();
  }

  void _cancelReminderText() {
    setState(() {
      _reminderTextProposal = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              Text(
                'Care Reminders',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 2.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enable Reminders',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Switch(
                    value: _careRemindersEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _careRemindersEnabled = value;
                      });

                      if (value) {
                        await widget.onScheduleCareReminders(widget.plant);
                      } else {
                        await widget.onCancelPlantReminders(widget.plant.id);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              if (_careRemindersEnabled) ...[
                Text(
                  'Reminder Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: CustomIconWidget(
                      iconName: 'schedule',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    title:
                        Text(_formatReminderTime(_reminderTime ?? '09:00')),
                    subtitle: Text(
                      _reminderTime != null
                          ? 'Daily reminder at $_reminderTime'
                          : 'Daily reminder time',
                    ),
                    trailing: CustomIconWidget(
                      iconName: 'edit',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onTap: widget.onReminderTimeTap,
                  ),
                ),
              ],

              SizedBox(height: 2.h),

              Text(
                'AI Schedule',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isProposingSchedule
                      ? null
                      : _proposeScheduleForPlant,
                  icon: _isProposingSchedule
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Icon(Icons.auto_awesome, size: 5.w),
                  label: Text(
                    _isProposingSchedule ? 'Proposing…' : 'Regenerate schedule',
                  ),
                ),
              ),
              if (_scheduleProposalError != null) ...[
                SizedBox(height: 2.h),
                AiErrorCard(
                  error: _scheduleProposalError!,
                  onRetry: _retryScheduleProposal,
                ),
              ],
              if (_scheduleProposal != null) ...[
                SizedBox(height: 2.h),
                AiScheduleSuggestionCard(
                  suggestion: _scheduleProposal!,
                  onConfirm: _confirmScheduleProposal,
                  onTryAgain: _retryScheduleProposal,
                  onCancel: _cancelScheduleProposal,
                ),
              ],

              SizedBox(height: 2.h),

              Text(
                'Reminder Message',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  _currentReminderText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 1.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isGeneratingReminderText
                      ? null
                      : _generateReminderText,
                  icon: _isGeneratingReminderText
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Icon(Icons.smart_toy_outlined, size: 5.w),
                  label: Text(
                    _isGeneratingReminderText
                        ? 'Generating…'
                        : 'Write smart reminder text',
                  ),
                ),
              ),
              if (_reminderTextError != null) ...[
                SizedBox(height: 2.h),
                AiErrorCard(
                  error: _reminderTextError!,
                  onRetry: _retryReminderText,
                ),
              ],
              if (_reminderTextProposal != null) ...[
                SizedBox(height: 2.h),
                AiReminderTextCard(
                  text: _reminderTextProposal!,
                  onConfirm: _confirmReminderText,
                  onTryAgain: _retryReminderText,
                  onCancel: _cancelReminderText,
                ),
              ],
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
