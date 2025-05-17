import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../models/settings.dart';

/// Écran de paramètres pour les informations de l'entreprise
class CompanySettingsScreen extends StatefulWidget {
  /// Paramètres actuels
  final Settings settings;

  const CompanySettingsScreen({super.key, required this.settings});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final _formKeyCompany = GlobalKey<FormState>();
  late final TextEditingController _companyNameController;
  late final TextEditingController _companyAddressController;
  late final TextEditingController _companyPhoneController;
  late final TextEditingController _companyEmailController;
  late final TextEditingController _taxNumberController;
  late final TextEditingController _rccmNumberController;
  late final TextEditingController _idNatNumberController;
  
  String? _companyLogo;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    
    // Initialise les contrôleurs avec les valeurs actuelles
    _companyNameController = TextEditingController(text: widget.settings.companyName);
    _companyAddressController = TextEditingController(text: widget.settings.companyAddress);
    _companyPhoneController = TextEditingController(text: widget.settings.companyPhone);
    _companyEmailController = TextEditingController(text: widget.settings.companyEmail);
    _taxNumberController = TextEditingController(text: widget.settings.taxIdentificationNumber);
    _rccmNumberController = TextEditingController(text: widget.settings.rccmNumber);
    _idNatNumberController = TextEditingController(text: widget.settings.idNatNumber);
    
    _companyLogo = widget.settings.companyLogo;
    
    // Écouteurs pour détecter les changements
    _companyNameController.addListener(_onFieldChanged);
    _companyAddressController.addListener(_onFieldChanged);
    _companyPhoneController.addListener(_onFieldChanged);
    _companyEmailController.addListener(_onFieldChanged);
    _taxNumberController.addListener(_onFieldChanged);
    _rccmNumberController.addListener(_onFieldChanged);
    _idNatNumberController.addListener(_onFieldChanged);
  }
  
  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    _companyEmailController.dispose();
    _taxNumberController.dispose();
    _rccmNumberController.dispose();
    _idNatNumberController.dispose();
    super.dispose();
  }
  
  /// Détecte les changements dans les champs
  void _onFieldChanged() {
    final hasChanges = 
        _companyNameController.text != widget.settings.companyName ||
        _companyAddressController.text != widget.settings.companyAddress ||
        _companyPhoneController.text != widget.settings.companyPhone ||
        _companyEmailController.text != widget.settings.companyEmail ||
        _taxNumberController.text != widget.settings.taxIdentificationNumber ||
        _rccmNumberController.text != widget.settings.rccmNumber ||
        _idNatNumberController.text != widget.settings.idNatNumber ||
        _companyLogo != widget.settings.companyLogo;
    
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
        title: const Text('Informations de l\'entreprise'),
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
            key: _formKeyCompany,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo de l'entreprise
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          image: _companyLogo != null && _companyLogo!.isNotEmpty
                              ? DecorationImage(
                                  image: _getImageProvider(_companyLogo!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _companyLogo == null || _companyLogo!.isEmpty
                            ? const Icon(
                                Icons.business,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _selectLogo,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Changer le logo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Nom de l'entreprise
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'entreprise *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom de l\'entreprise est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Adresse
                TextFormField(
                  controller: _companyAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Téléphone
                TextFormField(
                  controller: _companyPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                // Email
                TextFormField(
                  controller: _companyEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Numéro d'identification fiscale
                TextFormField(
                  controller: _taxNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro d\'identification fiscale',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.receipt),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Numéro RCCM
                TextFormField(
                  controller: _rccmNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro RCCM',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                    helperText: 'Registre du Commerce et du Crédit Mobilier',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Numéro ID NAT
                TextFormField(
                  controller: _idNatNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro ID NAT',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.assignment_ind),
                    helperText: 'Identification Nationale',
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

  /// Retourne le provider d'image approprié selon le chemin
  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }

  /// Sélectionne un logo depuis la galerie ou la caméra
  Future<void> _selectLogo() async {
    try {
      // Afficher un dialogue pour choisir la source de l'image
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sélectionner une source'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galerie'),
                    onTap: () {
                      Navigator.of(context).pop(ImageSource.gallery);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Caméra'),
                    onTap: () {
                      Navigator.of(context).pop(ImageSource.camera);
                    },
                  ),
                  if (_companyLogo != null && _companyLogo!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Supprimer le logo actuel'),
                      onTap: () {
                        Navigator.of(context).pop(null);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      );
      
      // Si l'utilisateur a choisi de supprimer le logo
      if (source == null) {
        setState(() {
          _companyLogo = '';
          _hasChanges = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo supprimé')),
        );
        return;
      }
      
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
      
      if (pickedFile == null) return;
      
      // Obtenir le répertoire des documents de l'application
      final appDir = await getApplicationDocumentsDirectory();
      final companyLogosDir = Directory('${appDir.path}/company_logos');
      
      // Créer le répertoire s'il n'existe pas
      if (!await companyLogosDir.exists()) {
        await companyLogosDir.create(recursive: true);
      }
      
      // Générer un nom de fichier unique basé sur l'horodatage
      final fileName = 'company_logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImagePath = path.join(companyLogosDir.path, fileName);
      
      // Copier l'image sélectionnée vers le répertoire de l'application
      await File(pickedFile.path).copy(savedImagePath);
      
      setState(() {
        _companyLogo = savedImagePath;
        _hasChanges = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logo mis à jour avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection du logo: $e')),
      );
    }
  }

  /// Enregistre les modifications
  void _saveSettings() {
    if (_formKeyCompany.currentState?.validate() ?? false) {
      context.read<SettingsBloc>().add(UpdateCompanyInfo(
        companyName: _companyNameController.text.trim(),
        companyAddress: _companyAddressController.text.trim(),
        companyPhone: _companyPhoneController.text.trim(),
        companyEmail: _companyEmailController.text.trim(),
        companyLogo: _companyLogo,
        taxIdentificationNumber: _taxNumberController.text.trim(),
        rccmNumber: _rccmNumberController.text.trim(),
        idNatNumber: _idNatNumberController.text.trim(),
      ));
    }
  }
}
