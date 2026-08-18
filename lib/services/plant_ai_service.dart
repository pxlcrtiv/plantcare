abstract class PlantAiService {
  Future<bool> isAvailable();
}

class StubPlantAiService implements PlantAiService {
  const StubPlantAiService();

  @override
  Future<bool> isAvailable() async => false;
}