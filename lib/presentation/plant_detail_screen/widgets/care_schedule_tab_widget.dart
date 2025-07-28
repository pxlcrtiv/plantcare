import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CareScheduleTabWidget extends StatefulWidget {
  final DateTime nextWateringDate;
  final VoidCallback onWaterNow;
  final List<Map<String, dynamic>> careHistory;

  const CareScheduleTabWidget({
    Key? key,
    required this.nextWateringDate,
    required this.onWaterNow,
    required this.careHistory,
  }) : super(key: key);

  @override
  State<CareScheduleTabWidget> createState() => _CareScheduleTabWidgetState();
}

class _CareScheduleTabWidgetState extends State<CareScheduleTabWidget> {
  String _getCountdownText() {
    final now = DateTime.now();
    final difference = widget.nextWateringDate.difference(now);

    if (difference.isNegative) {
      return 'Overdue by ${difference.abs().inDays} days';
    } else if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else {
      return 'In ${difference.inDays} days';
    }
  }

  Color _getActivityColor(String activity) {
    switch (activity.toLowerCase()) {
      case 'watering':
        return Colors.blue;
      case 'fertilizing':
        return Colors.green;
      case 'pruning':
        return Colors.orange;
      case 'repotting':
        return Colors.brown;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next watering section
          Container(
            width: double.infinity,
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
              children: [
                CustomIconWidget(
                  iconName: 'water_drop',
                  color: Colors.blue,
                  size: 32,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Next Watering',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${widget.nextWateringDate.day}/${widget.nextWateringDate.month}/${widget.nextWateringDate.year}',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getCountdownText(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onWaterNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: Text(
                      'Water Now',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Weekly calendar view
          Text(
            'This Week',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),

          Container(
            height: 12.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().subtract(Duration(days: 3 - index));
                final dayName = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ][date.weekday - 1];
                final hasActivity = widget.careHistory.any((activity) {
                  final activityDate = activity['date'] as DateTime;
                  return activityDate.day == date.day &&
                      activityDate.month == date.month &&
                      activityDate.year == date.year;
                });

                return Container(
                  width: 12.w,
                  margin: EdgeInsets.only(right: 2.w),
                  decoration: BoxDecoration(
                    color: date.day == DateTime.now().day
                        ? AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: date.day == DateTime.now().day
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: AppTheme.lightTheme.textTheme.labelSmall,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${date.day}',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: hasActivity ? Colors.blue : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Recent care history
          Text(
            'Recent Care History',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount:
                widget.careHistory.length > 5 ? 5 : widget.careHistory.length,
            itemBuilder: (context, index) {
              final activity = widget.careHistory[index];
              final date = activity['date'] as DateTime;
              final activityType = activity['type'] as String;
              final notes = activity['notes'] as String? ?? '';

              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getActivityColor(activityType),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activityType,
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (notes.isNotEmpty) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              notes,
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '${date.day}/${date.month}',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
