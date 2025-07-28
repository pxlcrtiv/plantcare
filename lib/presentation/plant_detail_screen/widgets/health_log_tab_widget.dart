import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class HealthLogTabWidget extends StatelessWidget {
  final List<Map<String, dynamic>> healthLogs;

  const HealthLogTabWidget({
    Key? key,
    required this.healthLogs,
  }) : super(key: key);

  Color _getLogTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'growth':
        return AppTheme.getSuccessColor(true);
      case 'issue':
        return AppTheme.lightTheme.colorScheme.error;
      case 'care':
        return Colors.blue;
      case 'milestone':
        return AppTheme.getAccentColor(true);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  IconData _getLogTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'growth':
        return Icons.trending_up;
      case 'issue':
        return Icons.warning;
      case 'care':
        return Icons.favorite;
      case 'milestone':
        return Icons.star;
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
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Add new log entry
                },
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.lightTheme.colorScheme.primary,
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
              final date = log['date'] as DateTime;
              final type = log['type'] as String;
              final title = log['title'] as String;
              final description = log['description'] as String;
              final hasPhoto = log['hasPhoto'] as bool? ?? false;
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
                            color:
                                _getLogTypeColor(type).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getLogTypeColor(type),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getLogTypeIcon(type),
                            color: _getLogTypeColor(type),
                            size: 20,
                          ),
                        ),
                        if (index < healthLogs.length - 1)
                          Container(
                            width: 2,
                            height: 4.h,
                            color: AppTheme.lightTheme.colorScheme.outline
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
                                    color: _getLogTypeColor(type)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    type.toUpperCase(),
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: _getLogTypeColor(type),
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
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 0.5.h),

                            // Description
                            Text(
                              description,
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),

                            // Photo attachment if available
                            if (hasPhoto && photoUrl != null) ...[
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
