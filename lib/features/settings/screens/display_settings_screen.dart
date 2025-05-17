import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../models/settings.dart';

/// Écran des paramètres d'affichage
class DisplaySettingsScreen extends StatefulWidget {
  /// Paramètres actuels
  final Settings settings;

  const DisplaySettingsScreen({super.key, required this.settings});

  @override
  State<DisplaySettingsScreen> createState() => _DisplaySettingsScreenState();
}

class _DisplaySettingsScreenState extends State<DisplaySettingsScreen> {
  AppThemeMode _themeMode = AppThemeMode.system;
  String _language = 'fr';
  String _dateFormat = 'DD/MM/YYYY';
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Initialise les valeurs avec les paramètres actuels
    _themeMode = widget.settings.themeMode;
    _language = widget.settings.language;
    _dateFormat = widget.settings.dateFormat;
  }
  
  /// Vérifie si des changements ont été effectués
  void _checkChanges() {
    final hasChanges = 
        _themeMode != widget.settings.themeMode ||
        _language != widget.settings.language ||
        _dateFormat != widget.settings.dateFormat;
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apparence et affichage'),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: 'Enregistrer',
            ),
        ],
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            setState(() {
              _hasChanges = false;
            });
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thème',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Sélection du thème
              Card(
                child: Column(
                  children: [
                    RadioListTile<AppThemeMode>(
                      title: const Text('Clair'),
                      value: AppThemeMode.light,
                      groupValue: _themeMode,
                      onChanged: (value) {
                        setState(() {
                          _themeMode = AppThemeMode.light;
                          _checkChanges();
                        });
                      },
                      secondary: const Icon(Icons.light_mode),
                    ),
                    RadioListTile<AppThemeMode>(
                      title: const Text('Sombre'),
                      value: AppThemeMode.dark,
                      groupValue: _themeMode,
                      onChanged: (value) {
                        setState(() {
                          _themeMode = AppThemeMode.dark;
                          _checkChanges();
                        });
                      },
                      secondary: const Icon(Icons.dark_mode),
                    ),
                    RadioListTile<AppThemeMode>(
                      title: const Text('Système'),
                      value: AppThemeMode.system,
                      groupValue: _themeMode,
                      onChanged: (value) {
                        setState(() {
                          _themeMode = AppThemeMode.system;
                          _checkChanges();
                        });
                      },
                      secondary: const Icon(Icons.brightness_auto),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Langue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Sélection de la langue
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Français'),
                      value: 'fr',
                      groupValue: _language,
                      onChanged: (value) {
                        setState(() {
                          _language = 'fr';
                          _checkChanges();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Anglais'),
                      value: 'en',
                      groupValue: _language,
                      onChanged: (value) {
                        setState(() {
                          _language = 'en';
                          _checkChanges();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Swahili'),
                      value: 'sw',
                      groupValue: _language,
                      onChanged: (value) {
                        setState(() {
                          _language = 'sw';
                          _checkChanges();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Format de date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Sélection du format de date
              Card(
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('DD/MM/YYYY'),
                      subtitle: Text(_getFormattedDateExample('DD/MM/YYYY')),
                      value: 'DD/MM/YYYY',
                      groupValue: _dateFormat,
                      onChanged: (value) {
                        setState(() {
                          _dateFormat = 'DD/MM/YYYY';
                          _checkChanges();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('MM/DD/YYYY'),
                      subtitle: Text(_getFormattedDateExample('MM/DD/YYYY')),
                      value: 'MM/DD/YYYY',
                      groupValue: _dateFormat,
                      onChanged: (value) {
                        setState(() {
                          _dateFormat = 'MM/DD/YYYY';
                          _checkChanges();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('YYYY-MM-DD'),
                      subtitle: Text(_getFormattedDateExample('YYYY-MM-DD')),
                      value: 'YYYY-MM-DD',
                      groupValue: _dateFormat,
                      onChanged: (value) {
                        setState(() {
                          _dateFormat = 'YYYY-MM-DD';
                          _checkChanges();
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('DD MMM YYYY'),
                      subtitle: Text(_getFormattedDateExample('DD MMM YYYY')),
                      value: 'DD MMM YYYY',
                      groupValue: _dateFormat,
                      onChanged: (value) {
                        setState(() {
                          _dateFormat = 'DD MMM YYYY';
                          _checkChanges();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Bouton d'enregistrement
              if (_hasChanges)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Enregistrer les modifications'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtient un exemple de date formatée
  String _getFormattedDateExample(String format) {
    final now = DateTime.now();
    
    switch (format) {
      case 'DD/MM/YYYY':
        return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      case 'MM/DD/YYYY':
        return '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
      case 'YYYY-MM-DD':
        return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      case 'DD MMM YYYY':
        final months = [
          '', 'Jan', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin',
          'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'
        ];
        return '${now.day.toString().padLeft(2, '0')} ${months[now.month]} ${now.year}';
      default:
        return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    }
  }

  /// Enregistre les modifications
  void _saveSettings() {
    context.read<SettingsBloc>().add(UpdateDisplaySettings(
      themeMode: _themeMode,
      language: _language,
      dateFormat: _dateFormat,
    ));
  }
}
