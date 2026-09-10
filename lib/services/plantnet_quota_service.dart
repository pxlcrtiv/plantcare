import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant_identification_result.dart';
import 'plantnet_service.dart';

class PlantNetQuotaService {
  static const int dailyLimit = 500;
  static const int warningThreshold = 450;
  static const String _usageKey = 'plantnet_daily_usage';
  static const String _usageDateKey = 'plantnet_usage_date';
  static const String _cachePrefix = 'plantnet_cache_';

  final PlantNetService _plantNetService;
  SharedPreferences? _prefs;

  PlantNetQuotaService({required PlantNetService plantNetService})
      : _plantNetService = plantNetService;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  int _usageToday(SharedPreferences prefs) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final storedDate = prefs.getString(_usageDateKey) ?? '';
    if (storedDate != today) return 0;
    return prefs.getInt(_usageKey) ?? 0;
  }

  Future<bool> get isQuotaExhausted async =>
      (await _getPrefs()).let((p) => _usageToday(p) >= dailyLimit);

  Future<bool> get isNearQuota async =>
      (await _getPrefs()).let((p) => _usageToday(p) >= warningThreshold);

  Future<int> get remaining async =>
      (dailyLimit - _usageToday(await _getPrefs())).clamp(0, dailyLimit);

  Future<void> _incrementUsage() async {
    final prefs = await _getPrefs();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final storedDate = prefs.getString(_usageDateKey) ?? '';
    if (storedDate != today) {
      await prefs.setString(_usageDateKey, today);
      await prefs.setInt(_usageKey, 1);
    } else {
      await prefs.setInt(_usageKey, _usageToday(prefs) + 1);
    }
  }

  String _hashBytes(Uint8List bytes) => md5.convert(bytes).toString();

  PlantIdentificationResult? _getCachedResult(
      SharedPreferences prefs, String hash) {
    final cached = prefs.getString('$_cachePrefix$hash');
    if (cached == null) return null;
    return PlantIdentificationResult.fromJson(jsonDecode(cached));
  }

  Future<void> _cacheResult(
      String hash, PlantIdentificationResult result) async {
    final prefs = await _getPrefs();
    await prefs.setString('$_cachePrefix$hash', jsonEncode(result.toJson()));
  }

  Future<PlantIdentificationResult> identifyPlantFromBytes(
    Uint8List imageBytes, {
    String filename = 'plant_image.jpg',
  }) async {
    final prefs = await _getPrefs();
    final hash = _hashBytes(imageBytes);
    final cached = _getCachedResult(prefs, hash);
    if (cached != null) return cached;

    if (_usageToday(prefs) >= dailyLimit) {
      throw PlantNetQuotaException(
        'Daily identification limit reached ($dailyLimit/day). '
        'Please try again tomorrow.',
      );
    }

    final result = await _plantNetService.identifyPlantFromBytes(
      imageBytes,
      filename: filename,
    );

    await _incrementUsage();
    await _cacheResult(hash, result);

    return result;
  }

  Future<PlantIdentificationResult> identifyPlantFromUrl(
      String imageUrl) async {
    final prefs = await _getPrefs();
    final hash = md5.convert(utf8.encode(imageUrl)).toString();
    final cached = _getCachedResult(prefs, hash);
    if (cached != null) return cached;

    if (_usageToday(prefs) >= dailyLimit) {
      throw PlantNetQuotaException(
        'Daily identification limit reached ($dailyLimit/day). '
        'Please try again tomorrow.',
      );
    }

    final result = await _plantNetService.identifyPlantFromUrl(imageUrl);

    await _incrementUsage();
    await _cacheResult(hash, result);

    return result;
  }
}

class PlantNetQuotaException implements Exception {
  final String message;
  PlantNetQuotaException(this.message);

  @override
  String toString() => message;
}

extension _Let<T> on T {
  R let<R>(R Function(T) fn) => fn(this);
}
