import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './plant_result_card_widget.dart';

class IdentificationResultsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final VoidCallback onRetryPhoto;
  final VoidCallback onManualSearch;
  final Function(Map<String, dynamic>) onSelectPlant;

  const IdentificationResultsWidget({
    Key? key,
    required this.results,
    required this.onRetryPhoto,
    required this.onManualSearch,
    required this.onSelectPlant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      'Plant Identification Results',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Results List
            Expanded(
              child: results.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return PlantResultCardWidget(
                          plantData: results[index],
                          onSelectPlant: () => onSelectPlant(results[index]),
                        );
                      },
                    ),
            ),
            // Bottom Actions
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Not quite right link
                  GestureDetector(
                    onTap: onManualSearch,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Text(
                        'Not quite right? Try manual search',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  // Retry Photo Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onRetryPhoto,
                      icon: CustomIconWidget(
                        iconName: 'camera_alt',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 5.w,
                      ),
                      label: Text(
                        'Take Another Photo',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          fontSize: 14.sp,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
              size: 20.w,
            ),
            SizedBox(height: 4.h),
            Text(
              'No plants identified',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Try taking another photo with better lighting or focus on the plant\'s leaves and overall shape.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
