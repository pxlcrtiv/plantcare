import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../providers/plant_ai_service_provider.dart';
import '../../services/plant_ai_service.dart';

class PlantDoctorStubScreen extends StatefulWidget {
  const PlantDoctorStubScreen({super.key, this.initialSpecies});

  final String? initialSpecies;

  @override
  State<PlantDoctorStubScreen> createState() => _PlantDoctorStubScreenState();
}

class _PlantDoctorStubScreenState extends State<PlantDoctorStubScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _speciesController = TextEditingController();

  PlantAiService _service = const StubPlantAiService();
  Uint8List? _photoBytes;
  String _photoMimeType = 'image/jpeg';
  bool _isLoading = false;
  DiagnosisResult? _result;
  PlantAiException? _error;

  @override
  void initState() {
    super.initState();
    _speciesController.text = widget.initialSpecies ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final service = PlantAiServiceProvider.of(context);
    if (!identical(service, _service)) {
      _service = service;
    }
  }

  @override
  void dispose() {
    _speciesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final XFile? image;
    try {
      image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
    } catch (_) {
      if (mounted) {
        _showPickError();
      }
      return;
    }
    if (image == null || !mounted) return;
    final Uint8List bytes = await image.readAsBytes();
    final String mimeType = image.mimeType ?? 'image/jpeg';
    setState(() {
      _photoBytes = bytes;
      _photoMimeType = mimeType;
      _result = null;
      _error = null;
    });
  }

  void _showPickError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not pick a photo. Please try again.')),
    );
  }

  Future<void> _diagnose() async {
    final photoBytes = _photoBytes;
    if (photoBytes == null || _isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final species = _speciesController.text.trim();
    try {
      final result = await _service.diagnosePlant(
        DiagnosisRequest(
          photoBytes: photoBytes,
          photoMimeType: _photoMimeType,
          species: species.isEmpty ? null : species,
        ),
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } on PlantAiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = const UnknownError();
        _isLoading = false;
      });
    }
  }

  void _resetToNewPhoto() {
    setState(() {
      _photoBytes = null;
      _result = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Plant Doctor',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _isLoading ? _buildLoading(context) : _buildContent(context),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
      children: [
        if (_photoBytes != null) _buildPhotoPreview(context),
        SizedBox(height: 4.h),
        Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        ),
        SizedBox(height: 2.h),
        Center(
          child: Text(
            'Diagnosing your plant…',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : const Color(0xFF888888),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final result = _result;
    if (result != null) {
      return _buildResult(context, result);
    }
    return ListView(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
      children: [
        _buildPhotoSection(context),
        SizedBox(height: 2.h),
        _buildSpeciesField(context),
        SizedBox(height: 2.h),
        _buildDiagnoseButton(context),
        if (_error != null) ...[
          SizedBox(height: 2.h),
          _buildErrorCard(context, _error!),
        ],
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    final photoBytes = _photoBytes;
    if (photoBytes != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoPreview(context),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildPhotoActionButton(
                  context,
                  icon: Icons.photo_camera_outlined,
                  label: 'Retake',
                  onTap: () => _pickPhoto(ImageSource.camera),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildPhotoActionButton(
                  context,
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _pickPhoto(ImageSource.gallery),
                ),
              ),
            ],
          ),
        ],
      );
    }
    return _buildCard(
      context,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_information_outlined,
              size: 9.w,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Snap a photo of the ailing leaf',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'The assistant will diagnose the issue and suggest care steps.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : const Color(0xFF888888),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _pickPhoto(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.memory(
        _photoBytes!,
        height: 32.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 32.h,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );
  }

  Widget _buildPhotoActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 4.w),
      label: Text(label),
    );
  }

  Widget _buildSpeciesField(BuildContext context) {
    return TextField(
      controller: _speciesController,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Species (optional)',
        hintText: 'e.g. Monstera deliciosa',
        prefixIcon: const Icon(Icons.local_florist_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildDiagnoseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: FilledButton.icon(
        onPressed: _photoBytes == null ? null : _diagnose,
        icon: const Icon(Icons.healing_outlined),
        label: const Text('Diagnose'),
      ),
    );
  }

  Widget _buildResult(BuildContext context, DiagnosisResult result) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
      children: [
        _buildCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      result.condition,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  _buildSeverityChip(context, result.severity),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                '${(result.confidence * 100).toStringAsFixed(0)}% confidence',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : const Color(0xFF888888),
                ),
              ),
              if (result.causes.isNotEmpty) ...[
                SizedBox(height: 2.h),
                _buildSectionTitle(context, 'Likely causes'),
                SizedBox(height: 0.5.h),
                ...result.causes.map(
                  (cause) => Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 1.5.w, color: colorScheme.primary),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(cause, style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (result.careSteps.isNotEmpty) ...[
                SizedBox(height: 2.h),
                _buildSectionTitle(context, 'Care steps'),
                SizedBox(height: 0.5.h),
                ...result.careSteps.asMap().entries.map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(bottom: 0.5.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 5.w,
                              height: 5.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
        SizedBox(height: 2.h),
        OutlinedButton.icon(
          onPressed: _resetToNewPhoto,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: const Text('Diagnose another photo'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildSeverityChip(BuildContext context, String severity) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color color = switch (severity.toLowerCase()) {
      'mild' => colorScheme.primary,
      'severe' => colorScheme.error,
      _ => colorScheme.tertiary,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        severity,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, PlantAiException error) {
    final (title, message, icon) = _errorPresentation(error);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 5.w, color: colorScheme.primary),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : const Color(0xFF888888),
            ),
          ),
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _diagnose,
              child: const Text('Try again'),
            ),
          ),
        ],
      ),
    );
  }

  (String, String, IconData) _errorPresentation(PlantAiException error) {
    return switch (error) {
      QuotaExceededError() => (
          'The assistant is resting',
          'Try again in a moment.',
          Icons.self_improvement,
        ),
      MalformedOutputError() => (
          'The assistant is resting',
          'Try again in a moment.',
          Icons.self_improvement,
        ),
      BlockedError() => (
          'Photo not reviewable',
          'The assistant could not review this photo. Please try a different one.',
          Icons.visibility_off_outlined,
        ),
      TimeoutError() => (
          'The assistant took too long',
          'Please try again in a moment.',
          Icons.hourglass_empty,
        ),
      OfflineError() => (
          "You're offline",
          'AI features need a connection.',
          Icons.cloud_off,
        ),
      UnknownError() => (
          'Something went wrong',
          'Please try again.',
          Icons.error_outline,
        ),
    };
  }

  Widget _buildCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}