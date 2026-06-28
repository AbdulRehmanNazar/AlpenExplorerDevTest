import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alpenexplorer/core/theme/app_theme.dart';
import 'package:alpenexplorer/features/weather/data/weather_service_stub.dart';
import 'package:alpenexplorer/features/weather/presentation/widgets/storm_warning.dart';
import 'package:alpenexplorer/features/weather/presentation/widgets/weather_hero.dart';
import 'package:alpenexplorer/features/weather/presentation/widgets/daily_forecast.dart';
import 'package:alpenexplorer/features/weather/presentation/widgets/hourly_scroll.dart';

CurrentWeather _makeWeather({
  double temperature = 22.5,
  double apparentTemp = 21.0,
  int weatherCode = 1,
  double windSpeed = 8.0,
  double windDirection = 270.0,
  double humidity = 55.0,
  double precipitation = 0.0,
}) => CurrentWeather(
  temperature: temperature,
  apparentTemp: apparentTemp,
  weatherCode: weatherCode,
  windSpeed: windSpeed,
  windDirection: windDirection,
  humidity: humidity,
  precipitation: precipitation,
);

DailyWeather _makeDay(
  int offsetDays, {
  double maxTemp = 25.0,
  double minTemp = 12.0,
}) => DailyWeather(
  date: DateTime.now().add(Duration(days: offsetDays)),
  weatherCode: 1,
  maxTemp: maxTemp,
  minTemp: minTemp,
  precipitationSum: 0.0,
  uvIndex: 5.0,
  sunrise: '06:00',
  sunset: '21:00',
);

