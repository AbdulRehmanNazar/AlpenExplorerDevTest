part of 'weather_bloc.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

class WeatherLoaded extends WeatherState {
  final WeatherData data;
  final String location;
  final double? lat;
  final double? lon;
  final bool isOffline;

  const WeatherLoaded({
    required this.data,
    required this.location,
    this.lat,
    this.lon,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [data, location, lat, lon, isOffline];
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}
