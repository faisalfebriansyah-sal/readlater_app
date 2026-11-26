import 'package:flutter/material.dart';
import '../core/app_routing.dart';
import '../main.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Email dan password wajib diisi'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      Navigator.pushReplacementNamed(context, AppRouting.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(res['message'] ?? 'Login gagal'),
        ),
      );
    }
  }

  InputDecoration _pillFieldDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.surface,
      prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Stack(
        children: [
          // Header atas hijau sage dengan branding ReadLater Blog
          SizedBox(
            height: screenHeight * 0.34,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  right: -45,
                  top: -35,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -30,
                  bottom: 20,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            color: AppColors.secondary,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ReadLater Blog',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Simpan & kelola bacaan pilihanmu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sheet form bawah dengan sudut atas membulat
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.70,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Masuk ke Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Akses topik dan koleksi artikel kamu di ReadLater Blog',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _pillFieldDecoration(
                        hint: 'Masukkan email kamu',
                        prefixIcon: Icons.mail_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      decoration: _pillFieldDecoration(
                        hint: 'Masukkan password',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRouting.register),
                          child: const Text(
                            'Daftar sekarang',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}