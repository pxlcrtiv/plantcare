import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plantcare/repositories/plant_repository.dart';
import 'package:plantcare/services/sync_service.dart';

/// Deterministic connectivity source: the documented connectivity_plus
/// testing seam (ConnectivityPlatform.instance) backed by scripted results.
class FakeConnectivityPlatform extends ConnectivityPlatform {
  FakeConnectivityPlatform({List<ConnectivityResult>? checkResult})
    : checkResult = checkResult ?? [ConnectivityResult.none];

  List<ConnectivityResult> checkResult;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => checkResult;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

class MockPlantRepository extends Mock implements PlantRepository {}

void main() {
  late FakeConnectivityPlatform fakeConnectivity;
  late ConnectivityPlatform originalPlatform;
  late SyncService service;

  setUp(() {
    originalPlatform = ConnectivityPlatform.instance;
    fakeConnectivity = FakeConnectivityPlatform();
    ConnectivityPlatform.instance = fakeConnectivity;

    service = SyncService(MockPlantRepository());
  });

  tearDown(() {
    ConnectivityPlatform.instance = originalPlatform;
  });

  group('isConnected', () {
    test('reports false when the only connectivity result is none', () async {
      fakeConnectivity.checkResult = [ConnectivityResult.none];

      expect(await service.isConnected(), isFalse);
    });

    test('reports true when a concrete connection is available', () async {
      fakeConnectivity.checkResult = [ConnectivityResult.wifi];

      expect(await service.isConnected(), isTrue);
    });

    test('reports false when none appears alongside other results', () async {
      fakeConnectivity.checkResult = [
        ConnectivityResult.mobile,
        ConnectivityResult.none,
      ];

      expect(await service.isConnected(), isFalse);
    });
  });
}