import 'package:flutter/material.dart';

import 'widgets/assistant_coming_soon_widget.dart';

/// Stub destination for the Plant Doctor feature (photo → AI diagnosis).
class PlantDoctorStubScreen extends StatelessWidget {
  const PlantDoctorStubScreen({super.key});

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
      body: const AssistantComingSoonWidget(
        icon: Icons.medical_information_outlined,
        title: 'Coming soon',
        message: 'Snap a photo of an ailing leaf and your AI assistant will '
            'diagnose it with tailored care advice.',
      ),
    );
  }
}