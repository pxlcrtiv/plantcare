import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  static const String _supportEmail = 'support@plantcare.app';

  Future<void> _copySupportEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _supportEmail));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support email copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          Text(
            'FAQ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 2.h),
          Card(
            child: Column(
              children: [
                _buildFaqTile(
                  context,
                  question: 'How do I identify an unknown plant?',
                  answer:
                      'Tap the Identify tab on the home screen and take a clear photo of the plant\'s leaves or flowers. The app matches the image against a plant database and suggests the most likely species, which you can then add straight to your collection.',
                ),
                const Divider(height: 1),
                _buildFaqTile(
                  context,
                  question: 'How do watering schedules work?',
                  answer:
                      'Each plant keeps its own watering frequency, set when you add it. The app tracks when the plant was last watered and works out the next watering date. Tap "Water Now" on a plant card (or its detail screen) to mark it watered and roll the schedule forward.',
                ),
                const Divider(height: 1),
                _buildFaqTile(
                  context,
                  question: 'How do I edit my plants?',
                  answer:
                      'Long-press a plant card on the home screen and choose "Edit Plant" — the form opens prefilled with your plant\'s details so you can update its name, species, photos, and care schedule. You can also rename a plant directly on its detail screen.',
                ),
                const Divider(height: 1),
                _buildFaqTile(
                  context,
                  question: 'Why am I not getting notifications?',
                  answer:
                      'First check that notifications are enabled in your device settings for PlantCare, and that the app\'s Notification Settings are turned on. Also make sure the plant has a watering schedule set — reminders are only sent for plants with an upcoming watering date.',
                ),
                const Divider(height: 1),
                _buildFaqTile(
                  context,
                  question: 'Can I add a plant manually?',
                  answer:
                      'Yes. From the home screen, open Add Plant and pick "Manual Entry" instead of taking a photo. You can fill in the plant\'s name, species, photos, and care schedule yourself, or browse the built-in plant database for a match.',
                ),
                const Divider(height: 1),
                _buildFaqTile(
                  context,
                  question: 'How do I sign out or manage my account?',
                  answer:
                      'Open the Profile screen to see your account details — your name and email are shown at the top. Use the Sign Out button at the bottom to leave the account; you\'ll be returned to the login screen.',
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Contact Support',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 2.h),
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: Text(
                _supportEmail,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Text(
                'Tap to copy to clipboard',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              trailing: CustomIconWidget(
                iconName: 'content_copy',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              onTap: () => _copySupportEmail(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      children: [
        Text(
          answer,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}