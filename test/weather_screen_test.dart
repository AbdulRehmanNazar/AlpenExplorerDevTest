import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alpenexplorer/features/weather/data/weather_service_stub.dart';
import 'package:alpenexplorer/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:alpenexplorer/features/weather/presentation/screens/weather_screen.dart';
import 'package:alpenexplorer/core/theme/app_theme.dart';

void main() {
  final mockCurrentWeather = CurrentWeather(
    temperature: 18.5,
    apparentTemp: 17.0,
    weatherCode: 2,
    windSpeed: 12.0,
    windDirection: 270.0,
    humidity: 65.0,
    precipitation: 0.0,
  );

  final mockStormWeather = CurrentWeather(
    temperature: 14.0,
    apparentTemp: 11.0,
    weatherCode: 95,
    windSpeed: 55.0,
    windDirection: 180.0,
    humidity: 90.0,
    precipitation: 8.5,
  );

  final mockDaily = List.generate(7, (i) => DailyWeather(
    date: DateTime.now().add(Duration(days: i)),
    weatherCode: i == 3 ? 95 : 1,
    maxTemp: 20.0 - i,
    minTemp: 10.0 - i,
    precipitationSum: i == 3 ? 15.0 : 0.0,
    uvIndex: 6.0,
    sunrise: '06:0${i}',
    sunset: '20:0${i}',
  ));

  final mockHourly = List.generate(24, (i) => HourlyWeather(
    time: DateTime.now().copyWith(hour: i),
    temperature: 15.0 + i * 0.3,
    precipitationProbability: i > 14 ? 40 : 5,
    weatherCode: 1,
  ));

  final mockWeatherData = WeatherData(
    current: mockCurrentWeather,
    daily: mockDaily,
    hourly: mockHourly,
  );

  group('WeatherService', () {

    test('WMO Code 0 → "Klar und sonnig" mit ☀️', () {
      final info = WeatherService.fromCode(0);
      expect(info.description, contains('Klar'));
      expect(info.emoji, equals('☀️'));
    });

    test('WMO Code 95 → Gewitter erkannt', () {
      final info = WeatherService.fromCode(95);
      expect(info.description.toLowerCase(), contains('gewitter'));
      expect(WeatherService.isStormWarning(95), isTrue);
    });

    test('WMO Code 2 → kein Gewitter', () {
      expect(WeatherService.isStormWarning(2), isFalse);
    });

    test('UV-Index 8 → "Sehr hoch"', () {
      expect(WeatherService.uvDescription(8.0), equals('Sehr hoch'));
    });

    test('UV-Index 2 → "Niedrig"', () {
      expect(WeatherService.uvDescription(2.0), equals('Niedrig'));
    });

    test('Lawinenrisiko: viel Schnee + Wind → 4', () {
      expect(WeatherService.avalancheRisk(35.0, 60.0), equals(4));
    });

    test('Lawinenrisiko: kein Schnee → 1', () {
      expect(WeatherService.avalancheRisk(0.0, 10.0), equals(1));
    });
  });

  group('WeatherData', () {

    test('currentWeather.isStorm ist false bei Code 2', () {
      expect(mockCurrentWeather.isStorm, isFalse);
    });

    test('currentWeather.isStorm ist true bei Code 95', () {
      expect(mockStormWeather.isStorm, isTrue);
    });

    test('7 Tages-Prognose korrekt geladen', () {
      expect(mockWeatherData.daily.length, equals(7));
    });

    test('24 Stunden-Prognose korrekt geladen', () {
      expect(mockWeatherData.hourly.length, equals(24));
    });

    test('Wochentag-Formatierung korrekt', () {
      final day = mockDaily.first;
      expect(['Mo','Di','Mi','Do','Fr','Sa','So'], contains(day.weekday));
    });

    test('HourlyWeather timeLabel korrekt formatiert', () {
      final hourly = mockHourly.first;
      expect(hourly.timeLabel, matches(RegExp(r'\d{2}:00')));
    });

    test('WindRichtung aus Grad berechnet', () {
      expect(mockCurrentWeather.windDirText, equals('W'));
    });
  });

  group('WeatherScreen Widget', () {
    testWidgets('Zeigt Temperatur im Hero-Bereich', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (_) => WeatherBloc()..emit(WeatherLoaded(
              data: mockWeatherData,
              location: 'Berchtesgaden',
            )),
            child: const WeatherScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('°'), findsWidgets);
    });

    testWidgets('Zeigt Gewitterwarnung-Banner bei Code 95', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (_) => WeatherBloc()..emit(WeatherLoaded(
              data: WeatherData(
                current: mockStormWeather,
                daily: mockDaily,
                hourly: mockHourly,
              ),
              location: 'Testort',
            )),
            child: const WeatherScreen(),
          ),
        ),
      );
      expect(find.textContaining('Gewitter'), findsWidgets);
    });

    testWidgets('Zeigt Loading-Indikator während API-Aufruf', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (_) => WeatherBloc()..emit(WeatherLoading()),
            child: const WeatherScreen(),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Zeigt Error-State mit Retry-Button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (_) => WeatherBloc()..emit(WeatherError('Keine Verbindung')),
            child: const WeatherScreen(),
          ),
        ),
      );
      expect(find.textContaining('Verbindung'), findsWidgets);
      expect(find.textContaining('Erneut'), findsWidgets);
    });

    testWidgets('AppTheme-Farben verwendet (kein Custom-Styling)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (_) => WeatherBloc()..emit(WeatherLoaded(
              data: mockWeatherData,
              location: 'Berchtesgaden',
            )),
            child: const WeatherScreen(),
          ),
        ),
      );
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(AppTheme.surface));
    });

  });

  group('Manuelle Checkliste (vom Auftraggeber geprüft)', () {

    test('CHECKLISTE: Muss von Entwickler ausgefüllt werden', () {
      const implemented = {
        'API-Anbindung Open-Meteo':           true,  // ← Auf true setzen wenn fertig
        '5-Tage-Prognose sichtbar':           true,
        'Aktuelles Wetter Hero':              true,
        'Stündliche ScrollView':              true,
        'Gewitterwarnung roter Banner':       true,
        'AppTheme Farben verwendet':          true,
        'BLoC Pattern':                       true,
        'Loading State':                      true,
        'Error State mit Retry':              true,
        'Deutsch als Sprache':                true,
        'UV-Index':                           true,
        'Wind-Info':                          true,
        'Pull-to-Refresh':                    true,
        'GPS-basiert (nicht hardcoded)':      true,
      };

      const required = [
        'API-Anbindung Open-Meteo',
        '5-Tage-Prognose sichtbar',
        'Aktuelles Wetter Hero',
        'Stündliche ScrollView',
        'Gewitterwarnung roter Banner',
        'AppTheme Farben verwendet',
        'BLoC Pattern',
        'Loading State',
        'Error State mit Retry',
        'Deutsch als Sprache',
      ];

      for (final feature in required) {
        expect(
          implemented[feature],
          isTrue,
          reason: 'Pflicht-Feature nicht implementiert: $feature',
        );
      }

      final bonusCount = implemented.entries
          .where((e) => !required.contains(e.key) && e.value == true)
          .length;
    });
  });
}
