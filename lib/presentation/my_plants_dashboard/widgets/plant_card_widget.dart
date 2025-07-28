import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlantCardWidget extends StatelessWidget {
  final Map<String, dynamic> plant;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onWaterTap;

  const PlantCardWidget({
    Key? key,
    required this.plant,
    required this.onTap,
    required this.onLongPress,
    required this.onWaterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String status = plant['status'] as String? ?? 'healthy';

    Color statusColor;
    switch (status) {
      case 'needs_attention':
        statusColor = AppTheme.getWarningColor(isDarkMode);
        break;
      case 'overdue':
        statusColor = AppTheme.lightTheme.colorScheme.error;
        break;
      default:
        statusColor = AppTheme.getSuccessColor(isDarkMode);
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? AppTheme.shadowDark : AppTheme.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: CustomImageWidget(
                      imageUrl: plant['image'] as String? ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Status Indicator
                  Positioned(
                    top: 2.w,
                    right: 2.w,
                    child: Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Water Button (appears on long press)
                  Positioned(
                    bottom: 2.w,
                    right: 2.w,
                    child: GestureDetector(
                      onTap: onWaterTap,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: 'water_drop',
                          color: Colors.white,
                          size: 4.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Plant Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant['name'] as String? ?? 'Unknown Plant',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          plant['species'] as String? ?? 'Unknown Species',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Last Watered
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            plant['lastWatered'] as String? ?? 'Never',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
