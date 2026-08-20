import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// "Target" dock tab: scan CTA that opens the identification camera.
class IdentifyTab extends StatelessWidget {
  final VoidCallback onScan;

  const IdentifyTab({super.key, required this.onScan});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(6.w),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.qr_code_scanner,
                    size: 12.w, color: colorScheme.primary),
              ),
              SizedBox(height: 3.h),
              Text(
                'Scan a plant',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Take a photo and let PlantNet identify the species for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF888888),
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onScan,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Open camera'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}