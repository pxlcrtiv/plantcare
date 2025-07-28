import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NotesTabWidget extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  final Function(String) onAddNote;

  const NotesTabWidget({
    Key? key,
    required this.notes,
    required this.onAddNote,
  }) : super(key: key);

  @override
  State<NotesTabWidget> createState() => _NotesTabWidgetState();
}

class _NotesTabWidgetState extends State<NotesTabWidget> {
  final TextEditingController _noteController = TextEditingController();
  bool _isAddingNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addNote() {
    if (_noteController.text.trim().isNotEmpty) {
      widget.onAddNote(_noteController.text.trim());
      _noteController.clear();
      setState(() {
        _isAddingNote = false;
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
              Text(
                'Care Notes',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isAddingNote = !_isAddingNote;
                  });
                },
                icon: CustomIconWidget(
                  iconName: _isAddingNote ? 'close' : 'add',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 16,
                ),
                label: Text(_isAddingNote ? 'Cancel' : 'Add Note'),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Add note section
          if (_isAddingNote) ...[
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Note',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _noteController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Write your observations, care tips, or reminders...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(3.w),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _noteController.clear();
                            setState(() {
                              _isAddingNote = false;
                            });
                          },
                          child: Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addNote,
                          child: Text('Save Note'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Notes list
          widget.notes.isEmpty
              ? Container(
                  height: 30.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'note',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No notes yet',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Start documenting your plant care journey',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isAddingNote = true;
                          });
                        },
                        child: Text('Add First Note'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.notes.length,
                  itemBuilder: (context, index) {
                    final note = widget.notes[index];
                    final date = note['date'] as DateTime;
                    final content = note['content'] as String;
                    final isImportant = note['isImportant'] as bool? ?? false;

                    return Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: isImportant
                            ? AppTheme.getWarningColor(true)
                                .withValues(alpha: 0.05)
                            : AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isImportant
                              ? AppTheme.getWarningColor(true)
                                  .withValues(alpha: 0.3)
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with date and importance indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (isImportant) ...[
                                    CustomIconWidget(
                                      iconName: 'star',
                                      color: AppTheme.getWarningColor(true),
                                      size: 16,
                                    ),
                                    SizedBox(width: 1.w),
                                  ],
                                  Text(
                                    '${date.day}/${date.month}/${date.year}',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelMedium
                                        ?.copyWith(
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  // Handle note actions (edit, delete, mark important)
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'edit',
                                          color: AppTheme
                                              .lightTheme.colorScheme.onSurface,
                                          size: 16,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'important',
                                    child: Row(
                                      children: [
                                        CustomIconWidget(
                                          iconName: isImportant
                                              ? 'star_border'
                                              : 'star',
                                          color: AppTheme.getWarningColor(true),
                                          size: 16,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(isImportant
                                            ? 'Unmark Important'
                                            : 'Mark Important'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'delete',
                                          color: AppTheme
                                              .lightTheme.colorScheme.error,
                                          size: 16,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                                child: CustomIconWidget(
                                  iconName: 'more_vert',
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 1.h),

                          // Note content
                          Text(
                            content,
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
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
