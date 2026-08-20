import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProcessingScreenWidget extends StatefulWidget {
  final String imagePath;

  const ProcessingScreenWidget({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ProcessingScreenWidget> createState() => _ProcessingScreenWidgetState();
}

class _ProcessingScreenWidgetState extends State<ProcessingScreenWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            // Captured Image
            Container(
              width: 80.w,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'image',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          size: 12.w,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 6.h),
            // Loading Animation
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.tertiary
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 4.h),
            // Processing Text
            Text(
              'Analyzing plant...',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'This may take a few moments',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
