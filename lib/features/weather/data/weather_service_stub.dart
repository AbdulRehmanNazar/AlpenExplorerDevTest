import 'package:dio/dio.dart';
import 'weather_api_models.dart';

class WeatherService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.open-meteo.com/v1',
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<WeatherData> getWeather({
    required double lat,
    required double lon,
  }) async {
    final response = await _dio.get('/forecast', queryParameters: {
      'latitude':  lat,
      'longitude': lon,
      'current': [
        'temperature_2m',
        'apparent_temperature',
        'weather_code',
        'wind_speed_10m',
        'wind_direction_10m',
        'relative_humidity_2m',
        'precipitation',
      ].join(','),
      'hourly': [
        'temperature_2m',
        'precipitation_probability',
        'weather_code',
      ].join(','),
      'daily': [
        'weather_code',
        'temperature_2m_max',
        'temperature_2m_min',
        'precipitation_sum',
        'uv_index_max',
        'sunrise',
        'sunset',
      ].join(','),
      'timezone':     'Europe/Berlin',
      'forecast_days': 5,
    });
    final api = WeatherApiResponse.fromJson(response.data as Map<String, dynamic>);
    return WeatherData.fromApiResponse(api);
  }

  static WeatherInfo fromCode(int code) => switch (code) {
    0           => const WeatherInfo('Klar und sonnig',      '☀️', 'sunny'),
    1           => const WeatherInfo('Überwiegend klar',     '🌤', 'mostly_clear'),
    2           => const WeatherInfo('Teils bewölkt',        '⛅', 'partly_cloudy'),
    3           => const WeatherInfo('Bedeckt',              '☁️', 'overcast'),
    45 || 48    => const WeatherInfo('Neblig',               '🌫', 'foggy'),
    51 || 53    => const WeatherInfo('Leichter Niesel',      '🌦', 'drizzle'),
    61 || 63    => const WeatherInfo('Regen',                '🌧', 'rain'),
    65          => const WeatherInfo('Starker Regen',        '🌧', 'heavy_rain'),
    71 || 73    => const WeatherInfo('Leichter Schneefall',  '🌨', 'snow'),
    75          => const WeatherInfo('Starker Schneefall',   '❄️', 'heavy_snow'),
    77          => const WeatherInfo('Eiskörnchen',          '🧊', 'ice'),
    80 || 81    => const WeatherInfo('Regenschauer',         '🌦', 'showers'),
    82          => const WeatherInfo('Starke Schauer',       '⛈', 'heavy_showers'),
    85 || 86    => const WeatherInfo('Schneeschauer',        '🌨', 'snow_showers'),
    95          => const WeatherInfo('Gewitter',             '⛈', 'thunderstorm'),
    96 || 99    => const WeatherInfo('Schweres Gewitter',    '⛈', 'heavy_storm'),
    _           => const WeatherInfo('Unbekannt',            '🌡', 'unknown'),
  };

  /// Gewitterwarnung aktiv?
  static bool isStormWarning(int code) => code >= 95;

  /// Lawinenrisiko (vereinfacht)
  static int avalancheRisk(double snowfall, double windKmh) {
    if (snowfall > 30 && windKmh > 50) return 4;
    if (snowfall > 20 || windKmh > 40) return 3;
    if (snowfall > 10) return 2;
    return 1;
  }

  /// UV-Index → Beschreibung
  static String uvDescription(double uv) {
    if (uv >= 11) return 'Extrem';
    if (uv >= 8)  return 'Sehr hoch';
    if (uv >= 6)  return 'Hoch';
    if (uv >= 3)  return 'Mäßig';
    return 'Niedrig';
  }

  /// UV-Index → Farbe
  static String uvColor(double uv) {
    if (uv >= 11) return 'A32D2D';
    if (uv >= 8)  return 'BA7517';
    if (uv >= 6)  return 'E08030';
    if (uv >= 3)  return '4B8A2A';
    return '1D9E75';
  }
}


class WeatherData {
  final CurrentWeather current;
  final List<DailyWeather> daily;
  final List<HourlyWeather> hourly;

  const WeatherData({
    required this.current,
    required this.daily,
    required this.hourly,
  });

