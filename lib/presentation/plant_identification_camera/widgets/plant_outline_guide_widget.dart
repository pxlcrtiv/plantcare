import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PlantOutlineGuideWidget extends StatelessWidget {
  const PlantOutlineGuideWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 70.w,
        height: 50.h,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.8),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: -1,
              left: -1,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      width: 4,
                    ),
                    left: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      width: 4,
                    ),
                    right: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              left: -1,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      width: 4,
                    ),
                    left: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      width: 4,
                    ),
                    right: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      width: 4,
                    ),
                  ),
                ),
              ),
            ),
            // Center focus indicator
            Center(
              child: Container(
                width: 4.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
