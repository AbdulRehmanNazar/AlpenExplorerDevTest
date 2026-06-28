import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/weather/data/weather_service_stub.dart';

class SavedLocation {
  final String id;
  final String name;
  final double lat;
  final double lon;

  const SavedLocation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  Map<String, dynamic> toJson() => {
    'id':   id,
    'name': name,
    'lat':  lat,
    'lon':  lon,
  };

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
    id:   json['id']   as String,
    name: json['name'] as String,
    lat:  (json['lat'] as num).toDouble(),
    lon:  (json['lon'] as num).toDouble(),
  );
}

class WeatherStorage {
  static const _boxName        = 'alpenexplorer';
  static const _locationsKey   = 'saved_locations';
  static const _cacheKeyPrefix = 'weather_cache_';

  static Future<Box> _box() => Hive.openBox(_boxName);


  static Future<List<SavedLocation>> loadLocations() async {
    final box = await _box();
    final raw = box.get(_locationsKey, defaultValue: <String>[]);
    return (raw as List)
        .cast<String>()
        .map((s) => SavedLocation.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveLocation(SavedLocation loc) async {
    final box  = await _box();
    final locs = await loadLocations();
    if (locs.any((l) => l.id == loc.id)) return;
    locs.add(loc);
    await box.put(
      _locationsKey,
      locs.map((l) => jsonEncode(l.toJson())).toList(),
    );
  }

  static Future<void> removeLocation(String id) async {
    final box  = await _box();
    final locs = await loadLocations();
    locs.removeWhere((l) => l.id == id);
    await box.put(
      _locationsKey,
      locs.map((l) => jsonEncode(l.toJson())).toList(),
    );
  }


  static String _cacheKey(double lat, double lon) =>
      '$_cacheKeyPrefix${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}';

  static Future<void> cacheWeather(
    double lat,
    double lon,
    WeatherData data,
  ) async {
    final box = await _box();
    await box.put(_cacheKey(lat, lon), jsonEncode(data.toCacheJson()));
  }

  static Future<WeatherData?> loadCachedWeather(double lat, double lon) async {
    final box = await _box();
    final raw = box.get(_cacheKey(lat, lon));
    if (raw == null) return null;
    try {
      return WeatherData.fromCacheJson(
        jsonDecode(raw as String) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
