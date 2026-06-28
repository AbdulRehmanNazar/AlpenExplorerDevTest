import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/weather_bloc.dart';
import '../widgets/weather_hero.dart';
import '../widgets/hourly_scroll.dart';
import '../widgets/daily_forecast.dart';
import '../widgets/storm_warning.dart';
import '../widgets/location_drawer.dart';
import '../widgets/sunrise_sunset_card.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const LocationDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: const Text('AlpenExplorer Wetter'),
        actions: [],
      ),
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading || state is WeatherInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WeatherError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Keine Verbindung',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context
                          .read<WeatherBloc>()
                          .add(const WeatherRefreshRequested()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is WeatherLoaded) {
            final data = state.data;
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<WeatherBloc>()
                    .add(const WeatherRefreshRequested());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.isOffline)
                      Container(
                        width: double.infinity,
                        color: AppTheme.accent.withOpacity(0.12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wifi_off,
                              size: 16,
                              color: AppTheme.accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Offline – Daten vom letzten Abruf',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppTheme.accent),
                            ),
                          ],
                        ),
                      ),
                    if (data.current.isStorm) const StormWarningBanner(),
                    WeatherHero(
                      weather: data.current,
                      location: state.location,
                      uvIndex: data.daily.isNotEmpty
                          ? data.daily.first.uvIndex
                          : null,
                    ),
                    HourlyScroll(hours: data.hourly),
                    if (data.daily.isNotEmpty)
                      SunriseSunsetCard(today: data.daily.first),
                    DailyForecast(days: data.daily),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
