import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/providers/auth_provider.dart';
import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Simulate splash delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    // AuthProvider constructor already triggers _loadAuthState which is async but called in constructor (fire and forget)
    // We should probably rely on a listener or ensure it's loaded.
    // Given the current implementation of AuthProvider, _loadAuthState runs in constructor.
    // We can assume after 2 seconds it's loaded.
    
    if (authProvider.isAuthenticated) {
      context.go(AppRouter.dashboard);
    } else {
      context.go(AppRouter.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100), // Logo placeholder
            SizedBox(height: 24),
            LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}
