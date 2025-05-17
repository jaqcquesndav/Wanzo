import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanzo/constants/constants.dart';
import '../models/business_sector.dart';
import '../repositories/registration_repository.dart';
import '../models/registration_request.dart';
import '../../auth/bloc/auth_bloc.dart';

/// Écran d'inscription pour un nouveau compte entreprise
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs de texte
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _rccmController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Secteur sélectionné
  BusinessSector _selectedSector = africanBusinessSectors.first;
  
  // État du formulaire
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isRegistering = false;
  
  // Stepper
  int _currentStep = 0;
  static const int _totalSteps = 3;
  
  @override
  void dispose() {
    _ownerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _rccmController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Informations personnelles
        if (_ownerNameController.text.trim().isEmpty) return false;
        if (_emailController.text.trim().isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) return false;
        if (_phoneController.text.trim().isEmpty) return false;
        if (_passwordController.text.isEmpty || _passwordController.text.length < 8) return false;
        if (_passwordController.text != _confirmPasswordController.text) return false;
        return true;
      case 1: // Informations de l'entreprise
        if (_companyNameController.text.trim().isEmpty) return false;
        if (_rccmController.text.trim().isEmpty) return false;
        if (_locationController.text.trim().isEmpty) return false;
        return true;
      case 2: // Confirmation
        return _agreeToTerms;
      default:
        return false;
    }
  }
  
  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        if (_currentStep < _totalSteps - 1) {
          _currentStep++;
        } else {
          _register();
        }
      });
    } else {
      // Afficher une validation d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis correctement'),
          backgroundColor: WanzoColors.error,
        ),
      );
    }
  }
  
  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }
  
  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez accepter les conditions d\'utilisation pour continuer'),
            backgroundColor: WanzoColors.error,
          ),
        );
        return;
      }
      
      setState(() {
        _isRegistering = true;
      });
      
      final request = RegistrationRequest(
        ownerName: _ownerNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        companyName: _companyNameController.text.trim(),
        rccmNumber: _rccmController.text.trim(),
        location: _locationController.text.trim(),
        sector: _selectedSector,
      );
      
      try {
        final repository = RegistrationRepository();
        final success = await repository.register(request);
        
        if (success && mounted) {
          // Effectuer la connexion avec les identifiants fournis
          context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
          
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie ! Vous êtes maintenant connecté.'),
              backgroundColor: WanzoColors.success,
            ),
          );
          
          // Rediriger vers le tableau de bord
          context.go('/dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'inscription: $e'),
              backgroundColor: WanzoColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isRegistering = false;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
        automaticallyImplyLeading: true,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _previousStep,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: WanzoSpacing.lg),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Précédent'),
                      ),
                    ),
                  if (_currentStep > 0)
                    const SizedBox(width: WanzoSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRegistering ? null : details.onStepContinue,
                      child: _isRegistering
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_currentStep == _totalSteps - 1 ? 'S\'inscrire' : 'Suivant'),
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Identité'),
              content: _buildOwnerInfoStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Entreprise'),
              content: _buildCompanyInfoStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Confirmation'),
              content: _buildConfirmationStep(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(WanzoSpacing.md),
        child: TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Vous avez déjà un compte ? Se connecter'),
        ),
      ),
    );
  }
  
  /// Étape 1: Informations sur le propriétaire
  Widget _buildOwnerInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations personnelles',
          style: TextStyle(
            fontSize: WanzoTypography.fontSizeLg,
            fontWeight: WanzoTypography.fontWeightBold,
          ),
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Nom du propriétaire
        TextFormField(
          controller: _ownerNameController,
          decoration: const InputDecoration(
            labelText: 'Nom complet *',
            hintText: 'Entrez votre nom complet',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez saisir votre nom';
            }
            return null;
          },
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email *',
            hintText: 'exemple@email.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir votre email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Veuillez saisir un email valide';
            }
            return null;
          },
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Téléphone
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Numéro de téléphone *',
            hintText: '+243 123 456 789',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez saisir votre numéro de téléphone';
            }
            return null;
          },
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Mot de passe
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mot de passe *',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir un mot de passe';
            }
            if (value.length < 8) {
              return 'Le mot de passe doit contenir au moins 8 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Confirmation du mot de passe
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirmer le mot de passe *',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez confirmer votre mot de passe';
            }
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: WanzoSpacing.sm),
        
        const Text(
          'Tous les champs marqués (*) sont obligatoires',
          style: TextStyle(
            fontSize: WanzoTypography.fontSizeXs,
            color: WanzoColors.textSecondaryLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
  
  /// Étape 2: Informations sur l'entreprise
  Widget _buildCompanyInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations de l\'entreprise',
          style: TextStyle(
            fontSize: WanzoTypography.fontSizeLg,
            fontWeight: WanzoTypography.fontWeightBold,
          ),
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Nom de l'entreprise
        TextFormField(
          controller: _companyNameController,
          decoration: const InputDecoration(
            labelText: 'Nom de l\'entreprise *',
            hintText: 'Entrez le nom de votre entreprise',
            prefixIcon: Icon(Icons.business_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez saisir le nom de votre entreprise';
            }
            return null;
          },
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Numéro RCCM
        TextFormField(
          controller: _rccmController,
          decoration: const InputDecoration(
            labelText: 'Numéro RCCM *',
            hintText: 'Ex: CD/KIN/RCCM/XX-X-XXXX',
            prefixIcon: Icon(Icons.numbers_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez saisir le numéro RCCM';
            }
            return null;
          },
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Adresse / Lieu
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Adresse / Lieu *',
            hintText: 'Entrez l\'adresse de votre entreprise',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez saisir l\'adresse de votre entreprise';
            }
            return null;
          },
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Secteur d'activité
        DropdownButtonFormField<BusinessSector>(
          value: _selectedSector,
          decoration: const InputDecoration(
            labelText: 'Secteur d\'activité *',
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: africanBusinessSectors.map((sector) {
            return DropdownMenuItem<BusinessSector>(
              value: sector,
              child: Text(sector.name),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSector = value;
              });
            }
          },
        ),
        const SizedBox(height: WanzoSpacing.sm),
        
        const Text(
          'Tous les champs marqués (*) sont obligatoires',          style: TextStyle(
            fontSize: WanzoTypography.fontSizeXs,
            color: WanzoColors.textSecondaryLight,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
  
  /// Étape 3: Confirmation
  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vérifiez vos informations',
          style: TextStyle(
            fontSize: WanzoTypography.fontSizeLg,
            fontWeight: WanzoTypography.fontWeightBold,
          ),
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Résumé des informations
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(WanzoSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations personnelles',
                  style: TextStyle(
                    fontSize: WanzoTypography.fontSizeMd,
                    fontWeight: WanzoTypography.fontWeightBold,
                  ),
                ),
                const Divider(),
                _buildInfoRow('Nom:', _ownerNameController.text),
                _buildInfoRow('Email:', _emailController.text),
                _buildInfoRow('Téléphone:', _phoneController.text),
                
                const SizedBox(height: WanzoSpacing.md),
                const Text(
                  'Informations de l\'entreprise',
                  style: TextStyle(
                    fontSize: WanzoTypography.fontSizeMd,
                    fontWeight: WanzoTypography.fontWeightBold,
                  ),
                ),
                const Divider(),
                _buildInfoRow('Nom de l\'entreprise:', _companyNameController.text),
                _buildInfoRow('Numéro RCCM:', _rccmController.text),
                _buildInfoRow('Adresse:', _locationController.text),
                _buildInfoRow('Secteur d\'activité:', _selectedSector.name),
              ],
            ),
          ),
        ),
        const SizedBox(height: WanzoSpacing.md),
        
        // Acceptation des conditions
        Row(
          children: [
            Checkbox(
              value: _agreeToTerms,
              onChanged: (value) {
                setState(() {
                  _agreeToTerms = value ?? false;
                });
              },
              activeColor: WanzoColors.primary,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _agreeToTerms = !_agreeToTerms;
                  });
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'J\'accepte les ',
                    style: TextStyle(color: WanzoColors.textPrimaryLight),
                    children: [
                      TextSpan(
                        text: 'conditions d\'utilisation',
                        style: TextStyle(
                          color: WanzoColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' et la '),
                      TextSpan(
                        text: 'politique de confidentialité',
                        style: TextStyle(
                          color: WanzoColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: WanzoColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
