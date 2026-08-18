import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/app_export.dart';
import '../../../../models/plant.dart';
import '../../../../providers/plant_ai_service_provider.dart';
import '../../../../services/plant_ai_service.dart';

enum _SummaryPhase { idle, loading, success, error }

class HealthLogTabWidget extends StatefulWidget {
  final Plant plant;
  final List<Map<String, dynamic>> healthLogs;

  /// Called when a new health log entry is saved from the Add Log dialog.
  /// Receives the selected [type], the optional [notes] and the log [date].
  final Future<void> Function(String type, String notes, DateTime date)
      onAddLog;

  const HealthLogTabWidget({
    Key? key,
    required this.plant,
    required this.healthLogs,
    required this.onAddLog,
  }) : super(key: key);

  @override
  State<HealthLogTabWidget> createState() => _HealthLogTabWidgetState();
}

class _HealthLogTabWidgetState extends State<HealthLogTabWidget> {
  PlantAiService _service = const StubPlantAiService();
  _SummaryPhase _phase = _SummaryPhase.idle;
  HealthLogSummary? _summary;
  PlantAiException? _summaryError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = PlantAiServiceProvider.of(context);
    if (!identical(service, _service)) {
      _service = service;
    }
  }

  Color _getLogTypeColor(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'growth':
        return AppTheme.getSuccessColor(Theme.of(context).brightness == Brightness.dark);
      case 'issue':
        return Theme.of(context).colorScheme.error;
      case 'care':
        return Colors.blue;
      case 'milestone':
        return AppTheme.getAccentColor(Theme.of(context).brightness == Brightness.dark);
      case 'note':
        return Colors.grey; // For personal notes
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getLogTypeIcon(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'growth':
        return Icons.trending_up;
      case 'issue':
        return Icons.warning;
      case 'care':
        return Icons.favorite;
      case 'milestone':
        return Icons.star;
      case 'note':
        return Icons.note_alt;
      default:
        return Icons.note;
    }
  }

  void _showAddLogDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _AddLogDialog(
        onSave: (type, notes, date) {
          widget.onAddLog(type, notes, date);
        },
      ),
    );
  }

  Future<void> _summarize() async {
    final service = _service;
    setState(() {
      _phase = _SummaryPhase.loading;
      _summary = null;
      _summaryError = null;
    });
    final request = SummaryRequest(
      plantName: widget.plant.name,
      species: widget.plant.species,
      humidity: widget.plant.humidity,
      light: widget.plant.light,
      location: widget.plant.location,
      careNotes: widget.plant.careNotes,
      careSchedule: widget.plant.careSchedule,
      healthLogs: widget.healthLogs.map(HealthLogEntry.fromMap).toList(),
    );
    try {
      final summary = await service.summarizeHealthLogs(request);
      if (!mounted) return;
      setState(() {
        _phase = _SummaryPhase.success;
        _summary = summary;
      });
    } on PlantAiException catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _SummaryPhase.error;
        _summaryError = error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _SummaryPhase.error;
        _summaryError = const UnknownError('Summarizing failed.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Health Timeline',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddLogDialog(context),
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                label: Text('Add Log'),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          _SummarySection(
            phase: _phase,
            summary: _summary,
            error: _summaryError,
            onSummarize: _summarize,
          ),

          SizedBox(height: 2.h),

          // Timeline
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.healthLogs.length,
            itemBuilder: (context, index) {
              final log = widget.healthLogs[index];
              
              // Handle date properly - could be Timestamp from Firestore or DateTime
              DateTime date;
              if (log['date'] is Timestamp) {
                date = (log['date'] as Timestamp).toDate();
              } else if (log['date'] is String) {
                date = DateTime.parse(log['date'] as String);
              } else if (log['date'] is DateTime) {
                date = log['date'] as DateTime;
              } else {
                date = DateTime.now(); // fallback
              }
              
              final type = log['type'] as String? ?? 'note';
              final title = log['title'] as String? ?? type.toUpperCase();
              final description = log['description'] as String? ?? log['content'] as String? ?? '';
              final photoUrl = log['photoUrl'] as String?;

              return Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getLogTypeColor(context, type).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getLogTypeColor(context, type),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getLogTypeIcon(context, type),
                            color: _getLogTypeColor(context, type),
                            size: 20,
                          ),
                        ),
                        if (index < widget.healthLogs.length - 1)
                          Container(
                            width: 2,
                            height: 4.h,
                            color: Theme.of(context).colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                      ],
                    ),

                    SizedBox(width: 4.w),

                    // Content
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with date and type
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getLogTypeColor(context, type)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    type.toUpperCase(),
                                    style: Theme.of(context).textTheme.labelSmall
                                        ?.copyWith(
                                      color: _getLogTypeColor(context, type),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 1.h),

                            // Title
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 0.5.h),

                            // Description
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),

                            // Photo attachment if available
                            if (photoUrl != null) ...[
                              SizedBox(height: 1.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CustomImageWidget(
                                  imageUrl: photoUrl,
                                  width: double.infinity,
                                  height: 20.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.phase,
    required this.summary,
    required this.error,
    required this.onSummarize,
  });

  final _SummaryPhase phase;
  final HealthLogSummary? summary;
  final PlantAiException? error;
  final VoidCallback onSummarize;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case _SummaryPhase.loading:
        return const _SummaryLoadingCard();
      case _SummaryPhase.success:
        return _SummaryResultCard(
          summary: summary!,
          onRegenerate: onSummarize,
        );
      case _SummaryPhase.error:
        return _SummaryErrorCard(error: error!, onRetry: onSummarize);
      case _SummaryPhase.idle:
        return _SummaryIdleCard(onSummarize: onSummarize);
    }
  }
}

