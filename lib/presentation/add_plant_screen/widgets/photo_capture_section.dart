import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PhotoCaptureSection extends StatefulWidget {
  final Function(List<XFile>) onPhotosChanged;

  const PhotoCaptureSection({
    super.key,
    required this.onPhotosChanged,
  });

  @override
  State<PhotoCaptureSection> createState() => _PhotoCaptureSectionState();
}

class _PhotoCaptureSectionState extends State<PhotoCaptureSection> {
  List<XFile> _capturedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _showCameraPreview = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (await _requestCameraPermission()) {
        _cameras = await availableCameras();
        if (_cameras.isNotEmpty) {
          final camera = kIsWeb
              ? _cameras.firstWhere(
                  (c) => c.lensDirection == CameraLensDirection.front,
                  orElse: () => _cameras.first)
              : _cameras.firstWhere(
                  (c) => c.lensDirection == CameraLensDirection.back,
                  orElse: () => _cameras.first);

          _cameraController = CameraController(
              camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

          await _cameraController!.initialize();
          await _applySettings();

          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });
          }
        }
      }
    } catch (e) {
      // Silent fail - camera not available
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {}

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {}
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImages.add(photo);
        _showCameraPreview = false;
      });
      widget.onPhotosChanged(_capturedImages);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImages.add(image);
        });
        widget.onPhotosChanged(_capturedImages);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _removeImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
    widget.onPhotosChanged(_capturedImages);
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final XFile item = _capturedImages.removeAt(oldIndex);
      _capturedImages.insert(newIndex, item);
    });
    widget.onPhotosChanged(_capturedImages);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plant Photos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add photos to help identify and track your plant\'s growth',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 2.h),

          // Camera Preview
          _showCameraPreview && _isCameraInitialized
              ? _buildCameraPreview()
              : _buildPhotoActions(),

          SizedBox(height: 2.h),

          // Photo Thumbnails
          if (_capturedImages.isNotEmpty) _buildPhotoThumbnails(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      height: 40.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CameraPreview(_cameraController!),
            Positioned(
              bottom: 4.w,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showCameraPreview = false;
                      });
                    },
                    icon: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _capturePhoto,
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _pickFromGallery,
                    icon: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'photo_library',
                        color: Colors.white,
                        size: 6.w,
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

  Widget _buildPhotoActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isCameraInitialized
                ? () {
                    setState(() {
                      _showCameraPreview = true;
                    });
                  }
                : null,
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
            label: Text('Take Photo'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: CustomIconWidget(
              iconName: 'photo_library',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
            label: Text('Gallery'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (${_capturedImages.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 1.h),
        Container(
          height: 20.h,
          child: ReorderableListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _capturedImages.length,
            onReorder: _reorderImages,
            itemBuilder: (context, index) {
              return Container(
                key: ValueKey(_capturedImages[index].path),
                margin: EdgeInsets.only(right: 2.w),
                child: Stack(
                  children: [
                    Container(
                      width: 30.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.lightTheme.colorScheme.surface,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Image.network(
                                _capturedImages[index].path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color:
                                        AppTheme.lightTheme.colorScheme.surface,
                                    child: Center(
                                      child: CustomIconWidget(
                                        iconName: 'image',
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                        size: 8.w,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : CustomImageWidget(
                                imageUrl: _capturedImages[index].path,
                                width: 30.w,
                                height: 20.h,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 1.w,
                      right: 1.w,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: Colors.white,
                            size: 4.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
