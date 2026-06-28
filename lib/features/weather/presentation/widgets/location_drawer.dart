import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/weather_storage.dart';
import '../bloc/weather_bloc.dart';

class LocationDrawer extends StatefulWidget {
  const LocationDrawer({super.key});

  @override
  State<LocationDrawer> createState() => _LocationDrawerState();
}

class _LocationDrawerState extends State<LocationDrawer> {
  List<SavedLocation> _locations = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locs = await WeatherStorage.loadLocations();
    if (mounted) setState(() => _locations = locs);
  }

  void _selectCurrentLocation() {
    Navigator.pop(context);
    context.read<WeatherBloc>().add(const WeatherLocationRequested());
  }

  void _selectSavedLocation(SavedLocation loc) {
    Navigator.pop(context);
    context.read<WeatherBloc>().add(WeatherSavedLocationSelected(
      name: loc.name,
      lat:  loc.lat,
      lon:  loc.lon,
    ));
  }

  Future<void> _saveCurrentLocation() async {
    final state = context.read<WeatherBloc>().state;
    if (state is! WeatherLoaded || state.lat == null || state.lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein Standort verfügbar.')),
      );
      return;
    }
    final loc = SavedLocation(
      id:   '${state.lat!.toStringAsFixed(3)}_${state.lon!.toStringAsFixed(3)}',
      name: state.location,
      lat:  state.lat!,
      lon:  state.lon!,
    );
    await WeatherStorage.saveLocation(loc);
    await _loadLocations();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${state.location} gespeichert.')),
      );
    }
  }

  Future<void> _showAddDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => const _AddLocationDialog(),
    );

    if (name == null || name.isEmpty) return;
    await _geocodeAndAdd(name);
  }

  Future<void> _geocodeAndAdd(String name) async {
    setState(() => _isSearching = true);
    try {
      final results = await locationFromAddress(name)
          .timeout(const Duration(seconds: 10));
      if (results.isEmpty) throw Exception();

      final loc = SavedLocation(
        id:   '${results.first.latitude.toStringAsFixed(3)}_${results.first.longitude.toStringAsFixed(3)}',
        name: name,
        lat:  results.first.latitude,
        lon:  results.first.longitude,
      );
      await WeatherStorage.saveLocation(loc);
      await _loadLocations();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$name" wurde nicht gefunden. Bitte überprüfen Sie den Namen.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _deleteLocation(String id) async {
    await WeatherStorage.removeLocation(id);
    await _loadLocations();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ────────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AlpenExplorer',
                    style: textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Meine Orte',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.my_location, color: AppTheme.primary),
              title: Text('Aktueller Standort', style: textTheme.titleMedium),
              onTap: _selectCurrentLocation,
            ),
            BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) {
                if (state is! WeatherLoaded || state.lat == null) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 72, right: 16, bottom: 4),
                  child: TextButton.icon(
                    onPressed: _saveCurrentLocation,
                    icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                    label: Text(
                      '${state.location} speichern',
                      style: textTheme.bodySmall?.copyWith(color: AppTheme.primary),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: _isSearching
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_location_alt_outlined,
                      color: AppTheme.secondary),
              title: Text(
                _isSearching ? 'Suche läuft...' : 'Ort hinzufügen',
                style: textTheme.titleMedium?.copyWith(color: AppTheme.secondary),
              ),
              onTap: _isSearching ? null : _showAddDialog,
            ),

            const Divider(height: 0),
            if (_locations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'GESPEICHERTE ORTE',
                  style: textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.0,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
            Expanded(
              child: _locations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_off_outlined,
                              size: 40, color: AppTheme.textMuted),
                          const SizedBox(height: 8),
                          Text('Keine gespeicherten Orte',
                              style: textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text('Tippen Sie auf „Ort hinzufügen"',
                              style: textTheme.bodySmall),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _locations.length,
                      itemBuilder: (context, i) {
                        final loc = _locations[i];
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          title: Text(loc.name, style: textTheme.titleMedium),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: AppTheme.textMuted),
                            onPressed: () => _deleteLocation(loc.id),
                          ),
                          onTap: () => _selectSavedLocation(loc),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
class _AddLocationDialog extends StatefulWidget {
  const _AddLocationDialog();

  @override
  State<_AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<_AddLocationDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ort hinzufügen'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'z. B. München, Wien, Innsbruck',
          prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Suchen'),
        ),
      ],
    );
  }
}
