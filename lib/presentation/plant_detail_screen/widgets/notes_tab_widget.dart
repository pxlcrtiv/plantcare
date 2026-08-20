import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/app_export.dart';

class NotesTabWidget extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  final Function(String) onAddNote;
  final void Function(int index, String newContent) onEditNote;
  final void Function(int index) onToggleImportant;
  final void Function(int index) onDeleteNote;

  const NotesTabWidget({
    Key? key,
    required this.notes,
    required this.onAddNote,
    required this.onEditNote,
    required this.onToggleImportant,
    required this.onDeleteNote,
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

  Future<void> _showEditNoteDialog(int index, String initialContent) async {
    final controller = TextEditingController(text: initialContent);
    final newContent = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          'Edit Note',
          style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newContent != null && newContent.isNotEmpty) {
      widget.onEditNote(index, newContent);
    }
  }

  Future<void> _showDeleteNoteDialog(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(
          'Delete Note',
          style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(dialogContext).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onDeleteNote(index);
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                  color: Theme.of(context).colorScheme.primary,
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
                  Text(
                    'New Note',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'note',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No notes yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Start documenting your plant care journey',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
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
                    
                    // Handle date properly - could be Timestamp from Firestore or DateTime
                    DateTime date;
                    if (note['date'] is Timestamp) {
                      date = (note['date'] as Timestamp).toDate();
                    } else if (note['date'] is String) {
                      date = DateTime.parse(note['date'] as String);
                    } else if (note['date'] is DateTime) {
                      date = note['date'] as DateTime;
                    } else {
                      date = DateTime.now(); // fallback
                    }
                    
                    final content = note['content'] as String? ?? note['description'] as String? ?? '';
                    final isImportant = note['isImportant'] as bool? ?? false;

                    return Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: isImportant
                            ? AppTheme.getWarningColor(Theme.of(context).brightness == Brightness.dark)
                                .withValues(alpha: 0.05)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isImportant
                              ? AppTheme.getWarningColor(Theme.of(context).brightness == Brightness.dark)
                                  .withValues(alpha: 0.3)
                              : Theme.of(context).colorScheme.outline
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
                                      color: AppTheme.getWarningColor(Theme.of(context).brightness == Brightness.dark),
                                      size: 16,
                                    ),
                                    SizedBox(width: 1.w),
                                  ],
                                  Text(
                                    '${date.day}/${date.month}/${date.year}',
                                    style: Theme.of(context).textTheme.labelMedium
                                        ?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _showEditNoteDialog(index, content);
                                      break;
                                    case 'important':
                                      widget.onToggleImportant(index);
                                      break;
                                    case 'delete':
                                      _showDeleteNoteDialog(index);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'edit',
                                          color: Theme.of(context).colorScheme.onSurface,
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
                                          color: AppTheme.getWarningColor(Theme.of(context).brightness == Brightness.dark),
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
                                          color: Theme.of(context).colorScheme.error,
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
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 1.h),

                          // Note content
                          Text(
                            content,
                            style: Theme.of(context).textTheme.bodyMedium,
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
