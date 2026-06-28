import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/weather_service_stub.dart';

class WeatherHero extends StatelessWidget {
  final CurrentWeather weather;
  final String location;
  final double? uvIndex;

  const WeatherHero({
    super.key,
    required this.weather,
    required this.location,
    this.uvIndex,
  });

  @override
  Widget build(BuildContext context) {
    final info = weather.info;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location, style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.emoji,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(1)}°C',
                    style: textTheme.displayLarge,
                  ),
                  Text(info.description, style: textTheme.bodyLarge),
                  Text(
                    'Gefühlt ${weather.apparentTemp.toStringAsFixed(1)}°C',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow(weather: weather, uvIndex: uvIndex),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final CurrentWeather weather;
  final double? uvIndex;

  const _InfoRow({required this.weather, this.uvIndex});

  @override
  Widget build(BuildContext context) {
    final uvColor = uvIndex != null
        ? Color(int.parse('FF${WeatherService.uvColor(uvIndex!)}', radix: 16))
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoItem(
          lottiePath: 'assets/windy.json',
          label: 'Wind',
          value:
          '${weather.windSpeed.toStringAsFixed(0)} km/h ${weather.windDirText}',
        ),
        _InfoItem(
          lottiePath: 'assets/Humidity.json',
          label: 'Luftfeuchte',
          value: '${weather.humidity.toStringAsFixed(0)}%',
        ),
        _InfoItem(
          lottiePath: 'assets/Raining.json',
          label: 'Niederschlag',
          value: '${weather.precipitation.toStringAsFixed(1)} mm',
        ),
        if (uvIndex != null)
          _InfoItem(
            lottiePath: 'assets/uv.json',
            label: 'UV-Index',
            value:
            '${uvIndex!.toStringAsFixed(0)} · ${WeatherService.uvDescription(uvIndex!)}',
            valueColor: uvColor,
          ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String lottiePath;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.lottiePath,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Lottie.asset(
          lottiePath,
          width: 40,
          height: 40,
          repeat: true,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        Text(label, style: textTheme.bodySmall),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
