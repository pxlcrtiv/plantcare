import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Small colored metric icon + label, as seen on the reference design's
/// plant cards (thermometer / sun / droplet).
class MetricIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const MetricIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  factory MetricIcon.thermometer(BuildContext context, String label) =>
      MetricIcon(
        icon: Icons.device_thermostat,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.thermometerDark
            : AppTheme.thermometerLight,
        label: label,
      );

  factory MetricIcon.sun(BuildContext context, String label) => MetricIcon(
        icon: Icons.wb_sunny,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.sunDark
            : AppTheme.sunLight,
        label: label,
      );

  factory MetricIcon.droplet(BuildContext context, String label) => MetricIcon(
        icon: Icons.water_drop,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.dropletDark
            : AppTheme.dropletLight,
        label: label,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : const Color(0xFF888888),
          ),
        ),
      ],
    );
  }
}