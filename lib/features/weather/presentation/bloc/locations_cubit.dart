import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/services/weather_storage.dart';

part 'locations_state.dart';

class LocationsCubit extends Cubit<LocationsState> {
  LocationsCubit() : super(const LocationsState()) {
    _load();
  }

  Future<void> _load() async {
    final locs = await WeatherStorage.loadLocations();
    emit(LocationsState(locations: locs));
  }

  Future<void> saveCurrentLocation(
    String name,
    double lat,
    double lon,
  ) async {
    final loc = SavedLocation(
      id:   '${lat.toStringAsFixed(3)}_${lon.toStringAsFixed(3)}',
      name: name,
      lat:  lat,
      lon:  lon,
    );
    await WeatherStorage.saveLocation(loc);
    final locs = await WeatherStorage.loadLocations();
    emit(LocationsState(locations: locs, message: '$name gespeichert.'));
  }

  Future<void> addByName(String name) async {
    emit(LocationsState(locations: state.locations, isSearching: true));
    try {
      final results = await locationFromAddress(name)
          .timeout(const Duration(seconds: 10));
      if (results.isEmpty) throw Exception();

      final loc = SavedLocation(
        id:   '${results.first.latitude.toStringAsFixed(3)}_${results.first.longitude.toStringAsFixed(3)}',
        name: name,
        lat:  results.first.latitude,
        lon:  results.first.longitude,
      );
      await WeatherStorage.saveLocation(loc);
      final locs = await WeatherStorage.loadLocations();
      emit(LocationsState(locations: locs));
    } catch (_) {
      emit(LocationsState(
        locations: state.locations,
        error: '"$name" wurde nicht gefunden. Bitte überprüfen Sie den Namen.',
      ));
    }
  }

  Future<void> removeLocation(String id) async {
    await WeatherStorage.removeLocation(id);
    await _load();
  }
}
