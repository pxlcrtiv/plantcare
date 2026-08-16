import 'package:flutter/material.dart';

import 'widgets/assistant_coming_soon_widget.dart';

/// Stub destination for the Care chat feature (conversational AI advice).
class CareChatStubScreen extends StatelessWidget {
  const CareChatStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Care chat',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: const AssistantComingSoonWidget(
        icon: Icons.chat_outlined,
        title: 'Coming soon',
        message: 'Chat with your AI assistant about watering, light, pests '
            'and more — tailored to your own plants.',
      ),
    );
  }
}