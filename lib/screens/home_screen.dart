import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../utils/shadows.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wanzo'),
        backgroundColor: WanzoColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(WanzoSpacing.base),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Bienvenue sur Wanzo',
                style: TextStyle(
                  fontSize: WanzoTypography.fontSizeXl,
                  fontWeight: WanzoTypography.fontWeightBold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: WanzoSpacing.lg),
              Text(
                'Votre nouvelle application mobile',
                style: TextStyle(
                  fontSize: WanzoTypography.fontSizeBase,
                  fontWeight: WanzoTypography.fontWeightMedium,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: WanzoSpacing.xxl),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                  boxShadow: WanzoShadows.medium,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Action à effectuer lorsque le bouton est pressé
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Fonctionnalité à venir !'),
                        backgroundColor: WanzoColors.info,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(WanzoBorderRadius.md),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: WanzoSpacing.xl, 
                      vertical: WanzoSpacing.md,
                    ),
                    textStyle: TextStyle(
                      fontSize: WanzoTypography.fontSizeMd,
                      fontWeight: WanzoTypography.fontWeightSemiBold,
                    ),
                  ),
                  child: const Text('Commencer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
