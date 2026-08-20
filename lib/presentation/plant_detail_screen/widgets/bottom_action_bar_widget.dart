import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class BottomActionBarWidget extends StatelessWidget {
  final VoidCallback onWaterPlant;
  final VoidCallback onAddPhoto;
  final VoidCallback onLogCareEvent;
  final VoidCallback onHowToWater;

  const BottomActionBarWidget({
    Key? key,
    required this.onWaterPlant,
    required this.onAddPhoto,
    required this.onLogCareEvent,
    required this.onHowToWater,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final radius = BorderRadius.circular(28);

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 1.5.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Water Plant - Primary action
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: onWaterPlant,
                    icon: const Icon(Icons.water_drop, size: 20),
                    label: Text(
                      'Water Plant',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: radius,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 2.w),

                // How to water
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: onHowToWater,
                    icon: Icon(
                      Icons.water_drop_outlined,
                      size: 18,
                      color: primary,
                    ),
                    label: Text(
                      'How to water',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: radius,
                      ),
                      side: BorderSide(color: primary),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.h),

            // Secondary actions
            Row(
              children: [
                _SecondaryPill(
                  icon: Icons.camera_alt,
                  label: 'Photo',
                  onTap: onAddPhoto,
                ),
                SizedBox(width: 2.w),
                _SecondaryPill(
                  icon: Icons.add_circle_outline,
                  label: 'Log Care',
                  onTap: onLogCareEvent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 1.2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: BorderSide(color: primary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: primary),
            SizedBox(width: 2.w),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}