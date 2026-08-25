import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../repositories/plant_repository.dart';
import '../../repositories/plant_repository_impl.dart';
import '../../services/firebase_service.dart';
import '../../models/plant.dart';
import './widgets/care_schedule_setup.dart';
import './widgets/entry_method_card.dart';
import './widgets/manual_entry_form.dart';
import './widgets/photo_capture_section.dart';
import './widgets/plant_database_browser.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key, this.repository});

  final PlantRepository? repository;

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Entry method selection
  String _selectedEntryMethod = '';

  // Form data
  Map<String, dynamic> _plantFormData = {};
  Map<String, dynamic> _careScheduleData = {};
  List<XFile> _plantPhotos = [];
  Map<String, dynamic> _selectedPlantFromDatabase = {};

  // Edit mode (when the screen is opened from a plant card)
  bool _isEditing = false;
  String? _editingPlantId;

  late PlantRepository _plantRepository;

  final List<String> _stepTitles = [
    'Choose Method',
    'Plant Details',
    'Add Photos',
    'Care Schedule',
    'Review & Save'
  ];

  bool _argsProcessed = false;

  @override
  void initState() {
    super.initState();
    _plantRepository =
        widget.repository ?? PlantRepositoryImpl(FirebaseService());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsProcessed) return;
    _argsProcessed = true;

    // Prefill from the Search tab: a database plant lands directly on
    // Review & Save with everything set.
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['database'] is Map) {
      final db = Map<String, dynamic>.from(args['database'] as Map);
      _selectedEntryMethod = 'database';
      _selectedPlantFromDatabase = db;
      _plantFormData = {
        'plantName': db['commonName'],
        'species': db['name'],
        'location': '',
        'imageUrl': db['image'],
        'light': db['lightRequirement'],
      };
      _careScheduleData = {
        'wateringFrequency': db['wateringFrequency'],
        'fertilizingEnabled': false,
        'fertilizingFrequency': 30,
        'mistingEnabled': false,
        'mistingFrequency': 3,
        'rotatingEnabled': false,
        'rotatingFrequency': 7,
      };
      _currentStep = _stepTitles.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pageController.jumpToPage(_stepTitles.length - 1);
      });
    } else if (args is Map && args['scientificName'] is String) {
      _selectedEntryMethod = 'database';
      _plantFormData = {
        'plantName': args['name'] ?? '',
        'species': args['scientificName'],
        'location': '',
        'imageUrl': args['image'] ?? '',
        'light': args['lightRequirement'],
      };
      final watering = args['wateringFrequency'];
      int wateringDays = 7;
      if (watering is num) {
        wateringDays = watering.round().clamp(1, 30).toInt();
      } else if (watering is String) {
        wateringDays = switch (watering.toLowerCase()) {
          'daily' => 1,
          'biweekly' => 14,
          'monthly' => 30,
          _ => 7,
        };
      }
      _careScheduleData = {
        'wateringFrequency': wateringDays,
        'fertilizingEnabled': false,
        'fertilizingFrequency': 30,
        'mistingEnabled': false,
        'mistingFrequency': 3,
        'rotatingEnabled': false,
        'rotatingFrequency': 7,
      };
      _currentStep = _stepTitles.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pageController.jumpToPage(_stepTitles.length - 1);
      });
    } else if (args is Map &&
        args['id'] is String &&
        (args['id'] as String).isNotEmpty) {
      // Edit mode: an existing plant map (from the plant card "Edit" action)
      // was passed. Prefill every form field and save via updatePlant.
      _isEditing = true;
      _editingPlantId = args['id'] as String;
      _selectedEntryMethod = 'manual';
      _plantFormData = {
        'plantName': args['name'] ?? '',
        'species': args['species'] ?? '',
        'location': args['location'] ?? '',
        'imageUrl': args['imageUrl'] ?? '',
        'light': args['light'],
        'humidity': args['humidity'],
        'careNotes': args['careNotes'],
      };
      final careSchedule = args['careSchedule'];
      if (careSchedule is Map) {
        final care = Map<String, dynamic>.from(careSchedule);
        _careScheduleData = {
          'wateringFrequency': care['wateringFrequency'] ?? 7,
          'fertilizingEnabled': care['fertilizingEnabled'] == true,
          'fertilizingFrequency': care['fertilizingFrequency'] ?? 30,
          'mistingEnabled': care['mistingEnabled'] == true,
          'mistingFrequency': care['mistingFrequency'] ?? 3,
          'rotatingEnabled': care['rotatingEnabled'] == true,
          'rotatingFrequency': care['rotatingFrequency'] ?? 7,
        };
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildEntryMethodSelection(),
                _buildPlantDetailsStep(),
                _buildPhotoStep(),
                _buildCareScheduleStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isEditing ? 'Edit Plant' : 'Add New Plant',
        style: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'close',
          color: Theme.of(context).colorScheme.onSurface,
          size: 6.w,
        ),
      ),
      actions: [
        if (_currentStep > 0)
          TextButton(
            onPressed: _canSave() ? _savePlant : null,
            child: Text(
              _isEditing ? 'Save Changes' : 'Save',
              style: TextStyle(
                color: _canSave()
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          Row(
            children: List.generate(_stepTitles.length, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  decoration: BoxDecoration(
                    color: isCompleted || isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline
                            .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 1.h),
          Text(
            '${_currentStep + 1} of ${_stepTitles.length}: ${_stepTitles[_currentStep]}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryMethodSelection() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How would you like to add your plant?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Choose the method that works best for you',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          EntryMethodCard(
            title: 'Camera Identification',
            description: 'Take a photo and let AI identify your plant',
            iconName: 'camera_alt',
            isSelected: _selectedEntryMethod == 'camera',
            onTap: () {
              setState(() {
                _selectedEntryMethod = 'camera';
              });
              _navigateToCamera();
            },
          ),
          EntryMethodCard(
            title: 'Browse Database',
            description: 'Search our curated plant collection',
            iconName: 'search',
            isSelected: _selectedEntryMethod == 'database',
            onTap: () {
              setState(() {
                _selectedEntryMethod = 'database';
              });
              _nextStep();
            },
          ),
          EntryMethodCard(
            title: 'Manual Entry',
            description: 'Enter plant details yourself',
            iconName: 'edit',
            isSelected: _selectedEntryMethod == 'manual',
            onTap: () {
              setState(() {
                _selectedEntryMethod = 'manual';
              });
              _nextStep();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlantDetailsStep() {
    if (_selectedEntryMethod == 'database') {
      return PlantDatabaseBrowser(
        onPlantSelected: (plant) {
          setState(() {
            _selectedPlantFromDatabase = plant;
            _plantFormData = {
              'plantName': plant['commonName'],
              'species': plant['name'],
              'location': '',
            };
            _careScheduleData = {
              'wateringFrequency': plant['wateringFrequency'],
              'fertilizingEnabled': false,
              'fertilizingFrequency': 30,
              'mistingEnabled': false,
              'mistingFrequency': 3,
              'rotatingEnabled': false,
              'rotatingFrequency': 7,
            };
          });
          _nextStep();
        },
      );
    } else {
      return SingleChildScrollView(
        child: ManualEntryForm(
          initialData: _isEditing ? _plantFormData : null,
          onFormChanged: (formData) {
            setState(() {
              _plantFormData = formData;
            });
          },
        ),
      );
    }
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      child: PhotoCaptureSection(
        onPhotosChanged: (photos) {
          setState(() {
            _plantPhotos = photos;
          });
        },
      ),
    );
  }

  Widget _buildCareScheduleStep() {
    return SingleChildScrollView(
      child: CareScheduleSetup(
        species: _plantFormData['species'] as String? ?? '',
        light: _plantFormData['light'] as String?,
        humidity: (_plantFormData['humidity'] as num?)?.toInt(),
        location: _plantFormData['location'] as String?,
        initialData: _isEditing ? _careScheduleData : null,
        onScheduleChanged: (scheduleData) {
          setState(() {
            _careScheduleData = scheduleData;
          });
        },
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Plant',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Make sure everything looks correct before saving',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 3.h),

          // Plant Info Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'local_florist',
                        color: Theme.of(context).colorScheme.primary,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Plant Information',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildReviewItem(
                      'Name', _plantFormData['plantName'] ?? 'Not specified'),
                  if (_plantFormData['species']?.isNotEmpty == true)
                    _buildReviewItem('Species', _plantFormData['species']),
                  if (_plantFormData['location']?.isNotEmpty == true)
                    _buildReviewItem('Location', _plantFormData['location']),
                  if (_selectedPlantFromDatabase.isNotEmpty) ...[
                    _buildReviewItem(
                        'Care Level', _selectedPlantFromDatabase['careLevel']),
                    _buildReviewItem('Light Requirement',
                        _selectedPlantFromDatabase['lightRequirement']),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Photos Card
          if (_plantPhotos.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'photo_library',
                          color: Theme.of(context).colorScheme.primary,
                          size: 6.w,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Photos (${_plantPhotos.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      height: 15.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _plantPhotos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 25.w,
                            margin: EdgeInsets.only(right: 2.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb
                                  ? Image.network(
                                      _plantPhotos[index].path,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Theme.of(context).colorScheme.surface,
                                          child: Center(
                                            child: CustomIconWidget(
                                              iconName: 'image',
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              size: 8.w,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : CustomImageWidget(
                                      imageUrl: _plantPhotos[index].path,
                                      width: 25.w,
                                      height: 15.h,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Care Schedule Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: Theme.of(context).colorScheme.primary,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Care Schedule',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildReviewItem('Watering',
                      'Every ${_careScheduleData['wateringFrequency'] ?? 7} days'),
                  if (_careScheduleData['fertilizingEnabled'] == true)
                    _buildReviewItem('Fertilizing',
                        'Every ${_careScheduleData['fertilizingFrequency']} days'),
                  if (_careScheduleData['mistingEnabled'] == true)
                    _buildReviewItem('Misting',
                        'Every ${_careScheduleData['mistingFrequency']} days'),
                  if (_careScheduleData['rotatingEnabled'] == true)
                    _buildReviewItem('Rotating',
                        'Every ${_careScheduleData['rotatingFrequency']} days'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: Text('Back'),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 4.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_currentStep == _stepTitles.length - 1
                        ? _savePlant
                        : _nextStep),
                child: _isLoading
                    ? SizedBox(
                        width: 5.w,
                        height: 5.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(_currentStep == _stepTitles.length - 1
                        ? (_isEditing ? 'Save Changes' : 'Save Plant')
                        : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCamera() {
    Navigator.pushNamed(context, '/plant-identification-camera').then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _plantFormData = result;
          _selectedEntryMethod = 'camera';
        });
        _nextStep();
      }
    });
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canSave() {
    return _plantFormData['plantName']?.isNotEmpty == true && !_isLoading;
  }

  Future<void> _savePlant() async {
    if (!_canSave()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String imageUrl = _plantPhotos.isNotEmpty
          ? _plantPhotos[0].path
          : (_plantFormData['imageUrl']?.isNotEmpty == true
              ? _plantFormData['imageUrl'] as String
              : 'https://via.placeholder.com/400x300');

      if (_isEditing) {
        // Update path: only the fields the wizard edits are written back.
        // Null optionals are dropped so existing values are preserved.
        final data = <String, dynamic>{
          'name': _plantFormData['plantName'] ?? '',
          'species': _plantFormData['species'] ?? '',
          'imageUrl': imageUrl,
          'careNotes': _plantFormData['careNotes'],
          'location': _plantFormData['location'],
          'humidity': (_plantFormData['humidity'] as num?)?.toInt(),
          'light': _plantFormData['light'],
          'careSchedule': _careScheduleData,
          if (_plantPhotos.isNotEmpty)
            'photos': _plantPhotos.map((photo) => photo.path).toList(),
        };
        data.removeWhere((key, value) => value == null);

        await _plantRepository.updatePlant(_editingPlantId!, data);
      } else {
        // Create plant object
        final plant = Plant(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // In production, use Firebase auto-generated ID
          name: _plantFormData['plantName'] ?? '',
          species: _plantFormData['species'] ?? '',
          imageUrl: imageUrl,
          status: 'healthy',
          lastWatered: null,
          nextWatering: null,
          careNotes: _plantFormData['careNotes'],
          location: _plantFormData['location'],
          humidity: (_plantFormData['humidity'] as num?)?.toInt(),
          light: _plantFormData['light'] as String?,
          dateAdded: DateTime.now(),
          careSchedule: _careScheduleData,
          photos: _plantPhotos.map((photo) => photo.path).toList(),
        );

        // Save to Firebase
        await _plantRepository.addPlant(plant);
      }

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.getSuccessColor(Theme.of(context).brightness == Brightness.dark),
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(_isEditing ? 'Plant Updated!' : 'Plant Added!'),
              ],
            ),
            content: Text(_isEditing
                ? 'Plant updated successfully.'
                : '${_plantFormData['plantName']} has been successfully added to your collection.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  if (_isEditing) {
                    Navigator.pop(context); // Return to the dashboard
                  } else {
                    Navigator.pushNamed(context,
                        '/add-plant-screen'); // Add another plant
                  }
                },
                child: Text(_isEditing ? 'Done' : 'Add Another'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/my-plants-dashboard',
                    (route) => false,
                  );
                },
                child: Text('View My Plants'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save plant: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
