import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/weather_storage.dart';
import '../bloc/locations_cubit.dart';
import '../bloc/weather_bloc.dart';

class LocationDrawer extends StatelessWidget {
  const LocationDrawer({super.key});

  void _selectCurrentLocation(BuildContext context) {
    Navigator.pop(context);
    context.read<WeatherBloc>().add(const WeatherLocationRequested());
  }

  void _selectSavedLocation(BuildContext context, SavedLocation loc) {
    Navigator.pop(context);
    context.read<WeatherBloc>().add(WeatherSavedLocationSelected(
      name: loc.name,
      lat:  loc.lat,
      lon:  loc.lon,
    ));
  }

  void _saveCurrentLocation(BuildContext context) {
    final weatherState = context.read<WeatherBloc>().state;
    if (weatherState is! WeatherLoaded ||
        weatherState.lat == null ||
        weatherState.lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kein Standort verfügbar.')),
      );
      return;
    }
    context.read<LocationsCubit>().saveCurrentLocation(
      weatherState.location,
      weatherState.lat!,
      weatherState.lon!,
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => const _AddLocationDialog(),
    );
    if (name == null || name.isEmpty) return;
    if (context.mounted) {
      context.read<LocationsCubit>().addByName(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<LocationsCubit, LocationsState>(
      listenWhen: (prev, curr) =>
          (curr.error   != null && curr.error   != prev.error) ||
          (curr.message != null && curr.message != prev.message),
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        } else if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
      },
      builder: (context, locState) {
        return Drawer(
          backgroundColor: AppTheme.surface,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ────────────────────────────────────────────────────
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
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── GPS-Standort ──────────────────────────────────────────────
                ListTile(
                  leading: const Icon(Icons.my_location, color: AppTheme.primary),
                  title: Text('Aktueller Standort', style: textTheme.titleMedium),
                  onTap: () => _selectCurrentLocation(context),
                ),

                // Save current location button (reads from WeatherBloc)
                BlocBuilder<WeatherBloc, WeatherState>(
                  builder: (context, weatherState) {
                    if (weatherState is! WeatherLoaded ||
                        weatherState.lat == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 72, right: 16, bottom: 4),
                      child: TextButton.icon(
                        onPressed: () => _saveCurrentLocation(context),
                        icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                        label: Text(
                          '${weatherState.location} speichern',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppTheme.primary),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    );
                  },
                ),

                // ── Ort hinzufügen ────────────────────────────────────────────
                ListTile(
                  leading: locState.isSearching
                      ? const SizedBox(
                          width:  24,
                          height: 24,
                          child:  CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_location_alt_outlined,
                          color: AppTheme.secondary),
                  title: Text(
                    locState.isSearching ? 'Suche läuft...' : 'Ort hinzufügen',
                    style: textTheme.titleMedium
                        ?.copyWith(color: AppTheme.secondary),
                  ),
                  onTap: locState.isSearching
                      ? null
                      : () => _showAddDialog(context),
                ),

                const Divider(height: 0),

                // ── Liste gespeicherter Orte ──────────────────────────────────
                if (locState.locations.isNotEmpty)
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
                  child: locState.locations.isEmpty
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
                          itemCount: locState.locations.length,
                          itemBuilder: (context, i) {
                            final loc = locState.locations[i];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_on_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              title: Text(loc.name,
                                  style: textTheme.titleMedium),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 20, color: AppTheme.textMuted),
                                onPressed: () => context
                                    .read<LocationsCubit>()
                                    .removeLocation(loc.id),
                              ),
                              onTap: () =>
                                  _selectSavedLocation(context, loc),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Dialog zum Hinzufügen eines Ortes ─────────────────────────────────────────
// Owns the TextEditingController so dispose() runs after focus cleanup, not before.
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
