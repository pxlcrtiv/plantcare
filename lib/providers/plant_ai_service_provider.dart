import 'package:flutter/widgets.dart';

import '../services/plant_ai_service.dart';

class PlantAiServiceProvider extends InheritedWidget {
  const PlantAiServiceProvider({
    super.key,
    required this.service,
    required super.child,
  });

  final PlantAiService service;

  static PlantAiService of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<PlantAiServiceProvider>();
    return provider?.service ?? const StubPlantAiService();
  }

  @override
  bool updateShouldNotify(PlantAiServiceProvider oldWidget) =>
      service != oldWidget.service;
}