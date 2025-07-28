import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GreetingHeaderWidget extends StatelessWidget {
  final String userName;
  final String currentDate;
  final String weatherInfo;
  final int plantsNeedingCare;

  const GreetingHeaderWidget({
    Key? key,
    required this.userName,
    required this.currentDate,
    required this.weatherInfo,
    required this.plantsNeedingCare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'wb_sunny',
                        color: AppTheme.getWarningColor(isDarkMode),
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        weatherInfo,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Care Summary
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: plantsNeedingCare > 0
                  ? AppTheme.getWarningColor(isDarkMode).withValues(alpha: 0.1)
                  : AppTheme.getSuccessColor(isDarkMode).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: plantsNeedingCare > 0
                    ? AppTheme.getWarningColor(isDarkMode)
                        .withValues(alpha: 0.3)
                    : AppTheme.getSuccessColor(isDarkMode)
                        .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: plantsNeedingCare > 0 ? 'warning' : 'check_circle',
                  color: plantsNeedingCare > 0
                      ? AppTheme.getWarningColor(isDarkMode)
                      : AppTheme.getSuccessColor(isDarkMode),
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plantsNeedingCare > 0
                            ? 'Plants Need Attention'
                            : 'All Plants Healthy',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: plantsNeedingCare > 0
                                  ? AppTheme.getWarningColor(isDarkMode)
                                  : AppTheme.getSuccessColor(isDarkMode),
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        plantsNeedingCare > 0
                            ? '$plantsNeedingCare ${plantsNeedingCare == 1 ? 'plant needs' : 'plants need'} watering today'
                            : 'Your plants are thriving! Keep up the great care.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
