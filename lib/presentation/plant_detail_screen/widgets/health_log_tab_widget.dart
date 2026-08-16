import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/app_export.dart';

class HealthLogTabWidget extends StatelessWidget {
  final List<Map<String, dynamic>> healthLogs;

  /// Called when a new health log entry is saved from the Add Log dialog.
  /// Receives the selected [type], the optional [notes] and the log [date].
  final Future<void> Function(String type, String notes, DateTime date)
      onAddLog;

  const HealthLogTabWidget({
    Key? key,
    required this.healthLogs,
    required this.onAddLog,
  }) : super(key: key);

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
          onAddLog(type, notes, date);
        },
      ),
    );
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

          SizedBox(height: 2.h),

          // Timeline
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: healthLogs.length,
            itemBuilder: (context, index) {
              final log = healthLogs[index];
              
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
                        if (index < healthLogs.length - 1)
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