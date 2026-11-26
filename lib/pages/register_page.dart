import 'package:flutter/material.dart';
import '../core/app_routing.dart';
import '../main.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Nama lengkap, email, dan password wajib diisi'),
        ),
      );
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Konfirmasi password tidak cocok'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.register(name, email, pass);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouting.home,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text(res['message'] ?? 'Register gagal'),
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
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
      filled: true,
      fillColor: AppColors.surface,
      prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 19),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          // Header atas hijau sage + tombol kembali
          SizedBox(
            height: screenHeight * 0.22,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  right: -35,
                  top: -30,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'ReadLater Blog',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sheet form daftar akun
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.82,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Buat Akun',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mulai simpan artikel & susun topik bacaanmu',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      decoration: _pillFieldDecoration(
                        hint: 'Masukkan nama lengkap',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _pillFieldDecoration(
                        hint: 'Masukkan email aktif',
                        prefixIcon: Icons.mail_outline_rounded,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      decoration: _pillFieldDecoration(
                        hint: 'Minimal 6 karakter',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 19,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Konfirmasi Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirm,
                      decoration: _pillFieldDecoration(
                        hint: 'Ulangi password',
                        prefixIcon: Icons.lock_reset_rounded,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 19,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
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
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Masuk',
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