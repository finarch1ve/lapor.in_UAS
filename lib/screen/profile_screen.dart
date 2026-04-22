import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const ProfileScreen({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.blue, child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 12),
          const Text('Fina', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('434241128 • Kelas TI-B1', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ListTile(leading: const Icon(Icons.person), title: const Text('Edit Profil'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.notifications), title: const Text('Notifikasi'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(value: themeMode == ThemeMode.dark, onChanged: (_) => onToggleTheme()),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen(onToggleTheme: onToggleTheme, themeMode: themeMode))),
          ),
        ],
      ),
    );
  }
}