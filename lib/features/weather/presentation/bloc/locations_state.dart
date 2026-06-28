part of 'locations_cubit.dart';

class LocationsState extends Equatable {
  final List<SavedLocation> locations;
  final bool isSearching;
  final String? error;
  final String? message;

  const LocationsState({
    this.locations = const [],
    this.isSearching = false,
    this.error,
    this.message,
  });

  @override
  List<Object?> get props => [locations, isSearching, error, message];
}
