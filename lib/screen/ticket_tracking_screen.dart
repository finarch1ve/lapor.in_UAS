import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_uts/providers/ticket_provider.dart';
import 'package:ticketing_uts/models/ticket_model.dart';
import 'package:ticketing_uts/widgets/app_colors.dart';
import 'package:ticketing_uts/widgets/app_card.dart';
import 'package:ticketing_uts/widgets/status_badge.dart';

class TicketTrackingScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketTrackingScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketTrackingScreen> createState() => _TicketTrackingScreenState();
}

class _TicketTrackingScreenState extends ConsumerState<TicketTrackingScreen> {
  TicketModel? _ticket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    setState(() => _isLoading = true);
    await ref.read(ticketProvider.notifier).fetchTickets();
    await ref.read(ticketProvider.notifier).fetchHistory(widget.ticketId);

    final ticketState = ref.read(ticketProvider);
    final allTickets = [
      ...ticketState.tickets,
      ...ticketState.myTickets,
      ...ticketState.assignedTickets,
    ];

    try {
      _ticket = allTickets.firstWhere((t) => t.id == widget.ticketId);
    } catch (e) {
      debugPrint('Ticket not found: $e');
    }

    setState(() => _isLoading = false);
  }

  int get _currentStep {
    if (_ticket == null) return 0;
    switch (_ticket!.status) {
      case 'Menunggu':
        return 0;
      case 'Diproses':
        return 1;
      case 'Selesai':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketProvider);
    final history = ticketState.getHistory(widget.ticketId);

    if (_isLoading || _ticket == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tracking ${_ticket!.displayId}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket info card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _ticket!.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      StatusBadge(status: _ticket!.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.tag, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(_ticket!.displayId, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.category, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(_ticket!.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(_ticket!.formattedDate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Progress stepper
            const Text(
              'Progress Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
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

            // Timeline history
            const Text(
              'Riwayat Aktivitas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              AppCard(
                child: const Text('Belum ada riwayat', style: TextStyle(color: AppColors.textSecondary)),
              )
            else
              ..._buildHistoryTimeline(history),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHistoryTimeline(List<dynamic> history) {
    return List.generate(history.length, (i) {
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
                    color: isLast ? AppColors.primary : AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.border),
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
                      h.action,
                      style: TextStyle(
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${h.formattedTime} • oleh ${h.performedByName}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _stepCircle(String label, int step) {
    final isDone = _currentStep >= step;
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isDone ? AppColors.getStatusColor(_ticket!.status!) : AppColors.border,
            child: Icon(
              step == 0 ? Icons.hourglass_empty : step == 1 ? Icons.sync : Icons.check,
              color: isDone ? Colors.white : AppColors.textSecondary,
              size: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
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
        color: isDone ? AppColors.primary : AppColors.border,
      ),
    );
  }
}
