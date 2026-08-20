import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PlantHeroImageWidget extends StatelessWidget {
  final String imageUrl;
  final String plantName;
  final VoidCallback onEditPhoto;
  final VoidCallback onSharePlant;

  const PlantHeroImageWidget({
    Key? key,
    required this.imageUrl,
    required this.plantName,
    required this.onEditPhoto,
    required this.onSharePlant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      width: double.infinity,
      child: Stack(
        children: [
          // Hero Image with parallax effect
          Positioned.fill(
            child: CustomImageWidget(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 35.h,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 6.h,
            left: 4.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Action buttons (Edit Photo, Share Plant)
          Positioned(
            top: 6.h,
            right: 4.w,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: onEditPhoto,
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: onSharePlant,
                    icon: CustomIconWidget(
                      iconName: 'share',
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Plant name at bottom
          Positioned(
            bottom: 2.h,
            left: 4.w,
            right: 4.w,
            child: Text(
              plantName,
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