  factory WeatherData.fromApiResponse(WeatherApiResponse api) {
    final c = api.current;
    final d = api.daily;
    final h = api.hourly;

    return WeatherData(
      current: CurrentWeather(
        temperature:   c.temperature2m,
        apparentTemp:  c.apparentTemperature,
        weatherCode:   c.weatherCode,
        windSpeed:     c.windSpeed10m,
        windDirection: c.windDirection10m,
        humidity:      c.relativeHumidity2m,
        precipitation: c.precipitation,
      ),
      daily: List.generate(
        d.time.length,
        (i) => DailyWeather(
          date:             DateTime.parse(d.time[i]),
          weatherCode:      d.weatherCode[i],
          maxTemp:          d.temperature2mMax[i],
          minTemp:          d.temperature2mMin[i],
          precipitationSum: d.precipitationSum[i],
          uvIndex:          d.uvIndexMax[i],
          sunrise:          d.sunrise[i],
          sunset:           d.sunset[i],
        ),
      ),
      hourly: List.generate(
        h.time.length.clamp(0, 24),
        (i) => HourlyWeather(
          time:                     DateTime.parse(h.time[i]),
          temperature:              h.temperature2m[i],
          precipitationProbability: h.precipitationProbability[i],
          weatherCode:              h.weatherCode[i],
        ),
      ),
    );
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      WeatherData.fromApiResponse(WeatherApiResponse.fromJson(json));

  Map<String, dynamic> toCacheJson() => {
    'current': {
      'temperature':   current.temperature,
      'apparentTemp':  current.apparentTemp,
      'weatherCode':   current.weatherCode,
      'windSpeed':     current.windSpeed,
      'windDirection': current.windDirection,
      'humidity':      current.humidity,
      'precipitation': current.precipitation,
    },
    'daily': daily.map((d) => {
      'date':             d.date.toIso8601String(),
      'weatherCode':      d.weatherCode,
      'maxTemp':          d.maxTemp,
      'minTemp':          d.minTemp,
      'precipitationSum': d.precipitationSum,
      'uvIndex':          d.uvIndex,
      'sunrise':          d.sunrise,
      'sunset':           d.sunset,
    }).toList(),
    'hourly': hourly.map((h) => {
      'time':                     h.time.toIso8601String(),
      'temperature':              h.temperature,
      'precipitationProbability': h.precipitationProbability,
      'weatherCode':              h.weatherCode,
    }).toList(),
  };

  factory WeatherData.fromCacheJson(Map<String, dynamic> json) {
    final c = json['current'] as Map<String, dynamic>;
    return WeatherData(
      current: CurrentWeather(
        temperature:   (c['temperature']   as num).toDouble(),
        apparentTemp:  (c['apparentTemp']  as num).toDouble(),
        weatherCode:   c['weatherCode']   as int,
        windSpeed:     (c['windSpeed']     as num).toDouble(),
        windDirection: (c['windDirection'] as num).toDouble(),
        humidity:      (c['humidity']      as num).toDouble(),
        precipitation: (c['precipitation'] as num).toDouble(),
      ),
      daily: (json['daily'] as List).map((d) {
        final dm = d as Map<String, dynamic>;
        return DailyWeather(
          date:             DateTime.parse(dm['date'] as String),
          weatherCode:      dm['weatherCode']      as int,
          maxTemp:          (dm['maxTemp']          as num).toDouble(),
          minTemp:          (dm['minTemp']          as num).toDouble(),
          precipitationSum: (dm['precipitationSum'] as num).toDouble(),
          uvIndex:          (dm['uvIndex']          as num).toDouble(),
          sunrise:          dm['sunrise']           as String,
          sunset:           dm['sunset']            as String,
        );
      }).toList(),
      hourly: (json['hourly'] as List).map((h) {
        final hm = h as Map<String, dynamic>;
        return HourlyWeather(
          time:                     DateTime.parse(hm['time'] as String),
          temperature:              (hm['temperature']              as num).toDouble(),
          precipitationProbability: hm['precipitationProbability'] as int,
          weatherCode:              hm['weatherCode']              as int,
        );
      }).toList(),
    );
  }
}

class CurrentWeather {
  final double temperature;
  final double apparentTemp;
  final int    weatherCode;
  final double windSpeed;
  final double windDirection;
  final double humidity;
  final double precipitation;

  const CurrentWeather({
    required this.temperature,
    required this.apparentTemp,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.precipitation,
  });

  WeatherInfo get info        => WeatherService.fromCode(weatherCode);
  bool        get isStorm     => WeatherService.isStormWarning(weatherCode);
  String      get windDirText => _windDir(windDirection);

  static String _windDir(double deg) {
    const dirs = ['N','NO','O','SO','S','SW','W','NW'];
    return dirs[((deg + 22.5) / 45).floor() % 8];
  }
}

class DailyWeather {
  final DateTime date;
  final int      weatherCode;
  final double   maxTemp;
  final double   minTemp;
  final double   precipitationSum;
  final double   uvIndex;
  final String   sunrise;
  final String   sunset;

  const DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationSum,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
  });

  WeatherInfo get info    => WeatherService.fromCode(weatherCode);
  bool        get isStorm => WeatherService.isStormWarning(weatherCode);

  String get weekday {
    const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return days[date.weekday - 1];
  }
}

class HourlyWeather {
  final DateTime time;
  final double   temperature;
  final int      precipitationProbability;
  final int      weatherCode;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.weatherCode,
  });

  WeatherInfo get info => WeatherService.fromCode(weatherCode);
  String get timeLabel => '${time.hour.toString().padLeft(2, '0')}:00';
}

class WeatherInfo {
  final String description;
  final String emoji;
  final String code;
  const WeatherInfo(this.description, this.emoji, this.code);
}
