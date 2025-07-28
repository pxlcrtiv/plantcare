import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class IdentificationTipsWidget extends StatelessWidget {
  final VoidCallback onDismiss;

  const IdentificationTipsWidget({
    Key? key,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'lightbulb_outline',
            color: AppTheme.lightTheme.colorScheme.tertiary,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Focus on leaves and overall plant shape',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontSize: 13.sp,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              padding: EdgeInsets.all(1.w),
              child: CustomIconWidget(
                iconName: 'close',
                color: Colors.white.withValues(alpha: 0.7),
                size: 4.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
