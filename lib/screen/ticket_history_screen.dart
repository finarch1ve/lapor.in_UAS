import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_uts/providers/auth_provider.dart';
import 'package:ticketing_uts/providers/ticket_provider.dart';
import 'package:ticketing_uts/widgets/app_colors.dart';
import 'package:ticketing_uts/widgets/app_card.dart';
import 'ticket_tracking_screen.dart';

class TicketHistoryScreen extends ConsumerStatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  ConsumerState<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends ConsumerState<TicketHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  List<dynamic> _filtered(String status, dynamic ticketState, dynamic user) {
    final tickets = user?.isAdmin == true
        ? ticketState.tickets
        : user?.isHelpdesk == true
            ? ticketState.assignedTickets
            : ticketState.myTickets;

    if (status == 'Semua') {
      return tickets;
    }
    if (status == 'Aktif') {
      return tickets.where((t) => t.status != 'Selesai').toList();
    }
    return tickets.where((t) => t.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final textSecondary = theme.textTheme.bodySmall?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Riwayat Tiket'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          labelColor: primary,
          unselectedLabelColor: textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
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
          _buildTab('Semua', ticketState, user, theme),
          _buildTab('Aktif', ticketState, user, theme),
          _buildTab('Selesai', ticketState, user, theme),
        ],
      ),
    );
  }

  Widget _buildTab(String status, dynamic ticketState, dynamic user, ThemeData theme) {
    final tickets = _filtered(status, ticketState, user);
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodySmall?.color;

    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 60, color: textSecondary?.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'Tidak ada tiket ${status == "Semua" ? "" : status}',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, i) {
        final t = tickets[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketTrackingScreen(ticketId: t.id),
                ),
              );
            },
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 4,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.getStatusColor(t.status ?? 'Menunggu'),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title ?? 'Tanpa judul',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${t.displayId ?? t.id ?? "#???"} • ${t.category ?? "Lainnya"} • ${t.formattedDate ?? ""}',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.chevron_right,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}