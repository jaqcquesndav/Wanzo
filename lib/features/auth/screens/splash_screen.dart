import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:wanzo/constants/constants.dart';
import '../bloc/auth_bloc.dart';

/// Écran d'accueil affiché au démarrage de l'application
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Vérification de l'état d'authentification
    context.read<AuthBloc>().add(const AuthCheckRequested());
    
    // Configuration des animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Redirection vers le dashboard
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) { // Check if the widget is still in the tree
              context.go('/dashboard'); // Use go_router
            }
          });
        } else if (state is AuthUnauthenticated) {
          // Redirection vers l'écran d'accueil ou d'onboarding
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) { // Check if the widget is still in the tree
              context.go('/onboarding'); // Use go_router
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: WanzoColors.primary,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,                      child: Column(
                        children: [                          // Logo de l'application
                          Image.asset(
                            'assets/images/splash_logo.jpg',
                            height: 80,
                            color: Colors.white,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/logo.jpg',
                                height: 80,
                                color: Colors.white,
                                errorBuilder: (_, __, ___) {
                                  return const Icon(
                                    Icons.storefront,
                                    size: 80,
                                    color: Colors.white,
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(height: WanzoSpacing.base),
                          Text(
                            'WANZO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: WanzoTypography.fontSizeXxl,
                              fontWeight: WanzoTypography.fontWeightBold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          SizedBox(height: WanzoSpacing.sm),
                          Text(
                            'Gestion simplifiée',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: WanzoTypography.fontSizeMd,
                              fontWeight: WanzoTypography.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: WanzoSpacing.xxl),
                  // Indicateur de chargement
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
