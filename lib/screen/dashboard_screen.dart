import 'package:flutter/material.dart';
import 'ticket_list_screen.dart';
import 'create_ticket_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const DashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHome(),
      TicketListScreen(onToggleTheme: widget.onToggleTheme, themeMode: widget.themeMode),
      CreateTicketScreen(onToggleTheme: widget.onToggleTheme, themeMode: widget.themeMode),
      ProfileScreen(onToggleTheme: widget.onToggleTheme, themeMode: widget.themeMode),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tiket'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Buat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selamat datang!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _statCard('Total Tiket', '24', Colors.blue, Icons.confirmation_number),
              _statCard('Menunggu', '8', Colors.orange, Icons.hourglass_empty),
              _statCard('Diproses', '10', Colors.purple, Icons.settings),
              _statCard('Selesai', '6', Colors.green, Icons.check_circle),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Tiket Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _ticketCard('Tidak bisa login sistem', 'Menunggu', Colors.orange),
          _ticketCard('Printer rusak lantai 2', 'Diproses', Colors.purple),
          _ticketCard('Reset password email', 'Selesai', Colors.green),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _ticketCard(String title, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.confirmation_number, color: Colors.blue),
        title: Text(title),
        trailing: Chip(
          label: Text(status, style: const TextStyle(fontSize: 11, color: Colors.white)),
          backgroundColor: statusColor,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}