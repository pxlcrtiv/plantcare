import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/app_export.dart';

class HealthLogTabWidget extends StatelessWidget {
  final List<Map<String, dynamic>> healthLogs;

  const HealthLogTabWidget({
    Key? key,
    required this.healthLogs,
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
                'Health Timeline',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Add new log entry functionality would go here
                },
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
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: _getLogTypeColor(context, type),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
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
