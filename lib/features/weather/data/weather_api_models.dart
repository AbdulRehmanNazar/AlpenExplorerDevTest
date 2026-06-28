import 'package:json_annotation/json_annotation.dart';

part 'weather_api_models.g.dart';

@JsonSerializable(explicitToJson: true)
class WeatherApiResponse {
  final CurrentWeatherJson current;
  final DailyJson daily;
  final HourlyJson hourly;

  const WeatherApiResponse({
    required this.current,
    required this.daily,
    required this.hourly,
  });

  factory WeatherApiResponse.fromJson(Map<String, dynamic> json) =>
      _$WeatherApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherApiResponseToJson(this);
}

@JsonSerializable()
class CurrentWeatherJson {
  @JsonKey(name: 'temperature_2m')
  final double temperature2m;

  @JsonKey(name: 'apparent_temperature')
  final double apparentTemperature;

  @JsonKey(name: 'weather_code')
  final int weatherCode;

  @JsonKey(name: 'wind_speed_10m')
  final double windSpeed10m;

  @JsonKey(name: 'wind_direction_10m')
  final double windDirection10m;

  @JsonKey(name: 'relative_humidity_2m')
  final double relativeHumidity2m;

  final double precipitation;

  const CurrentWeatherJson({
    required this.temperature2m,
    required this.apparentTemperature,
    required this.weatherCode,
    required this.windSpeed10m,
    required this.windDirection10m,
    required this.relativeHumidity2m,
    required this.precipitation,
  });

  factory CurrentWeatherJson.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentWeatherJsonToJson(this);
}

@JsonSerializable()
class DailyJson {
  final List<String> time;

  @JsonKey(name: 'weather_code')
  final List<int> weatherCode;

  @JsonKey(name: 'temperature_2m_max')
  final List<double> temperature2mMax;

  @JsonKey(name: 'temperature_2m_min')
  final List<double> temperature2mMin;

  @JsonKey(name: 'precipitation_sum')
  final List<double> precipitationSum;

  @JsonKey(name: 'uv_index_max')
  final List<double> uvIndexMax;

  final List<String> sunrise;
  final List<String> sunset;

  const DailyJson({
    required this.time,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationSum,
    required this.uvIndexMax,
    required this.sunrise,
    required this.sunset,
  });

  factory DailyJson.fromJson(Map<String, dynamic> json) =>
      _$DailyJsonFromJson(json);

  Map<String, dynamic> toJson() => _$DailyJsonToJson(this);
}

@JsonSerializable()
class HourlyJson {
  final List<String> time;

  @JsonKey(name: 'temperature_2m')
  final List<double> temperature2m;

  @JsonKey(name: 'precipitation_probability')
  final List<int> precipitationProbability;

  @JsonKey(name: 'weather_code')
  final List<int> weatherCode;

  const HourlyJson({
    required this.time,
    required this.temperature2m,
    required this.precipitationProbability,
    required this.weatherCode,
  });

  factory HourlyJson.fromJson(Map<String, dynamic> json) =>
      _$HourlyJsonFromJson(json);

  Map<String, dynamic> toJson() => _$HourlyJsonToJson(this);
}
