import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/plant_identification_result.dart';

class PlantNetService {
  static const String _baseUrl = 'https://my-api.plantnet.org/v2';
  final String _apiKey;
  final Dio _dio;

  PlantNetService({required String apiKey, Dio? dio})
      : _apiKey = apiKey,
        _dio = dio ?? Dio();

  /// Identify a plant from an image URL
  Future<PlantIdentificationResult> identifyPlantFromUrl(String imageUrl) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/identify/all',
        queryParameters: {
          'api-key': _apiKey,
          'images': imageUrl,
          'include-related-images': 'false',
          'lang': 'en',
        },
      );

      if (response.statusCode == 200) {
        return PlantIdentificationResult.fromJson(response.data);
      } else {
        throw Exception('Failed to identify plant: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('API request failed: ${e.message}');
    }
  }

  /// Identify a plant from a local image file
  Future<PlantIdentificationResult> identifyPlantFromImageFile(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imagePath,
          filename: 'plant_image.jpg',
        ),
        'api-key': _apiKey,
        'lang': 'en',
      });

      final response = await _dio.post(
        '$_baseUrl/identify/all',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PlantIdentificationResult.fromJson(response.data);
      } else {
        throw Exception('Failed to identify plant: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('API request failed: ${e.message}');
    }
  }

  /// Identify a plant from multiple images
  Future<PlantIdentificationResult> identifyPlantFromMultipleImages(
    List<String> imagePaths,
  ) async {
    try {
      final formData = FormData.fromMap({
        'api-key': _apiKey,
        'lang': 'en',
      });

      for (int i = 0; i < imagePaths.length; i++) {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(
            imagePaths[i],
            filename: 'plant_image_$i.jpg',
          ),
        ));
      }

      final response = await _dio.post(
        '$_baseUrl/identify/all',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PlantIdentificationResult.fromJson(response.data);
      } else {
        throw Exception('Failed to identify plant: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('API request failed: ${e.message}');
    }
  }
}