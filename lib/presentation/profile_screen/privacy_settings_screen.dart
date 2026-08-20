import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Privacy Settings',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              context,
              title: 'Data we collect',
              description:
                  'We only collect the information you add to your plant '
                  'collection:',
              items: const [
                'Plant names and species',
                'Photos of your plants',
                'Care logs and watering schedules',
              ],
            ),
            SizedBox(height: 3.h),
            _buildSection(
              context,
              title: 'Where data is stored',
              description:
                  'Your data is stored securely in our Firebase Cloud '
                  'project. It is used to keep your collection in sync across '
                  'devices and is never sold to third parties.',
            ),
            SizedBox(height: 3.h),
            _buildSection(
              context,
              title: 'Photo usage',
              description:
                  'Photos you upload for plant identification are sent to '
                  'PlantNet so we can recognize the species. When you use the '
                  'AI assistant for health diagnosis, your photos may also be '
                  'sent to Google\'s Gemini API. Your photos are never shared '
                  'publicly.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    List<String> items = const [],
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (items.isNotEmpty) ...[
              SizedBox(height: 1.h),
              for (final item in items)
                Padding(
                  padding: EdgeInsets.only(bottom: 0.5.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}