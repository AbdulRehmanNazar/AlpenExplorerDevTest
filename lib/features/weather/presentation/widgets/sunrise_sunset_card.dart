import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/weather_service_stub.dart';

class SunriseSunsetCard extends StatelessWidget {
  final DailyWeather today;

  const SunriseSunsetCard({super.key, required this.today});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _SunItem(
                lottiePath: 'assets/Sunrise.json',
                label: 'Sonnenaufgang',
                time: today.sunrise,
              ),
              Container(
                width: 0.5,
                height: 56,
                color: AppTheme.border,
              ),
              _SunItem(
                lottiePath: 'assets/sunset.json',
                label: 'Sonnenuntergang',
                time: today.sunset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SunItem extends StatelessWidget {
  final String lottiePath;
  final String label;
  final String time;

  const _SunItem({
    required this.lottiePath,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            lottiePath,
            width: 52,
            height: 52,
            repeat: true,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: textTheme.bodySmall),
              Text(
                _formatTime(time),
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Strips the date prefix if the API returns "2024-01-15T06:23" format.
  String _formatTime(String raw) {
    if (raw.contains('T')) return raw.split('T').last.substring(0, 5);
    return raw;
  }
}
