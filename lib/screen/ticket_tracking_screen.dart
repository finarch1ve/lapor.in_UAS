import 'package:flutter/material.dart';

class TicketTrackingScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketTrackingScreen({super.key, required this.ticket});

  Color _statusColor(String status) {
    switch (status) {
      case 'Menunggu': return Colors.orange;
      case 'Diproses': return Colors.purple;
      case 'Selesai': return Colors.green;
      default: return Colors.grey;
    }
  }

  int get _currentStep {
    switch (ticket['status']) {
      case 'Menunggu': return 0;
      case 'Diproses': return 1;
      case 'Selesai': return 2;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ticket['history'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(title: Text('Tracking ${ticket['id']}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Tiket
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ticket['title'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Chip(
                          label: Text(
                            ticket['status'],
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          backgroundColor: _statusColor(ticket['status']),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.tag, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(ticket['id'], style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.category, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(ticket['category'], style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(ticket['date'], style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Progress Stepper
            const Text('Progress Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _stepCircle('Menunggu', 0),
                _stepLine(0),
                _stepCircle('Diproses', 1),
                _stepLine(1),
                _stepCircle('Selesai', 2),
              ],
            ),

            const SizedBox(height: 28),

            // Timeline Riwayat
            const Text('Riwayat Aktivitas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(history.length, (i) {
              final h = history[i];
              final isLast = i == history.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isLast ? Colors.blue : Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(width: 2, color: Colors.grey.shade300),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h['action'],
                              style: TextStyle(
                                fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${h['time']} • oleh ${h['by']}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _stepCircle(String label, int step) {
    final isDone = _currentStep >= step;
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isDone ? _statusColor(ticket['status']) : Colors.grey.shade300,
            child: Icon(
              step == 0 ? Icons.hourglass_empty : step == 1 ? Icons.settings : Icons.check,
              color: isDone ? Colors.white : Colors.grey,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isDone ? Colors.black87 : Colors.grey)),
        ],
      ),
    );
  }

  Widget _stepLine(int step) {
    final isDone = _currentStep > step;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        height: 2,
        width: 32,
        color: isDone ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }
}