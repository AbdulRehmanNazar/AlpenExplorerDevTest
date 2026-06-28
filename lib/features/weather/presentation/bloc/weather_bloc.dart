import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/weather_service_stub.dart';
import '../../../../core/services/weather_storage.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _service;

  double? _lastLat;
  double? _lastLon;
  String? _lastLocation;

  WeatherBloc({WeatherService? service})
      : _service = service ?? WeatherService(),
        super(const WeatherInitial()) {
    on<WeatherLocationRequested>(_onLocationRequested);
    on<WeatherLoadRequested>(_onLoadRequested);
    on<WeatherRefreshRequested>(_onRefreshRequested);
    on<WeatherSavedLocationSelected>(_onSavedLocationSelected);
  }


  Future<void> _onLocationRequested(
    WeatherLocationRequested event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());

    Position? position;
    String? locationError;

    try {
      position = await _acquirePosition();
    } on TimeoutException {
      locationError = 'Standortermittlung hat zu lange gedauert. Bitte erneut versuchen.';
    } catch (e) {
      locationError = e.toString().replaceFirst('Exception: ', '');
    }

    if (position == null) {
      emit(WeatherError(locationError ?? 'Standort konnte nicht ermittelt werden.'));
      return;
    }

    _lastLat      = position.latitude;
    _lastLon      = position.longitude;
    _lastLocation = await _resolveLocationName(position.latitude, position.longitude);

    try {
      final data = await _service.getWeather(lat: _lastLat!, lon: _lastLon!);
      await WeatherStorage.cacheWeather(_lastLat!, _lastLon!, data);
      emit(WeatherLoaded(
        data:     data,
        location: _lastLocation!,
        lat:      _lastLat,
        lon:      _lastLon,
      ));
    } catch (_) {
      final cached = await WeatherStorage.loadCachedWeather(_lastLat!, _lastLon!);
      if (cached != null) {
        emit(WeatherLoaded(
          data:      cached,
          location:  _lastLocation!,
          lat:       _lastLat,
          lon:       _lastLon,
          isOffline: true,
        ));
      } else {
        emit(const WeatherError('Keine Verbindung und keine gespeicherten Daten vorhanden.'));
      }
    }
  }

  // ── Explizite Koordinaten (z. B. aus Tests) ───────────────────────────────────

  Future<void> _onLoadRequested(
    WeatherLoadRequested event,
    Emitter<WeatherState> emit,
  ) async {
    _lastLat      = event.lat;
    _lastLon      = event.lon;
    _lastLocation = event.location;

    emit(const WeatherLoading());
    try {
      final data = await _service.getWeather(lat: event.lat, lon: event.lon);
      await WeatherStorage.cacheWeather(event.lat, event.lon, data);
      emit(WeatherLoaded(
        data:     data,
        location: event.location,
        lat:      event.lat,
        lon:      event.lon,
      ));
    } catch (e) {
      emit(WeatherError('Fehler beim Laden der Wetterdaten: ${e.toString()}'));
    }
  }

  // ── Gespeicherter Ort ausgewählt ──────────────────────────────────────────────

  Future<void> _onSavedLocationSelected(
    WeatherSavedLocationSelected event,
    Emitter<WeatherState> emit,
  ) async {
    _lastLat      = event.lat;
    _lastLon      = event.lon;
    _lastLocation = event.name;

    emit(const WeatherLoading());
    try {
      final data = await _service.getWeather(lat: event.lat, lon: event.lon);
      await WeatherStorage.cacheWeather(event.lat, event.lon, data);
      emit(WeatherLoaded(
        data:     data,
        location: event.name,
        lat:      event.lat,
        lon:      event.lon,
      ));
    } catch (_) {
      final cached = await WeatherStorage.loadCachedWeather(event.lat, event.lon);
      if (cached != null) {
        emit(WeatherLoaded(
          data:      cached,
          location:  event.name,
          lat:       event.lat,
          lon:       event.lon,
          isOffline: true,
        ));
      } else {
        emit(WeatherError(
          'Keine Verbindung und keine gespeicherten Daten für ${event.name}.',
        ));
      }
    }
  }

  Future<void> _onRefreshRequested(
    WeatherRefreshRequested event,
    Emitter<WeatherState> emit,
  ) async {
    if (_lastLat == null || _lastLon == null) {
      await _onLocationRequested(const WeatherLocationRequested(), emit);
      return;
    }
    try {
      final data = await _service.getWeather(lat: _lastLat!, lon: _lastLon!);
      await WeatherStorage.cacheWeather(_lastLat!, _lastLon!, data);
      emit(WeatherLoaded(
        data:     data,
        location: _lastLocation ?? 'Mein Standort',
        lat:      _lastLat,
        lon:      _lastLon,
      ));
    } catch (_) {
      final cached = await WeatherStorage.loadCachedWeather(_lastLat!, _lastLon!);
      if (cached != null) {
        emit(WeatherLoaded(
          data:      cached,
          location:  _lastLocation ?? 'Mein Standort',
          lat:       _lastLat,
          lon:       _lastLon,
          isOffline: true,
        ));
      } else {
        emit(const WeatherError('Keine Verbindung und keine gespeicherten Daten vorhanden.'));
      }
    }
  }

  Future<Position> _acquirePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
      const Duration(seconds: 8),
      onTimeout: () => true,
    );
    if (!serviceEnabled) {
      throw Exception('Standortdienste deaktiviert. Bitte in den Einstellungen aktivieren.');
    }

    var permission = await Geolocator.checkPermission().timeout(
      const Duration(seconds: 8),
      onTimeout: () => LocationPermission.denied,
    );
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission().timeout(
        const Duration(seconds: 60),
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied) {
        throw Exception('Standortberechtigung verweigert.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Standortberechtigung dauerhaft verweigert. Bitte in den Einstellungen aktivieren.',
      );
    }

    try {
      final lastKnown = await Geolocator.getLastKnownPosition()
          .timeout(const Duration(seconds: 5));
      if (lastKnown != null) return lastKnown;
    } catch (_) {}

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    ).timeout(const Duration(seconds: 15));
  }

  Future<String> _resolveLocationName(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon)
          .timeout(const Duration(seconds: 8));
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final name = p.locality?.isNotEmpty == true
            ? p.locality!
            : p.subAdministrativeArea?.isNotEmpty == true
                ? p.subAdministrativeArea!
                : p.administrativeArea ?? '';
        if (name.isNotEmpty) return name;
      }
    } catch (_) {}
    return 'Mein Standort';
  }
}
