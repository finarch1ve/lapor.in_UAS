import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_uts/providers/auth_provider.dart';
import 'package:ticketing_uts/providers/ticket_provider.dart';
import 'package:ticketing_uts/widgets/app_card.dart';
import 'package:ticketing_uts/widgets/app_button.dart';
import 'ticket_detail_screen.dart';
import 'ticket_history_screen.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const TicketListScreen({super.key, required this.onToggleTheme, required this.themeMode});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
  }

  List<dynamic> _getFilteredTickets(dynamic ticketState, dynamic user) {
    final tickets = user?.isAdmin == true
        ? ticketState.tickets
        : user?.isHelpdesk == true
            ? ticketState.assignedTickets
            : ticketState.myTickets;

    if (_selectedFilter == 'Semua') {
      return tickets;
    }
    return tickets.where((t) => t.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;
    final textSecondary = theme.textTheme.bodySmall?.color;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredTickets = _getFilteredTickets(ticketState, user);

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Semua', 'Menunggu', 'Diproses', 'Selesai'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : textSecondary,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: primary,
                    backgroundColor: cardColor,
                    side: BorderSide(
                      color: isSelected ? primary : dividerColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // History button
        Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TicketHistoryScreen()),
            ),
            icon: const Icon(Icons.history, size: 18),
            label: const Text('Lihat Riwayat Tiket'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: BorderSide(color: primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              foregroundColor: primary,
            ),
          ),
        ),

        // Ticket list
        Expanded(
          child: ticketState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredTickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 60,
                            color: textSecondary?.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedFilter == 'Semua'
                                ? 'Belum ada tiket'
                                : 'Tidak ada tiket $_selectedFilter',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(ticketProvider.notifier).fetchTickets(reset: true),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredTickets.length,
                              itemBuilder: (context, i) {
                                final t = filteredTickets[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TicketCard(
                                    title: t.title ?? 'Tanpa judul',
                                    ticketId: t.displayId ?? t.id ?? '#???',
                                    category: t.category ?? 'Lainnya',
                                    date: t.formattedDate ?? '',
                                    status: t.status ?? 'Menunggu',
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TicketDetailScreen(
                                            ticketId: t.id,
                                            onToggleTheme: widget.onToggleTheme,
                                            themeMode: widget.themeMode,
                                          ),
                                        ),
                                      );
                                      setState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                            // Load More Button
                            if (ticketState.hasMore && _selectedFilter == 'Semua')
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: ticketState.isLoadingMore
                                    ? const Center(child: CircularProgressIndicator())
                                    : AppButton(
                                        label: 'Muat Lebih Banyak',
                                        onPressed: () => ref.read(ticketProvider.notifier).loadMoreTickets(),
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}