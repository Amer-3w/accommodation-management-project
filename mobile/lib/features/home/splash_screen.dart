import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'onboarding_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../shell/studyhub_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const route = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.bootstrap();
    if (!mounted) return;
    if (!auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, OnboardingScreen.route);
      return;
    }
    Navigator.pushReplacementNamed(context, auth.user?.role == 'owner' ? OwnerDashboardScreen.route : StudyHubShell.route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 78, color: Color(0xFF0C4A4A)),
            SizedBox(height: 16),
            Text('StudyHub', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
