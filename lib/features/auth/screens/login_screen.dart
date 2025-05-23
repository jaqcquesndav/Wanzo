import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wanzo/constants/constants.dart';
import 'package:wanzo/features/auth/screens/forgot_password_screen.dart';
import '../bloc/auth_bloc.dart';
import '../../../features/connectivity/widgets/subtle_offline_indicator.dart';

/// Écran de connexion permettant à l'utilisateur de se connecter
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Soumission du formulaire de connexion
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Dispatch demo login event if demo credentials are used
      if (email == 'demo@wanzo.app' && password == 'wanzo_password123') {
        context.read<AuthBloc>().add(const AuthLoginWithDemoAccountRequested());
      } else {
        // Otherwise, dispatch standard Auth0 login event
        context.read<AuthBloc>().add(const AuthLoginWithAuth0Requested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Redirection vers le dashboard avec GoRouter
            context.go('/dashboard');
          } else if (state is AuthFailure) {
            // Affichage d'une erreur
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: WanzoColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Contenu principal
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(WanzoSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Petit indicateur de mode hors ligne
                          const Align(
                            alignment: Alignment.topRight,
                            child: SubtleOfflineIndicator(),
                          ),
                          const SizedBox(height: WanzoSpacing.sm),
                          // Logo et titre
                          Image.asset(
                            'assets/images/logo.png',
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.storefront,
                                size: 72,
                                color: WanzoColors.primary,
                              );
                            },
                          ),
                          const SizedBox(height: WanzoSpacing.md),
                          Text(
                            'WANZO',
                            style: TextStyle(
                              color: WanzoColors.primary,
                              fontSize: WanzoTypography.fontSizeXl,
                              fontWeight: WanzoTypography.fontWeightBold,
                              letterSpacing: 2.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: WanzoSpacing.sm),
                          Text(
                            'Connectez-vous à votre compte',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: WanzoTypography.fontSizeMd,
                              fontWeight: WanzoTypography.fontWeightMedium,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: WanzoSpacing.xxl),
                          
                          // Formulaire de connexion
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Champ email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'exemple@email.com',
                                    prefixIcon: const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                                      borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                                      borderSide: const BorderSide(color: WanzoColors.primary, width: 2),
                                    ),
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
                                
                                // Champ mot de passe
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
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
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                                      borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                                      borderSide: const BorderSide(color: WanzoColors.primary, width: 2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez saisir votre mot de passe';
                                    }
                                    return null;
                                  },
                                ),
                                
                                // Option se souvenir de moi et mot de passe oublié
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded( // Wrap with Expanded
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: _rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                _rememberMe = value!;
                                              });
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          Flexible( // Use Flexible for text to allow wrapping if needed
                                            child: Text(
                                              'Se souvenir de moi',
                                              style: TextStyle(fontSize: WanzoTypography.fontSizeSm),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded( // Wrap with Expanded
                                      child: TextButton(
                                        onPressed: () {
                                          // Navigate to ForgotPasswordScreen using GoRouter
                                          context.push(ForgotPasswordScreen.routeName);
                                        },
                                        child: Text(
                                          'Mot de passe oublié ?',
                                          textAlign: TextAlign.end, // Align text to the end
                                          style: TextStyle(
                                            fontSize: WanzoTypography.fontSizeSm,
                                            color: WanzoColors.primary,
                                            fontWeight: WanzoTypography.fontWeightMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: WanzoSpacing.lg),
                                
                                // Bouton de connexion
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: state is AuthLoading ? null : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                                      ),
                                    ),
                                    child: state is AuthLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : const Text(
                                            'Se connecter',
                                            style: TextStyle(
                                              fontSize: WanzoTypography.fontSizeMd,
                                              fontWeight: WanzoTypography.fontWeightSemiBold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ), // Fin du Form
                          // Lien vers la création de compte
                          const SizedBox(height: WanzoSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Vous n'avez pas de compte?"),
                              TextButton(
                                onPressed: () {
                                  context.go('/signup');
                                },
                                child: const Text(
                                  'Créer un compte',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          
                          // Mode démo pour test rapide
                          const SizedBox(height: WanzoSpacing.lg),
                          OutlinedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    // Update credentials to the specific demo ones
                                    _emailController.text = 'demo@wanzo.app';
                                    _passwordController.text = 'wanzo_password123';
                                    _submitForm(); // This will now correctly dispatch AuthLoginWithDemoAccountRequested
                                  },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                              ),
                            ),
                            child: const Text('Mode démo'),
                          ),
                        ], // Fin des enfants de la colonne principale
                      ), // Fin de la colonne principale
                    ), // Fin du padding
                  ), // Fin du SingleChildScrollView
                ), // Fin du Center
              ), // Fin du SafeArea
            ], // Fin des enfants du Stack
          ); // Fin du Stack
        },
      ),
    );
  }
}
