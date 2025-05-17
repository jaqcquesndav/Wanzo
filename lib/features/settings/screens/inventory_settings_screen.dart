import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../models/settings.dart';

/// Écran des paramètres d'inventaire
class InventorySettingsScreen extends StatefulWidget {
  /// Paramètres actuels
  final Settings settings;

  const InventorySettingsScreen({super.key, required this.settings});

  @override
  State<InventorySettingsScreen> createState() => _InventorySettingsScreenState();
}

class _InventorySettingsScreenState extends State<InventorySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _defaultCategoryController;
  late final TextEditingController _lowStockDaysController;
  
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Initialise les contrôleurs avec les valeurs actuelles
    _defaultCategoryController = TextEditingController(text: widget.settings.defaultProductCategory);
    _lowStockDaysController = TextEditingController(text: widget.settings.lowStockAlertDays.toString());
    
    // Écouteurs pour détecter les changements
    _defaultCategoryController.addListener(_onFieldChanged);
    _lowStockDaysController.addListener(_onFieldChanged);
  }
  
  @override
  void dispose() {
    _defaultCategoryController.dispose();
    _lowStockDaysController.dispose();
    super.dispose();
  }
  
  /// Détecte les changements dans les champs
  void _onFieldChanged() {
    final hasChanges = 
        _defaultCategoryController.text != widget.settings.defaultProductCategory ||
        _lowStockDaysController.text != widget.settings.lowStockAlertDays.toString();
    
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
        title: const Text('Paramètres d\'inventaire'),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paramètres généraux',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Catégorie par défaut
                TextFormField(
                  controller: _defaultCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie de produit par défaut',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La catégorie par défaut est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                const Divider(),
                const SizedBox(height: 16),
                
                const Text(
                  'Alertes de stock',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Jours pour alerte de stock bas
                TextFormField(
                  controller: _lowStockDaysController,
                  decoration: const InputDecoration(
                    labelText: 'Jours pour les alertes de stock bas',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warning),
                    hintText: 'Ex: 7 jours',
                    suffixText: 'jours',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ce champ est obligatoire';
                    }
                    try {
                      final days = int.parse(value);
                      if (days < 1) {
                        return 'Minimum 1 jour requis';
                      }
                      if (days > 90) {
                        return 'Maximum 90 jours autorisés';
                      }
                    } catch (_) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Cette valeur définit combien de jours à l\'avance vous souhaitez être alerté lorsque le stock d\'un produit est sur le point d\'être épuisé.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
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
      ),
    );
  }

  /// Enregistre les modifications
  void _saveSettings() {
    if (_formKey.currentState?.validate() ?? false) {
      int lowStockDays;
      try {
        lowStockDays = int.parse(_lowStockDaysController.text);
      } catch (_) {
        lowStockDays = widget.settings.lowStockAlertDays;
      }
      
      context.read<SettingsBloc>().add(UpdateInventorySettings(
        defaultProductCategory: _defaultCategoryController.text.trim(),
        lowStockAlertDays: lowStockDays,
      ));
    }
  }
}
