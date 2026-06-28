// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherApiResponse _$WeatherApiResponseFromJson(Map<String, dynamic> json) =>
    WeatherApiResponse(
      current:
          CurrentWeatherJson.fromJson(json['current'] as Map<String, dynamic>),
      daily: DailyJson.fromJson(json['daily'] as Map<String, dynamic>),
      hourly: HourlyJson.fromJson(json['hourly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WeatherApiResponseToJson(WeatherApiResponse instance) =>
    <String, dynamic>{
      'current': instance.current.toJson(),
      'daily': instance.daily.toJson(),
      'hourly': instance.hourly.toJson(),
    };

CurrentWeatherJson _$CurrentWeatherJsonFromJson(Map<String, dynamic> json) =>
    CurrentWeatherJson(
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
      windDirection10m: (json['wind_direction_10m'] as num).toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
    );

Map<String, dynamic> _$CurrentWeatherJsonToJson(CurrentWeatherJson instance) =>
    <String, dynamic>{
      'temperature_2m': instance.temperature2m,
      'apparent_temperature': instance.apparentTemperature,
      'weather_code': instance.weatherCode,
      'wind_speed_10m': instance.windSpeed10m,
      'wind_direction_10m': instance.windDirection10m,
      'relative_humidity_2m': instance.relativeHumidity2m,
      'precipitation': instance.precipitation,
    };

DailyJson _$DailyJsonFromJson(Map<String, dynamic> json) => DailyJson(
      time: (json['time'] as List<dynamic>).map((e) => e as String).toList(),
      weatherCode: (json['weather_code'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      temperature2mMax: (json['temperature_2m_max'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      temperature2mMin: (json['temperature_2m_min'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      precipitationSum: (json['precipitation_sum'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      uvIndexMax: (json['uv_index_max'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      sunrise:
          (json['sunrise'] as List<dynamic>).map((e) => e as String).toList(),
      sunset:
          (json['sunset'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DailyJsonToJson(DailyJson instance) => <String, dynamic>{
      'time': instance.time,
      'weather_code': instance.weatherCode,
      'temperature_2m_max': instance.temperature2mMax,
      'temperature_2m_min': instance.temperature2mMin,
      'precipitation_sum': instance.precipitationSum,
      'uv_index_max': instance.uvIndexMax,
      'sunrise': instance.sunrise,
      'sunset': instance.sunset,
    };

HourlyJson _$HourlyJsonFromJson(Map<String, dynamic> json) => HourlyJson(
      time: (json['time'] as List<dynamic>).map((e) => e as String).toList(),
      temperature2m: (json['temperature_2m'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      precipitationProbability:
          (json['precipitation_probability'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
      weatherCode: (json['weather_code'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$HourlyJsonToJson(HourlyJson instance) =>
    <String, dynamic>{
      'time': instance.time,
      'temperature_2m': instance.temperature2m,
      'precipitation_probability': instance.precipitationProbability,
      'weather_code': instance.weatherCode,
    };
