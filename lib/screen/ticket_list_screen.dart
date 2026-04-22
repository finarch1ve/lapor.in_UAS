import 'package:flutter/material.dart';
import 'ticket_detail_screen.dart';
import 'ticket_history_screen.dart';
import 'ticket_data.dart';

class TicketListScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const TicketListScreen({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
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
    final tickets = TicketData.tickets;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TicketHistoryScreen()),
            ),
            icon: const Icon(Icons.history),
            label: const Text('Lihat Riwayat Tiket'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tickets.length,
            itemBuilder: (context, i) {
              final t = tickets[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.confirmation_number, color: Colors.blue),
                  ),
                  title: Text(t['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${t['id']} • ${t['date']}'),
                  trailing: Chip(
                    label: Text(t['status'], style: const TextStyle(fontSize: 11, color: Colors.white)),
                    backgroundColor: _statusColor(t['status']),
                  ),
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (_) => TicketDetailScreen(
                        ticket: t,
                        onToggleTheme: widget.onToggleTheme,
                        themeMode: widget.themeMode,
                      ),
                    ));
                    setState(() {}); // refresh setelah balik
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}