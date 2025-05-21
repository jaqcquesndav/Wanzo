import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../auth/models/user.dart'; // This import provides the correct IdStatus
import '../../auth/bloc/auth_bloc.dart';
import '../../../core/services/file_storage_service.dart'; 

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _jobTitleController;
  late TextEditingController _physicalAddressController;
  late TextEditingController _idCardController;
  late TextEditingController _idCardStatusReasonController; // New controller
  late IdStatus _selectedIdStatus; // To hold the selected ID status, non-nullable

  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();
  final FileStorageService _storageService = FileStorageService(); // Instantiate the service
  bool _isSaving = false; // To track saving state

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _jobTitleController = TextEditingController(text: widget.user.jobTitle);
    _physicalAddressController = TextEditingController(text: widget.user.physicalAddress);
    _idCardController = TextEditingController(text: widget.user.idCard);
    _selectedIdStatus = widget.user.idCardStatus; // Initialize status
    _idCardStatusReasonController = TextEditingController(text: widget.user.idCardStatusReason); // Initialize reason
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _physicalAddressController.dispose();
    _idCardController.dispose();
    _idCardStatusReasonController.dispose(); // Dispose new controller
    super.dispose();
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (!mounted) return;
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Rogner l\'image',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square, // Can keep this for initial view
              lockAspectRatio: false // Ensure this is false to allow free cropping
            ),
          IOSUiSettings(
            title: 'Rogner l\'image',
            minimumAspectRatio: 1.0, // Can be kept or removed
            aspectRatioLockEnabled: false, // Ensure this is false for free cropping
            resetAspectRatioEnabled: true, // Allow resetting
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _profileImageFile = File(croppedFile.path);
        });
      }
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickAndCropImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickAndCropImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    String? newImageUrl;
    if (_profileImageFile != null) {
      newImageUrl = await _storageService.uploadProfileImage(
          _profileImageFile!, widget.user.id);
      if (newImageUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec du téléchargement de l\'image. Veuillez réessayer.')),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }
    }

    User updatedUser = widget.user.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      jobTitle: _jobTitleController.text,
      physicalAddress: _physicalAddressController.text,
      idCard: _idCardController.text,
      idCardStatus: _selectedIdStatus,
      idCardStatusReason: _idCardStatusReasonController.text,
      picture: newImageUrl ?? widget.user.picture,
    );

    if (mounted) {
      context.read<AuthBloc>().add(AuthUserProfileUpdated(updatedUser, profileImageFile: _profileImageFile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le Profil'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthProfileUpdateSuccess) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil mis à jour avec succès!')),
              );
              Navigator.of(context).pop(state.user);
            }
          } else if (state is AuthProfileUpdateFailure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Échec de la mise à jour du profil: ${state.error}')),
              );
              setState(() {
                _isSaving = false;
              });
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                      backgroundImage: _profileImageFile != null
                          ? FileImage(_profileImageFile!)
                          : (widget.user.picture != null && widget.user.picture!.isNotEmpty
                              ? NetworkImage(widget.user.picture!)
                              : null) as ImageProvider?,
                      child: (_profileImageFile == null && (widget.user.picture == null || widget.user.picture!.isEmpty))
                          ? Text(
                              widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontSize: 50,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
                      onPressed: () => _showImagePickerOptions(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Nom complet'),
              _buildTextField(_emailController, 'Adresse e-mail', keyboardType: TextInputType.emailAddress),
              _buildTextField(_phoneController, 'Téléphone', keyboardType: TextInputType.phone),
              _buildTextField(_jobTitleController, 'Fonction dans l\'entreprise'),
              _buildTextField(_physicalAddressController, 'Adresse physique'),
              _buildTextField(_idCardController, 'Pièce d\'identité (ex: NINA, Passeport)'),
              const SizedBox(height: 16),
              _buildIdStatusDropdown(),
              const SizedBox(height: 8),
              _buildTextField(_idCardStatusReasonController, 'Raison du statut (si applicable)'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)) 
                    : const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<IdStatus>(
        decoration: InputDecoration(
          labelText: 'Statut de la pièce d\'identité',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        value: _selectedIdStatus,
        items: IdStatus.values.map((IdStatus status) {
          return DropdownMenuItem<IdStatus>(
            value: status,
            child: Text(status.toString().split('.').last),
          );
        }).toList(),
        onChanged: (IdStatus? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedIdStatus = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
