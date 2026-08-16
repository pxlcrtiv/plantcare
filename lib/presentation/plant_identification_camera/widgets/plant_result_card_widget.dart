import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlantResultCardWidget extends StatelessWidget {
  final Map<String, dynamic> plantData;
  final VoidCallback onSelectPlant;

  const PlantResultCardWidget({
    Key? key,
    required this.plantData,
    required this.onSelectPlant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confidence = (plantData['confidence'] as double) * 100;
    final careDifficulty = plantData['careDifficulty'] as String;

    Color getDifficultyColor() {
      switch (careDifficulty.toLowerCase()) {
        case 'easy':
          return AppTheme.getSuccessColor(Theme.of(context).brightness == Brightness.dark);
        case 'medium':
          return AppTheme.getWarningColor(Theme.of(context).brightness == Brightness.dark);
        case 'hard':
          return Theme.of(context).colorScheme.error;
        default:
          return Theme.of(context).colorScheme.onSurface;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant Image and Basic Info
          Row(
            children: [
              // Plant Image
              Container(
                width: 20.w,
                height: 20.w,
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomImageWidget(
                    imageUrl: plantData['image'] as String,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Plant Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Confidence Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: confidence >= 80
                              ? AppTheme.getSuccessColor(Theme.of(context).brightness == Brightness.dark)
                                  .withValues(alpha: 0.1)
                              : confidence >= 60
                                  ? AppTheme.getWarningColor(Theme.of(context).brightness == Brightness.dark)
                                      .withValues(alpha: 0.1)
                                  : Theme.of(context).colorScheme.error
                                      .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${confidence.toInt()}% match',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                            color: confidence >= 80
                                ? AppTheme.getSuccessColor(Theme.of(context).brightness == Brightness.dark)
                                : confidence >= 60
                                    ? AppTheme.getWarningColor(Theme.of(context).brightness == Brightness.dark)
                                    : Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      // Plant Name
                      Text(
                        plantData['name'] as String,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      // Scientific Name
                      Text(
                        plantData['scientificName'] as String,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Care Difficulty and Basic Info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                // Care Difficulty
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: getDifficultyColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'eco',
                        color: getDifficultyColor(),
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '$careDifficulty Care',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: getDifficultyColor(),
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Basic Care Info
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'water_drop',
                      color: Theme.of(context).colorScheme.primary,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      plantData['wateringFrequency'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Select Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSelectPlant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Select This Plant',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
