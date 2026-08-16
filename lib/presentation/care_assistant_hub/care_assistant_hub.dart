import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'care_chat_stub_screen.dart';
import 'plant_doctor_stub_screen.dart';

/// "Flask" dock tab: the Care Assistant hub — landing page for the app's
/// upcoming AI features (Plant Doctor photo diagnosis + Care chat).
class CareAssistantHub extends StatelessWidget {
  const CareAssistantHub({super.key});

  void _openPlantDoctor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlantDoctorStubScreen()),
    );
  }

  void _openCareChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CareChatStubScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
      children: [
        Text(
          'Care Assistant',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
        ),
        SizedBox(height: 0.8.h),
        Text(
          'Your AI partner for keeping every plant thriving',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xFF888888),
          ),
        ),
        SizedBox(height: 3.h),
        _FeatureCard(
          icon: Icons.medical_information_outlined,
          title: 'Plant Doctor',
          description: 'Snap a photo and get an instant health diagnosis.',
          onTap: () => _openPlantDoctor(context),
        ),
        SizedBox(height: 2.h),
        _FeatureCard(
          icon: Icons.chat_outlined,
          title: 'Care chat',
          description: 'Ask anything about watering, light and repotting.',
          onTap: () => _openCareChat(context),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 7.w, color: colorScheme.primary),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}