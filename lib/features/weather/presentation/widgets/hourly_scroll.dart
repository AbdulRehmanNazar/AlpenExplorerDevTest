import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/weather_service_stub.dart';

class HourlyScroll extends StatelessWidget {
  final List<HourlyWeather> hours;

  const HourlyScroll({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Stündliche Prognose', style: textTheme.headlineMedium),
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: hours.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) => _HourCard(hour: hours[i]),
          ),
        ),
      ],
    );
  }
}

class _HourCard extends StatelessWidget {
  final HourlyWeather hour;

  const _HourCard({required this.hour});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(hour.timeLabel, style: textTheme.labelSmall),
            const SizedBox(height: 2),
            Text(
              hour.info.emoji,
              style: const TextStyle(fontSize: 16, height: 1.2),
            ),
            const SizedBox(height: 2),
            Text(
              '${hour.temperature.toStringAsFixed(0)}°',
              style: textTheme.titleMedium,
            ),
            if (hour.precipitationProbability > 0)
              Text(
                '${hour.precipitationProbability}%',
                style: textTheme.labelSmall?.copyWith(color: AppTheme.secondary),
              ),
          ],
        ),
      ),
    );
  }
}
