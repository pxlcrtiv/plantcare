import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddPlant;

  const EmptyStateWidget({
    Key? key,
    required this.onAddPlant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color:
                    AppTheme.getSuccessColor(isDarkMode).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'local_florist',
                  color: AppTheme.getSuccessColor(isDarkMode),
                  size: 20.w,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            // Title
            Text(
              'Start Your Plant Journey',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            // Description
            Text(
              'Add your first plant to begin tracking its care schedule and watch it thrive with personalized reminders.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAddPlant,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 5.w,
                ),
                label: Text(
                  'Add Your First Plant',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            // Secondary Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/plant-identification-camera');
                  },
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: Theme.of(context).colorScheme.primary,
                    size: 4.w,
                  ),
                  label: Text('Identify Plant'),
                ),
                TextButton.icon(
                  onPressed: onAddPlant,
                  icon: CustomIconWidget(
                    iconName: 'search',
                    color: Theme.of(context).colorScheme.primary,
                    size: 4.w,
                  ),
                  label: Text('Browse Database'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