HourlyWeather _makeHour(int hour) => HourlyWeather(
  time: DateTime.now().copyWith(hour: hour),
  temperature: 20.0 + hour * 0.3,
  precipitationProbability: 0,
  weatherCode: 1,
);

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('StormWarningBanner Widget', () {
    testWidgets('zeigt Gewitterwarnung-Text an', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StormWarningBanner())),
      );
      expect(find.textContaining('Gewitterwarnung'), findsOneWidget);
    });

    testWidgets('hat roten Hintergrund', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StormWarningBanner())),
      );
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.any((c) => c.color == Colors.red.shade700), isTrue);
    });

    testWidgets('zeigt Warn-Emoji an', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StormWarningBanner())),
      );
      expect(find.textContaining('⚠'), findsWidgets);
    });
  });

  group('WeatherHero Widget', () {
    testWidgets('zeigt Standort an', (tester) async {
      await tester.pumpWidget(
        _wrap(WeatherHero(weather: _makeWeather(), location: 'Berchtesgaden')),
      );
      expect(find.text('Berchtesgaden'), findsOneWidget);
    });

    testWidgets('zeigt Temperatur in °C an', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WeatherHero(
            weather: _makeWeather(temperature: 22.5),
            location: 'Test',
          ),
        ),
      );
      expect(find.textContaining('22.5°C'), findsOneWidget);
    });

    testWidgets('zeigt gefühlte Temperatur an', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WeatherHero(
            weather: _makeWeather(apparentTemp: 21.0),
            location: 'Test',
          ),
        ),
      );
      expect(find.textContaining('Gefühlt'), findsOneWidget);
      expect(find.textContaining('21.0'), findsWidgets);
    });

    testWidgets('zeigt Wind-Label an', (tester) async {
      await tester.pumpWidget(
        _wrap(WeatherHero(weather: _makeWeather(), location: 'Test')),
      );
      expect(find.text('Wind'), findsOneWidget);
    });

    testWidgets('zeigt Luftfeuchte-Label an', (tester) async {
      await tester.pumpWidget(
        _wrap(WeatherHero(weather: _makeWeather(), location: 'Test')),
      );
      expect(find.text('Luftfeuchte'), findsOneWidget);
    });

    testWidgets('zeigt Niederschlag-Label an', (tester) async {
      await tester.pumpWidget(
        _wrap(WeatherHero(weather: _makeWeather(), location: 'Test')),
      );
      expect(find.text('Niederschlag'), findsOneWidget);
    });

    testWidgets('zeigt Windrichtung W bei 270 Grad', (tester) async {
      await tester.pumpWidget(
        _wrap(
          WeatherHero(
            weather: _makeWeather(windDirection: 270),
            location: 'Test',
          ),
        ),
      );
      expect(find.textContaining('W'), findsWidgets);
    });
  });

  group('DailyForecast Widget', () {
    testWidgets('zeigt Abschnitts-Überschrift an', (tester) async {
      await tester.pumpWidget(_wrap(DailyForecast(days: [_makeDay(0)])));
      expect(find.text('5-Tage-Prognose'), findsOneWidget);
    });

    testWidgets('zeigt Max-Temperatur an', (tester) async {
      await tester.pumpWidget(
        _wrap(DailyForecast(days: [_makeDay(0, maxTemp: 28.0, minTemp: 14.0)])),
      );
      expect(find.textContaining('28'), findsWidgets);
    });

    testWidgets('zeigt Min-Temperatur an', (tester) async {
      await tester.pumpWidget(
        _wrap(DailyForecast(days: [_makeDay(0, maxTemp: 28.0, minTemp: 14.0)])),
      );
      expect(find.textContaining('14'), findsWidgets);
    });

    testWidgets('zeigt UV-Badge an', (tester) async {
      await tester.pumpWidget(_wrap(DailyForecast(days: [_makeDay(0)])));
      expect(find.textContaining('UV'), findsWidgets);
    });

    testWidgets('4 Trennlinien zwischen 5 Tages-Einträgen', (tester) async {
      final days = List.generate(5, (i) => _makeDay(i));
      await tester.pumpWidget(_wrap(DailyForecast(days: days)));
      expect(find.byType(Divider), findsNWidgets(4));
    });

    testWidgets('begrenzt auf 5 Tage auch wenn mehr übergeben', (tester) async {
      final days = List.generate(10, (i) => _makeDay(i));
      await tester.pumpWidget(_wrap(DailyForecast(days: days)));
      expect(find.byType(Divider), findsNWidgets(4));
    });
  });

  group('HourlyScroll Widget', () {
    testWidgets('zeigt Abschnitts-Überschrift an', (tester) async {
      await tester.pumpWidget(_wrap(HourlyScroll(hours: [_makeHour(12)])));
      expect(find.text('Stündliche Prognose'), findsOneWidget);
    });

    testWidgets('zeigt Stunden-Label im HH:00-Format', (tester) async {
      await tester.pumpWidget(_wrap(HourlyScroll(hours: [_makeHour(8)])));
      expect(find.textContaining('08:00'), findsWidgets);
    });

    testWidgets('zeigt Temperaturwert in Grad an', (tester) async {
      await tester.pumpWidget(_wrap(HourlyScroll(hours: [_makeHour(10)])));
      expect(find.textContaining('°'), findsWidgets);
    });
  });

  group('WeatherService – Grenzfälle', () {
    test('WMO Code 45 → Neblig', () {
      expect(
        WeatherService.fromCode(45).description.toLowerCase(),
        contains('neblig'),
      );
    });

    test('WMO Code 77 → Eiskörnchen', () {
      expect(
        WeatherService.fromCode(77).description.toLowerCase(),
        contains('eis'),
      );
    });

    test('WMO unbekannter Code → Unbekannt', () {
      expect(WeatherService.fromCode(999).description, equals('Unbekannt'));
    });

    test('UV-Index 11 → Extrem', () {
      expect(WeatherService.uvDescription(11.0), equals('Extrem'));
    });

    test('UV-Index 6 → Hoch', () {
      expect(WeatherService.uvDescription(6.0), equals('Hoch'));
    });

    test('UV-Index 3 → Mäßig', () {
      expect(WeatherService.uvDescription(3.0), equals('Mäßig'));
    });

    test('UV-Farbe: extrem → A32D2D', () {
      expect(WeatherService.uvColor(11.0), equals('A32D2D'));
    });

    test('UV-Farbe: niedrig → 1D9E75', () {
      expect(WeatherService.uvColor(1.0), equals('1D9E75'));
    });

    test('isStormWarning: Code 96 → true', () {
      expect(WeatherService.isStormWarning(96), isTrue);
    });

    test('isStormWarning: Code 94 → false', () {
      expect(WeatherService.isStormWarning(94), isFalse);
    });

    test('Lawinenrisiko: starker Wind ohne viel Schnee → 3', () {
      expect(WeatherService.avalancheRisk(5.0, 45.0), equals(3));
    });

    test('Lawinenrisiko: mittlerer Schneefall → 2', () {
      expect(WeatherService.avalancheRisk(15.0, 20.0), equals(2));
    });
  });

  group('Windrichtung – alle Himmelsrichtungen', () {
    CurrentWeather dir(double deg) => _makeWeather(windDirection: deg);

    test('0°   → N', () => expect(dir(0).windDirText, equals('N')));
    test('45°  → NO', () => expect(dir(45).windDirText, equals('NO')));
    test('90°  → O', () => expect(dir(90).windDirText, equals('O')));
    test('135° → SO', () => expect(dir(135).windDirText, equals('SO')));
    test('180° → S', () => expect(dir(180).windDirText, equals('S')));
    test('225° → SW', () => expect(dir(225).windDirText, equals('SW')));
    test('270° → W', () => expect(dir(270).windDirText, equals('W')));
    test('315° → NW', () => expect(dir(315).windDirText, equals('NW')));
    test('360° → N', () => expect(dir(360).windDirText, equals('N')));
  });
}
