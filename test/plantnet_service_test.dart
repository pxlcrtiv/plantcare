import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare/services/plantnet_service.dart';

/// A deterministic no-network adapter that records the last request and
/// replays a canned PlantNet-shaped JSON (or an error).
class FakePlantNetAdapter implements HttpClientAdapter {
  FakePlantNetAdapter({
    this.responseBody = _sampleJson,
    this.statusCode = 200,
    this.throwOnFetch = false,
  });

  final String responseBody;
  int statusCode;
  bool throwOnFetch;

  RequestOptions? lastRequest;
  Object? lastData;

  static const _sampleJson = '''
  {
    "queryId": "q-123",
    "queryType": "tk",
    "queryHash": "abc",
    "queryImage": "https://example.com/plant.jpg",
    "results": [
      {
        "score": 0.912,
        "species": {
          "scientificName": "Monstera deliciosa",
          "family": {"scientificName": "Araceae"},
          "genus": {"scientificName": "Monstera"},
          "commonNames": {"eng": "Swiss cheese plant"},
          "images": [{"m": {"url": "https://cdn.example.com/m.jpg"}}],
          "gbif": {"id": 12345},
          "links": {"self": "https://api.example.com/species/1"}
        }
      }
    ],
    "similarImages": [
      {"url": "https://cdn.example.com/sim.jpg", "sourceUrl": "https://source.example.com/sim.jpg"}
    ]
  }
  ''';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    lastRequest = options;
    lastData = options.data;
    if (throwOnFetch) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'Network is unreachable',
      );
    }
    return ResponseBody.fromBytes(
      utf8.encode(responseBody),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FakePlantNetAdapter adapter;
  late Dio dio;
  late PlantNetService service;

  setUp(() {
    adapter = FakePlantNetAdapter();
    dio = Dio()..httpClientAdapter = adapter;
    service = PlantNetService(apiKey: 'TEST_KEY', dio: dio);
  });

  group('identifyPlantFromUrl', () {
    test('parses a 200 response into a PlantIdentificationResult', () async {
      final result = await service.identifyPlantFromUrl(
        'https://example.com/plant.jpg',
      );

      expect(result.results, hasLength(1));
      expect(result.results.first.scientificName, 'Monstera deliciosa');
      expect(result.results.first.score, closeTo(0.912, 0.0001));
      expect(result.results.first.family, 'Araceae');
      expect(result.similarImages, hasLength(1));
    });

    test('sends the injected api-key as a query parameter', () async {
      await service.identifyPlantFromUrl('https://example.com/plant.jpg');

      expect(adapter.lastRequest!.queryParameters['api-key'], 'TEST_KEY');
      expect(
        adapter.lastRequest!.queryParameters['images'],
        'https://example.com/plant.jpg',
      );
    });

    test('throws when the API returns a non-200 status', () async {
      adapter.statusCode = 401;

      expect(
        () => service.identifyPlantFromUrl('https://example.com/plant.jpg'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to identify plant: 401'),
          ),
        ),
      );
    });

    test('wraps a DioException as an Exception mentioning the failure', () async {
      adapter.throwOnFetch = true;

      expect(
        () => service.identifyPlantFromUrl('https://example.com/plant.jpg'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('API request failed'),
          ),
        ),
      );
    });
  });

  group('identifyPlantFromImageFile', () {
    late File tempFile;

    setUp(() {
      tempFile = File(
        '${Directory.systemTemp.path}/plant_test_'
        '${DateTime.now().microsecondsSinceEpoch}.jpg',
      )..writeAsBytesSync([1, 2, 3]);
    });

    tearDown(() {
      if (tempFile.existsSync()) tempFile.deleteSync();
    });

    test('posts multipart form data and returns the result', () async {
      final result = await service.identifyPlantFromImageFile(tempFile.path);

      expect(result.results.first.scientificName, 'Monstera deliciosa');
      expect(adapter.lastRequest!.method, 'POST');
      expect(adapter.lastData, isA<FormData>());
    });

    test('sends the injected api-key inside the multipart form', () async {
      await service.identifyPlantFromImageFile(tempFile.path);

      final formData = adapter.lastData as FormData;
      final apiKeyField = formData.fields.firstWhere(
        (f) => f.key == 'api-key',
        orElse: () => const MapEntry('missing', ''),
      );
      expect(apiKeyField.value, 'TEST_KEY');
    });
  });

  group('identifyPlantFromMultipleImages', () {
    late List<File> tempFiles;

    setUp(() {
      tempFiles = List.generate(
        2,
        (i) => File(
          '${Directory.systemTemp.path}/plant_multi_$i'
          '_${DateTime.now().microsecondsSinceEpoch}.jpg',
        )..writeAsBytesSync([i, i + 1]),
      );
    });

    tearDown(() {
      for (final f in tempFiles) {
        if (f.existsSync()) f.deleteSync();
      }
    });

    test('posts all images and returns the result', () async {
      final result = await service.identifyPlantFromMultipleImages(
        tempFiles.map((f) => f.path).toList(),
      );

      expect(result.results.first.scientificName, 'Monstera deliciosa');
      final formData = adapter.lastData as FormData;
      final imageEntries =
          formData.files.where((f) => f.key == 'images').toList();
      expect(imageEntries, hasLength(2));
    });
  });
}
