import 'package:flutter/material.dart';
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
                  Text(
                    info.description,
                    style: textTheme.bodyLarge,
                  ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoItem(
          icon: '💨',
          label: 'Wind',
          value: '${weather.windSpeed.toStringAsFixed(0)} km/h ${weather.windDirText}',
        ),
        _InfoItem(
          icon: '💧',
          label: 'Luftfeuchte',
          value: '${weather.humidity.toStringAsFixed(0)}%',
        ),
        _InfoItem(
          icon: '🌧',
          label: 'Niederschlag',
          value: '${weather.precipitation.toStringAsFixed(1)} mm',
        ),
        if (uvIndex != null) _UvCircleItem(uvIndex: uvIndex!),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: textTheme.bodySmall),
        Text(value, style: textTheme.titleMedium),
      ],
    );
  }
}

class _UvCircleItem extends StatelessWidget {
  final double uvIndex;

  const _UvCircleItem({required this.uvIndex});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color     = Color(int.parse('FF${WeatherService.uvColor(uvIndex)}', radix: 16));
    final fraction  = (uvIndex / 11).clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: fraction,
                strokeWidth: 3.5,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              uvIndex.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('UV-Index', style: textTheme.bodySmall),
        Text(
          WeatherService.uvDescription(uvIndex),
          style: textTheme.titleMedium,
        ),
      ],
    );
  }
}
