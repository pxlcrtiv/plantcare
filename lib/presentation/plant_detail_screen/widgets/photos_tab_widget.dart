import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/app_export.dart';

class PhotosTabWidget extends StatefulWidget {
  final List<Map<String, dynamic>> photos;
  final VoidCallback onAddPhoto;

  const PhotosTabWidget({
    Key? key,
    required this.photos,
    required this.onAddPhoto,
  }) : super(key: key);

  @override
  State<PhotosTabWidget> createState() => _PhotosTabWidgetState();
}

class _PhotosTabWidgetState extends State<PhotosTabWidget> {

  void _showPhotoViewer(int index) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CustomImageWidget(
                  imageUrl: widget.photos[index]['url'] as String? ?? '',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 4.h,
              right: 4.w,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            Positioned(
              bottom: 4.h,
              left: 4.w,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle date properly - could be Timestamp from Firestore or DateTime
                    if (widget.photos[index]['date'] != null) 
                      Text(
                        'Taken on ${_formatDate(widget.photos[index]['date'])}',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    if (widget.photos[index]['caption'] != null && widget.photos[index]['caption'] != '') 
                      Text(
                        widget.photos[index]['caption'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
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
  
  String _formatDate(dynamic dateValue) {
    if (dateValue is Timestamp) {
      final date = dateValue.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } else if (dateValue is String) {
      final date = DateTime.parse(dateValue);
      return '${date.day}/${date.month}/${date.year}';
    } else if (dateValue is DateTime) {
      return '${dateValue.day}/${dateValue.month}/${dateValue.year}';
    } else {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with add photo button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Growth Gallery',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: widget.onAddPhoto,
                icon: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: Colors.white,
                  size: 16,
                ),
                label: Text('Add Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Photo count
          Text(
            '${widget.photos.length} photos',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 1.h),

          // Photo grid
          widget.photos.isEmpty
              ? Container(
                  height: 30.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'photo_library',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No photos yet',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Start documenting your plant\'s growth journey',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: widget.onAddPhoto,
                        child: Text('Take First Photo'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.w,
                    mainAxisSpacing: 2.w,
                    childAspectRatio: 1,
                  ),
                  itemCount: widget.photos.length,
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    
                    // Handle date properly - could be Timestamp from Firestore or DateTime
                    String dateString = _formatDate(photo['date']);
                    final url = photo['url'] as String? ?? '';
                    final caption = photo['caption'] as String? ?? '';

                    return GestureDetector(
                      onTap: () => _showPhotoViewer(index),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: url.isNotEmpty 
                                ? CustomImageWidget(
                                    imageUrl: url,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[600],
                                      size: 40,
                                    ),
                                  ),
                            ),

                            // Date stamp
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      dateString,
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (caption.isNotEmpty) ...[
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        caption,
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.white70,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
