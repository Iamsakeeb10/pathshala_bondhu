// ============================================================================
// 8. lib/core/widgets/no_internet_overlay.dart
// ============================================================================
import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';

class NoInternetOverlay extends StatefulWidget {
  final Widget child;

  const NoInternetOverlay({super.key, required this.child});

  @override
  State<NoInternetOverlay> createState() => _NoInternetOverlayState();
}

class _NoInternetOverlayState extends State<NoInternetOverlay> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _listenToConnectivity();
  }

  void _checkInitialConnectivity() async {
    final isConnected = await _connectivityService.checkConnectivity();
    if (mounted) {
      setState(() => _hasInternet = isConnected);
    }
  }

  void _listenToConnectivity() {
    _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() => _hasInternet = isConnected);

        if (isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Connection restored'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_hasInternet)
          Positioned.fill(
            child: _NoInternetFullScreen(
              onRetry: () async {
                final isConnected = await _connectivityService
                    .checkConnectivity();
                if (mounted) {
                  setState(() => _hasInternet = isConnected);

                  if (!isConnected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Still no internet connection'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
      ],
    );
  }
}

class _NoInternetFullScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const _NoInternetFullScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌀 GIF instead of Icon
                Image.asset(
                  'assets/animations/no_internet.gif',
                  width: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),

                // 🧭 Title
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),

                // 💬 Subtitle
                Text(
                  'It seems you are offline.\nPlease check your Wi-Fi or mobile data.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // 🔁 Retry Button
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
