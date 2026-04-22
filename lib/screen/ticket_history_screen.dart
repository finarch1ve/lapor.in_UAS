import 'package:flutter/material.dart';
import 'ticket_tracking_screen.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _allTickets = [
    {
      'id': '#001',
      'title': 'Tidak bisa login sistem',
      'status': 'Menunggu',
      'date': '21 Apr 2026',
      'category': 'Software',
      'history': [
        {'action': 'Tiket dibuat', 'time': '21 Apr 2026, 08:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '21 Apr 2026, 08:01', 'by': 'Sistem'},
      ],
    },
    {
      'id': '#002',
      'title': 'Printer rusak lantai 2',
      'status': 'Diproses',
      'date': '20 Apr 2026',
      'category': 'Hardware',
      'history': [
        {'action': 'Tiket dibuat', 'time': '20 Apr 2026, 09:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '20 Apr 2026, 09:01', 'by': 'Sistem'},
        {'action': 'Tiket diassign ke Helpdesk', 'time': '20 Apr 2026, 10:00', 'by': 'Admin'},
        {'action': 'Status diubah ke Diproses', 'time': '20 Apr 2026, 11:00', 'by': 'Helpdesk'},
      ],
    },
    {
      'id': '#003',
      'title': 'Reset password email',
      'status': 'Selesai',
      'date': '19 Apr 2026',
      'category': 'Software',
      'history': [
        {'action': 'Tiket dibuat', 'time': '19 Apr 2026, 07:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '19 Apr 2026, 07:01', 'by': 'Sistem'},
        {'action': 'Tiket diassign ke Helpdesk', 'time': '19 Apr 2026, 08:00', 'by': 'Admin'},
        {'action': 'Status diubah ke Diproses', 'time': '19 Apr 2026, 09:00', 'by': 'Helpdesk'},
        {'action': 'Tiket diselesaikan', 'time': '19 Apr 2026, 12:00', 'by': 'Helpdesk'},
      ],
    },
    {
      'id': '#004',
      'title': 'Koneksi internet lambat',
      'status': 'Menunggu',
      'date': '18 Apr 2026',
      'category': 'Network',
      'history': [
        {'action': 'Tiket dibuat', 'time': '18 Apr 2026, 14:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '18 Apr 2026, 14:01', 'by': 'Sistem'},
      ],
    },
    {
      'id': '#005',
      'title': 'Komputer tidak menyala',
      'status': 'Diproses',
      'date': '17 Apr 2026',
      'category': 'Hardware',
      'history': [
        {'action': 'Tiket dibuat', 'time': '17 Apr 2026, 10:00', 'by': 'Kamu'},
        {'action': 'Tiket diterima sistem', 'time': '17 Apr 2026, 10:01', 'by': 'Sistem'},
        {'action': 'Tiket diassign ke Helpdesk', 'time': '17 Apr 2026, 11:00', 'by': 'Admin'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(String status) =>
      status == 'Semua' ? _allTickets : _allTickets.where((t) => t['status'] == status).toList();

  Color _statusColor(String status) {
    switch (status) {
      case 'Menunggu': return Colors.orange;
      case 'Diproses': return Colors.purple;
      case 'Selesai': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Tiket'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList('Semua'),
          _buildList('Diproses'),
          _buildList('Selesai'),
        ],
      ),
    );
  }

  Widget _buildList(String filter) {
    final list = _filtered(filter);
    if (list.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('Tidak ada tiket', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final t = list[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _statusColor(t['status']).withOpacity(0.15),
              child: Icon(Icons.confirmation_number, color: _statusColor(t['status'])),
            ),
            title: Text(t['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${t['id']} • ${t['category']} • ${t['date']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(t['status'],
                      style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: _statusColor(t['status']),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TicketTrackingScreen(ticket: t),
              ),
            ),
          ),
        );
      },
    );
  }
}