class _SummaryIdleCard extends StatelessWidget {
  const _SummaryIdleCard({required this.onSummarize});

  final VoidCallback onSummarize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 5.w, color: colorScheme.primary),
              SizedBox(width: 2.5.w),
              Expanded(
                child: Text(
                  'Health summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Turn your care log history into a readable story.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSummarize,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Summarize'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLoadingCard extends StatelessWidget {
  const _SummaryLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 5.w,
            height: 5.w,
            child: const CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              "Writing your plant's health story…",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryResultCard extends StatelessWidget {
  const _SummaryResultCard({
    required this.summary,
    required this.onRegenerate,
  });

  final HealthLogSummary summary;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Health summary',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: onRegenerate,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Regenerate'),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            summary.overallHealth,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (summary.notableChanges.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            _SummaryList(
              title: 'Notable changes',
              items: summary.notableChanges,
              icon: Icons.trending_up,
              color: AppTheme.getSuccessColor(
                Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ],
          if (summary.anomalies.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            _SummaryList(
              title: 'Worth attention',
              items: summary.anomalies,
              icon: Icons.warning_amber_rounded,
              color: colorScheme.error,
            ),
          ],
          if (summary.suggestions.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            _SummaryList(
              title: 'Suggestions',
              items: summary.suggestions,
              icon: Icons.lightbulb_outline,
              color: AppTheme.getAccentColor(
                Theme.of(context).brightness == Brightness.dark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryList extends StatelessWidget {
  const _SummaryList({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 4.w, color: color),
            SizedBox(width: 2.w),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(bottom: 0.5.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 0.6.h),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SummaryErrorCard extends StatelessWidget {
  const _SummaryErrorCard({required this.error, required this.onRetry});

  final PlantAiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (title, body) = switch (error) {
      QuotaExceededError() => (
          'The assistant is resting',
          'Try again in a moment.',
        ),
      BlockedError() => (
          'The assistant could not answer',
          'Try rephrasing or summarize again.',
        ),
      TimeoutError() => (
          'The assistant took too long',
          'Try again in a moment.',
        ),
      MalformedOutputError() => (
          'The assistant is resting',
          'Try again in a moment.',
        ),
      OfflineError() => (
          "You're offline",
          'Connect to the internet and try again.',
        ),
      UnknownError() => (
          'Something went wrong',
          'Try again in a moment.',
        ),
    };
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.self_improvement,
                  size: 5.w,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for creating a new health log entry.
///
/// Collects a log type (Watering / Fertilizing / Repotting / Pest check),
/// optional notes, and a date that defaults to today. On save the dialog
/// closes and hands the collected values to [onSave].
class _AddLogDialog extends StatefulWidget {
  final void Function(String type, String notes, DateTime date) onSave;

  const _AddLogDialog({required this.onSave});

  @override
  State<_AddLogDialog> createState() => _AddLogDialogState();
}

class _AddLogDialogState extends State<_AddLogDialog> {
  static const List<String> _logTypes = [
    'watering',
    'fertilizing',
    'repotting',
    'pest check',
  ];

  final TextEditingController _notesController = TextEditingController();
  String _selectedType = _logTypes.first;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save() {
    final notes = _notesController.text.trim();
    Navigator.pop(context);
    widget.onSave(_selectedType, notes, _date);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(
        'Add Health Log',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log type',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: [
                for (final type in _logTypes)
                  ChoiceChip(
                    label: Text(_capitalize(type)),
                    selected: _selectedType == type,
                    onSelected: (_) => setState(() => _selectedType = type),
                    selectedColor: colorScheme.primary.withValues(alpha: 0.15),
                    labelStyle: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(
                      color: _selectedType == type
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: _selectedType == type
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: _selectedType == type
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Notes (optional)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any observations...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.all(3.w),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Date',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${_date.day}/${_date.month}/${_date.year}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text('Save'),
        ),
      ],
    );
  }
}