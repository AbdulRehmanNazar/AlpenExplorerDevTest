part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class WeatherLocationRequested extends WeatherEvent {
  const WeatherLocationRequested();
}

class WeatherLoadRequested extends WeatherEvent {
  final double lat;
  final double lon;
  final String location;

  const WeatherLoadRequested({
    required this.lat,
    required this.lon,
    required this.location,
  });

  @override
  List<Object?> get props => [lat, lon, location];
}

class WeatherRefreshRequested extends WeatherEvent {
  const WeatherRefreshRequested();
}

class WeatherSavedLocationSelected extends WeatherEvent {
  final String name;
  final double lat;
  final double lon;

  const WeatherSavedLocationSelected({
    required this.name,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [name, lat, lon];
}
