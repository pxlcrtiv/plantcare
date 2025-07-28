import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraControlsWidget extends StatelessWidget {
  final VoidCallback onCapturePressed;
  final VoidCallback onGalleryPressed;
  final VoidCallback onFlashToggle;
  final bool isFlashOn;
  final bool isWeb;

  const CameraControlsWidget({
    Key? key,
    required this.onCapturePressed,
    required this.onGalleryPressed,
    required this.onFlashToggle,
    required this.isFlashOn,
    required this.isWeb,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gallery Button
              GestureDetector(
                onTap: onGalleryPressed,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'photo_library',
                    color: Colors.white,
                    size: 6.w,
                  ),
                ),
              ),

              // Capture Button
              GestureDetector(
                onTap: onCapturePressed,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
              ),

              // Flash Toggle Button (Hidden on Web)
              isWeb
                  ? SizedBox(width: 12.w)
                  : GestureDetector(
                      onTap: onFlashToggle,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: isFlashOn
                              ? AppTheme.lightTheme.colorScheme.tertiary
                                  .withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFlashOn
                                ? AppTheme.lightTheme.colorScheme.tertiary
                                : Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: CustomIconWidget(
                          iconName: isFlashOn ? 'flash_on' : 'flash_off',
                          color: isFlashOn
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : Colors.white,
                          size: 6.w,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
