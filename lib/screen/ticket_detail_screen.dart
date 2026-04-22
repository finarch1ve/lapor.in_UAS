import 'package:flutter/material.dart';

class TicketDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const TicketDetailScreen({super.key, required this.ticket, required this.onToggleTheme, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Tiket ${ticket['id']}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.calendar_today, size: 14),
                      const SizedBox(width: 4),
                      Text(ticket['date']),
                      const SizedBox(width: 16),
                      Chip(
                        label: Text(ticket['status'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                        backgroundColor: ticket['status'] == 'Selesai' ? Colors.green : ticket['status'] == 'Diproses' ? Colors.purple : Colors.orange,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Komentar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('H')),
                title: Text('Helpdesk'),
                subtitle: Text('Tiket sedang dalam proses penanganan.'),
              ),
            ),
            const Spacer(),
            Row(children: [
              const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Tulis komentar...', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () {}),
            ]),
          ],
        ),
      ),
    );
  }
}