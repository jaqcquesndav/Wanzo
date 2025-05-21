import 'dart:io'; // Import for File type

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:image_cropper/image_cropper.dart'; // Import image_cropper
import '../../../core/shared_widgets/wanzo_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/models/user.dart';
import 'edit_profile_screen.dart'; // Import EditProfileScreen

class ProfileScreen extends StatefulWidget { // Changed to StatefulWidget
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(); // Create state
}

class _ProfileScreenState extends State<ProfileScreen> { // State class
  File? _profileImageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Rogner l\'image',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original, // Can keep this for initial view
              lockAspectRatio: false // Ensure this is false to allow free cropping
            ),
          IOSUiSettings(
            title: 'Rogner l\'image',
            minimumAspectRatio: 1.0, // Can be kept or removed
            aspectRatioLockEnabled: false, // Ensure this is false
            resetAspectRatioEnabled: true, // Allow resetting
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _profileImageFile = File(croppedFile.path);
        });
        // TODO: Upload _profileImageFile and update user.picture in AuthBloc/repository
        // This should likely happen in EditProfileScreen after saving.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo de profil mise à jour (localement). Sauvegardez depuis l\'écran de modification.')),
        );
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
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WanzoScaffold(
      currentIndex: -1, // Or an appropriate index if it's part of main navigation
      title: 'Mon Profil',
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final User user = state.user;
            return _buildProfileDetails(context, user, state);
          } else if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Handle other states like Unauthenticated or Failure
            return const Center(
              child: Text('Impossible de charger les informations du profil.'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context, User user, AuthState state) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60, // Increased size
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                backgroundImage: _profileImageFile != null 
                    ? FileImage(_profileImageFile!) 
                    : (user.picture != null && user.picture!.isNotEmpty 
                        ? NetworkImage(user.picture!) 
                        : null) as ImageProvider?,
                child: (_profileImageFile == null && (user.picture == null || user.picture!.isEmpty))
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 50, // Increased size
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
                onPressed: () {
                  _showImagePickerOptions(context); 
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProfileInfoRow(context, 'Nom complet', user.name),
                _buildProfileInfoRow(context, 'Adresse e-mail', user.email),
                _buildProfileInfoRow(context, 'Téléphone', user.phone),
                _buildProfileInfoRow(context, 'Fonction', user.jobTitle ?? 'Non fourni'),
                _buildProfileInfoRow(context, 'Adresse', user.physicalAddress ?? 'Non fourni'),
                _buildProfileInfoRow(context, 'Pièce d\'identité', user.idCard ?? 'Non fourni'),
                _buildProfileInfoRow(context, 'Statut Pièce d\'identité', user.idCardStatus.toString().split('.').last),
                if (user.idCardStatusReason != null && user.idCardStatusReason!.isNotEmpty)
                  _buildProfileInfoRow(context, 'Raison Statut', user.idCardStatusReason!),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Modifier le profil'),
          onPressed: () {
            final authState = context.read<AuthBloc>().state; // Read state directly
            if (authState is AuthAuthenticated) { // Ensure user data is available
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: authState.user),
                ),
              ).then((result) {
                if (result is User) {
                  setState(() {});
                }
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Données utilisateur non disponibles pour la modification.')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : 'Non fourni',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}
