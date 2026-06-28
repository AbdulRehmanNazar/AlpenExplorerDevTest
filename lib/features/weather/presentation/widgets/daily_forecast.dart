import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/weather_service_stub.dart';

class DailyForecast extends StatelessWidget {
  final List<DailyWeather> days;

  const DailyForecast({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayDays = days.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('5-Tage-Prognose', style: textTheme.headlineMedium),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (int i = 0; i < displayDays.length; i++) ...[
                _DayRow(day: displayDays[i]),
                if (i < displayDays.length - 1)
                  const Divider(height: 0),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final DailyWeather day;

  const _DayRow({required this.day});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uvColor = Color(int.parse('FF${WeatherService.uvColor(day.uvIndex)}', radix: 16));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(day.weekday, style: textTheme.titleMedium),
          ),
          const SizedBox(width: 8),
          Text(day.info.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(day.info.description, style: textTheme.bodyMedium),
          ),
          _UvBadge(uv: day.uvIndex, color: uvColor),
          const SizedBox(width: 12),
          Text(
            '${day.minTemp.toStringAsFixed(0)}°',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(width: 4),
          Text('–', style: textTheme.bodyMedium),
          const SizedBox(width: 4),
          SizedBox(
            width: 36,
            child: Text(
              '${day.maxTemp.toStringAsFixed(0)}°',
              style: textTheme.titleMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _UvBadge extends StatelessWidget {
  final double uv;
  final Color color;

  const _UvBadge({required this.uv, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'UV ${uv.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
