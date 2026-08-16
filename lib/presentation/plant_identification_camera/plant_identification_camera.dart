
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/plant_identification_result.dart';
import '../../services/plantnet_service.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/identification_results_widget.dart';
import './widgets/identification_tips_widget.dart';
import './widgets/plant_outline_guide_widget.dart';
import './widgets/processing_screen_widget.dart';

class PlantIdentificationCamera extends StatefulWidget {
  const PlantIdentificationCamera({Key? key}) : super(key: key);

  @override
  State<PlantIdentificationCamera> createState() =>
      _PlantIdentificationCameraState();
}

class _PlantIdentificationCameraState extends State<PlantIdentificationCamera>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _showTips = true;
  bool _isProcessing = false;
  bool _showResults = false;
  String? _capturedImagePath;
  final ImagePicker _imagePicker = ImagePicker();
  late PlantNetService _plantNetService;
  final List<Map<String, dynamic>> _mockResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize PlantNet service with API key from env
    _plantNetService = PlantNetService(
      apiKey: _getPlantNetApiKey(), // You'll need to add your API key here
    );
    
    _initializeCamera();
  }

  String _getPlantNetApiKey() {
    return const String.fromEnvironment(
      'PLANTNET_API_KEY',
      defaultValue: '',
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) {
        _showPermissionDialog();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        _showErrorDialog('Camera initialization failed. Please try again.');
      }
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.auto);
      }
    } catch (e) {
      debugPrint('Settings application error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      // Haptic feedback
      HapticFeedback.mediumImpact();

      final XFile photo = await _cameraController!.takePicture();

      setState(() {
        _capturedImagePath = photo.path;
        _isProcessing = true;
      });

      // Call PlantNet API to identify the plant
      await _identifyPlantFromImage(photo.path);

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _showResults = true;
        });
      }
    } catch (e) {
      debugPrint('Photo capture error: $e');
      if (mounted) {
        _showErrorDialog('Failed to capture photo or identify plant. Please try again.');
      }
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _capturedImagePath = image.path;
          _isProcessing = true;
        });

        // Call PlantNet API to identify the plant
        await _identifyPlantFromImage(image.path);

        if (mounted) {
          setState(() {
            _isProcessing = false;
            _showResults = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Gallery selection error: $e');
      if (mounted) {
        _showErrorDialog('Failed to select image from gallery.');
      }
    }
  }

  void _toggleFlash() {
    if (kIsWeb || _cameraController == null) return;

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      _cameraController!
          .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  void _dismissTips() {
    setState(() {
      _showTips = false;
    });
  }

  void _retryPhoto() {
    setState(() {
      _showResults = false;
      _isProcessing = false;
      _capturedImagePath = null;
    });
  }

  void _selectPlant(Map<String, dynamic> plantData) {
    Navigator.pushNamed(
      context,
      '/add-plant-screen',
      arguments: plantData,
    );
  }

  void _manualSearch() {
    Navigator.pushNamed(context, '/add-plant-screen');
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Camera Permission Required',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          'PlantCare needs camera access to identify your plants. This helps us provide accurate care recommendations.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _identifyPlantFromImage(String imagePath) async {
    try {
      final result = await _plantNetService.identifyPlantFromImageFile(imagePath);
      
      // Convert PlantNet API results to the format expected by the UI
      final identificationResults = _convertResultsForUI(result);
      
      // Update the mock results to use the actual API results
      setState(() {
        _mockResults.clear();
        _mockResults.addAll(identificationResults);
      });
    } catch (e) {
      debugPrint('Plant identification error: $e');
      if (mounted) {
        _showErrorDialog(
          'Failed to identify plant: ${e.toString()}. Using fallback method.'
        );
        // Fallback to simple mock results
        setState(() {
          _mockResults
            ..clear()
            ..addAll([
              {
                "id": 1,
                "name": "Unknown Plant",
                "scientificName": "Unknown",
                "confidence": 0.0,
                "careDifficulty": "Easy",
                "wateringFrequency": "Weekly",
                "image": imagePath,
                "description": "Could not identify plant. Please try another image or search manually.",
                "lightRequirement": "Varies",
                "humidity": "Varies",
              }
            ]);
        });
      }
    }
  }

  List<Map<String, dynamic>> _convertResultsForUI(PlantIdentificationResult result) {
    final results = <Map<String, dynamic>>[];
    
    for (final item in result.results) {
      if (item.score != null && item.scientificName != null) {
        results.add({
          "id": results.length + 1,
          "name": _extractCommonName(item) ?? item.scientificName!,
          "scientificName": item.scientificName!,
          "confidence": item.score!,
          "careDifficulty": _estimateCareDifficulty(item),
          "wateringFrequency": _estimateWateringFrequency(item),
          "image": item.images?.isNotEmpty == true 
              ? item.images!.first.url ?? ""
              : "https://via.placeholder.com/400x300",
          "description": _generatePlantDescription(item),
          "lightRequirement": _estimateLightRequirement(item),
          "humidity": _estimateHumidityRequirement(item),
        });
      }
    }
    
    return results;
  }

  String? _extractCommonName(PlantResult result) {
    // Try to get common name in English
    if (result.commonNames != null && result.commonNames!['en'] != null) {
      var commonName = result.commonNames!['en'];
      if (commonName is List && commonName.isNotEmpty) {
        return commonName.first.toString();
      } else if (commonName is String) {
        return commonName;
      }
    }
    return null;
  }

  String _estimateCareDifficulty(PlantResult result) {
    // Placeholder - in a real implementation, you might have a more sophisticated system
    return "Medium"; 
  }

  String _estimateWateringFrequency(PlantResult result) {
    // Placeholder - in a real implementation, you might fetch this from a database
    return "Weekly";
  }

  String _estimateLightRequirement(PlantResult result) {
    // Placeholder - in a real implementation, you might fetch this from a database
    return "Bright indirect light";
  }

  String _estimateHumidityRequirement(PlantResult result) {
    // Placeholder - in a real implementation, you might fetch this from a database
    return "Medium to high";
  }

  String _generatePlantDescription(PlantResult result) {
    final commonName = _extractCommonName(result);
    if (commonName != null) {
      return "This is $commonName (${result.scientificName}). Confidence: ${(result.score! * 100).toStringAsFixed(0)}%";
    } else {
      return "Scientific name: ${result.scientificName}. Confidence: ${(result.score! * 100).toStringAsFixed(0)}%";
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults && _capturedImagePath != null) {
      return IdentificationResultsWidget(
        results: _mockResults,
        onRetryPhoto: _retryPhoto,
        onManualSearch: _manualSearch,
        onSelectPlant: _selectPlant,
      );
    }

    if (_isProcessing && _capturedImagePath != null) {
      return ProcessingScreenWidget(imagePath: _capturedImagePath!);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Initializing camera...',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Plant Outline Guide
          if (_isCameraInitialized)
            const Positioned.fill(
              child: PlantOutlineGuideWidget(),
            ),

          // Top Tips Overlay
          if (_showTips)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: IdentificationTipsWidget(
                  onDismiss: _dismissTips,
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CameraControlsWidget(
              onCapturePressed: _capturePhoto,
              onGalleryPressed: _selectFromGallery,
              onFlashToggle: _toggleFlash,
              isFlashOn: _isFlashOn,
              isWeb: kIsWeb,
            ),
          ),

          // Back Button
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
