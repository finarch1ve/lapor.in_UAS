import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Tiket #001 Diperbarui',
      'message': 'Status tiket kamu berubah menjadi "Diproses".',
      'time': '2 menit lalu',
      'icon': Icons.sync,
      'color': Colors.purple,
      'read': false,
    },
    {
      'title': 'Tiket #003 Selesai',
      'message': 'Tiket "Reset password email" telah diselesaikan.',
      'time': '1 jam lalu',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'read': false,
    },
    {
      'title': 'Komentar Baru',
      'message': 'Helpdesk membalas tiket #002 kamu.',
      'time': '3 jam lalu',
      'icon': Icons.comment,
      'color': Colors.blue,
      'read': true,
    },
    {
      'title': 'Tiket #004 Diterima',
      'message': 'Tiket "Koneksi internet lambat" sedang menunggu penanganan.',
      'time': 'Kemarin',
      'icon': Icons.inbox,
      'color': Colors.orange,
      'read': true,
    },
    {
      'title': 'Tiket #005 Diassign',
      'message': 'Tiket kamu telah diassign ke petugas helpdesk.',
      'time': 'Kemarin',
      'icon': Icons.person_pin,
      'color': Colors.teal,
      'read': true,
    },
  ];

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['read'] = true;
      }
    });
  }

  int get _unreadCount => _notifications.where((n) => n['read'] == false).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifikasi'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Tandai Semua Dibaca'),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Tidak ada notifikasi', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return InkWell(
                  onTap: () {
                    setState(() => n['read'] = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Membuka ${n['title']}')),
                    );
                  },
                  child: Container(
                    color: n['read'] == false
                        ? Colors.blue.withOpacity(0.05)
                        : null,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: (n['color'] as Color).withOpacity(0.15),
                          child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n['title'],
                                      style: TextStyle(
                                        fontWeight: n['read'] == false
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (n['read'] == false)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n['message'],
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n['time'],
                                style: const TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}