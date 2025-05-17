// filepath: c:\Users\DevSpace\Flutter\wanzo\lib\features\connectivity\widgets\connectivity_status_banner.dart

import 'package:flutter/material.dart';
import '../../../core/utils/connectivity_service.dart';

/// Widget affichant l'état de connectivité (en ligne/hors ligne)
class ConnectivityStatusBanner extends StatefulWidget {
  final bool showAlways;
  final double height;
  final Color onlineColor;
  final Color offlineColor;
  
  /// Constructeur
  const ConnectivityStatusBanner({
    super.key,
    this.showAlways = false,
    this.height = 25.0,
    this.onlineColor = Colors.green,
    this.offlineColor = Colors.red,
  });

  @override
  State<ConnectivityStatusBanner> createState() => _ConnectivityStatusBannerState();
}

class _ConnectivityStatusBannerState extends State<ConnectivityStatusBanner> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Vérifier l'état initial
    _isConnected = _connectivityService.isConnected;
    _showBanner = !_isConnected || widget.showAlways;
      // S'abonner aux changements de connectivité
    _connectivityService.connectionStatus.addListener(() {
      if (mounted) {
        setState(() {
          _isConnected = _connectivityService.isConnected;
          _showBanner = !_isConnected || widget.showAlways;
        });
      }
    });
    
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBanner) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: widget.height,
      color: _isConnected ? widget.onlineColor : widget.offlineColor,
      child: Center(
        child: Text(
          _isConnected ? 'En ligne' : 'Hors ligne',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
