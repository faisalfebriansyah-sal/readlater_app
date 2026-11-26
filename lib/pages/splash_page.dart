import 'package:flutter/material.dart';
import '../core/app_routing.dart';
import '../main.dart';
import '../services/api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    final token = await ApiService.getToken();
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRouting.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRouting.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6F2EA),
              Color(0xFFEDE2D2),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                size: 56,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'ReadLater Blog',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Simpan bacaan & ringkasan terbaikmu',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}