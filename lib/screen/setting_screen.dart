import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_uts/providers/auth_provider.dart';
import 'package:ticketing_uts/widgets/status_badge.dart';

class SettingScreen extends ConsumerWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const SettingScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Account section
          SectionHeader(title: 'Akun'),
          if (user != null) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RoleBadge(role: user.role, fontSize: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profil',
            cardColor: cardColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primary: primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur edit profil coming soon!')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            cardColor: cardColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primary: primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur ubah password coming soon!')),
              );
            },
          ),

          const SizedBox(height: 8),

          // Appearance section
          SectionHeader(title: 'Tampilan'),
          _buildSwitchMenuItem(
            icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
            title: 'Mode Gelap',
            subtitle: 'Aktifkan tema dark mode',
            value: isDarkMode,
            onChanged: (_) => onToggleTheme(),
            cardColor: cardColor,
            dividerColor: dividerColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primary: primary,
          ),

          const SizedBox(height: 8),

          // Notification section
          SectionHeader(title: 'Notifikasi'),
          _buildSwitchMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi Push',
            subtitle: 'Terima notifikasi tiket',
            value: true, // TODO: Implement real notification setting
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value ? 'Notifikasi diaktifkan' : 'Notifikasi dinonaktifkan')),
              );
            },
            cardColor: cardColor,
            dividerColor: dividerColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primary: primary,
          ),
          _buildSwitchMenuItem(
            icon: Icons.email_outlined,
            title: 'Notifikasi Email',
            subtitle: 'Terima update via email',
            value: false, // TODO: Implement real notification setting
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value ? 'Email notifikasi diaktifkan' : 'Email notifikasi dinonaktifkan')),
              );
            },
            cardColor: cardColor,
            dividerColor: dividerColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primary: primary,
          ),

          const SizedBox(height: 8),

          // Support section
          SectionHeader(title: 'Bantuan'),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Pusat Bantuan',
            cardColor: cardColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primary: primary,
            onTap: () => _showHelpDialog(context),
          ),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'Kebijakan Privasi',
            cardColor: cardColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primary: primary,
            onTap: () => _showPrivacyDialog(context),
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            cardColor: cardColor,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primary: primary,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Lapor.in',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 Universitas Airlangga',
              );
            },
          ),

          const SizedBox(height: 8),

          // Logout
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Apakah kamu yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Ya, Logout'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red, size: 20),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color cardColor,
    required Color? textPrimary,
    required Color? textSecondary,
    required Color primary,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color cardColor,
    required Color dividerColor,
    required Color? textPrimary,
    required Color? textSecondary,
    required Color primary,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: primary),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pusat Bantuan'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cara Membuat Tiket:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Buka tab "Buat"\n2. Isi judul dan deskripsi\n3. Pilih kategori\n4. (Opsional) Upload gambar\n5. Tap "Kirim Tiket"'),
              SizedBox(height: 16),
              Text('Melacak Status Tiket:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. Buka tab "Tiket"\n2. Tap tiket yang ingin dilacak\n3. Lihat riwayat aktivitas di bawah'),
              SizedBox(height: 16),
              Text('Hubungi Helpdesk:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Untuk bantuan lebih lanjut, hubungi:\nhelpdesk@unair.ac.id'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kebijakan Privasi'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kami menghargai privasi Anda. Informasi yang Anda berikan akan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Digunakan untuk keperluan ticketing saja\n'
                  '• Tidak dibagikan ke pihak ketiga\n'
                  '• Disimpan dengan aman di server kami\n'
                  '• Dihapus saat akun Anda dihapus'),
              SizedBox(height: 16),
              Text(
                'Data yang Kami Kumpulkan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Nama dan email\n'
                  '• Informasi tiket yang Anda buat\n'
                  '• (Opsional) Gambar terkait tiket'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall?.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}