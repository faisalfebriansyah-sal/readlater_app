import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_routing.dart';
import '../main.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _absenCtrl = TextEditingController();
  final _projectThemeCtrl = TextEditingController();

  String _name = 'Nama Pengguna';
  String _kelas = 'Belum diatur';
  String _noAbsen = '-';
  String _projectTheme = 'ReadLater Blog — Warm Editorial';
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _classCtrl.dispose();
    _absenCtrl.dispose();
    _projectThemeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('user_name') ?? 'Nama Pengguna';
      _kelas = prefs.getString('user_class') ?? 'Belum diatur';
      _noAbsen = prefs.getString('user_absen') ?? '-';
      _projectTheme =
          prefs.getString('user_project_theme') ?? 'ReadLater Blog — Warm Editorial';
      _email = prefs.getString('user_email') ?? '';
      _isLoading = false;
    });
  }

  void _showEditProfileDialog() {
    _nameCtrl.text = _name == 'Nama Pengguna' ? '' : _name;
    _classCtrl.text = _kelas == 'Belum diatur' ? '' : _kelas;
    _absenCtrl.text = _noAbsen == '-' ? '' : _noAbsen;
    _projectThemeCtrl.text = _projectTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Edit Data Profil',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _classCtrl,
                decoration: const InputDecoration(
                  labelText: 'Kelas (misal: XII RPL 2)',
                  prefixIcon: Icon(Icons.school_outlined, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _absenCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'No. Absen',
                  prefixIcon:
                      Icon(Icons.format_list_numbered, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _projectThemeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tema Proyek',
                  prefixIcon: Icon(Icons.palette_outlined, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              final newName = _nameCtrl.text.trim();
              final newClass = _classCtrl.text.trim();
              final newAbsen = _absenCtrl.text.trim();
              final newTheme = _projectThemeCtrl.text.trim();

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                'user_name',
                newName.isEmpty ? 'Nama Pengguna' : newName,
              );
              await prefs.setString(
                'user_class',
                newClass.isEmpty ? 'Belum diatur' : newClass,
              );
              await prefs.setString(
                'user_absen',
                newAbsen.isEmpty ? '-' : newAbsen,
              );
              await prefs.setString(
                'user_project_theme',
                newTheme.isEmpty ? 'ReadLater Blog — Warm Editorial' : newTheme,
              );

              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              await _loadProfileData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.secondary,
                    content: Text('Profil & tema proyek berhasil diperbarui'),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRouting.login, (route) => false);
  }

  String _getInitials(String text) {
    final parts =
        text.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Edit Profil',
            icon: const Icon(Icons.edit_outlined, color: AppColors.secondary),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor:
                                AppColors.secondary.withValues(alpha: 0.16),
                            child: Text(
                              _getInitials(_name),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (_email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _email,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                          const Divider(height: 28, color: AppColors.border),
                          _buildInfoRow(
                            icon: Icons.person_rounded,
                            iconColor: AppColors.secondary,
                            label: 'Nama',
                            value: _name,
                          ),
                          _buildInfoRow(
                            icon: Icons.class_rounded,
                            iconColor: AppColors.primary,
                            label: 'Kelas',
                            value: _kelas,
                          ),
                          _buildInfoRow(
                            icon: Icons.confirmation_number_rounded,
                            iconColor: AppColors.secondary,
                            label: 'No. Absen',
                            value: _noAbsen,
                          ),
                          _buildInfoRow(
                            icon: Icons.palette_rounded,
                            iconColor: AppColors.primary,
                            label: 'Tema Proyek',
                            value: _projectTheme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showEditProfileDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Ubah Profil & Tema Proyek'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouting.topics),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.category_outlined,
                        color: AppColors.secondary),
                    label: const Text('Kelola Topik'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _handleLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.45)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.primary),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}