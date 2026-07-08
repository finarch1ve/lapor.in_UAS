import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_uts/providers/ticket_provider.dart';
import 'package:ticketing_uts/providers/auth_provider.dart';
import 'package:ticketing_uts/models/ticket_model.dart';
import 'package:ticketing_uts/models/user_model.dart';
import 'package:ticketing_uts/config/supabase_config.dart';
import 'package:ticketing_uts/widgets/app_card.dart';
import 'package:ticketing_uts/widgets/status_badge.dart';
import 'ticket_detail_screen.dart';

class AdminTicketScreen extends ConsumerStatefulWidget {
  const AdminTicketScreen({super.key});

  @override
  ConsumerState<AdminTicketScreen> createState() => _AdminTicketScreenState();
}

class _AdminTicketScreenState extends ConsumerState<AdminTicketScreen> {
  String _filterStatus = 'All';
  String _filterCategory = 'All';
  String _searchQuery = '';
  List<UserModel> _helpdeskUsers = [];
  bool _isLoadingHelpdesk = true;

  @override
  void initState() {
    super.initState();
    _fetchHelpdeskUsers();
  }

  Future<void> _fetchHelpdeskUsers() async {
    setState(() => _isLoadingHelpdesk = true);
    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('role', 'helpdesk')
          .eq('is_active', true);

      setState(() {
        _helpdeskUsers = (response as List)
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoadingHelpdesk = false;
      });
    } catch (e) {
      setState(() => _isLoadingHelpdesk = false);
    }
  }

  List<TicketModel> get _filteredTickets {
    final ticketState = ref.watch(ticketProvider);
    var tickets = ticketState.tickets;

    if (_filterStatus != 'All') {
      tickets = tickets.where((t) => t.status == _filterStatus).toList();
    }

    if (_filterCategory != 'All') {
      tickets = tickets.where((t) => t.category == _filterCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      tickets = tickets.where((t) =>
          t.title.toLowerCase().contains(query) ||
          t.displayId.toLowerCase().contains(query)
      ).toList();
    }

    return tickets;
  }

  Map<String, int> get _statistics {
    final tickets = _filteredTickets;
    return {
      'Total': tickets.length,
      'Menunggu': tickets.where((t) => t.status == 'Menunggu').length,
      'Diproses': tickets.where((t) => t.status == 'Diproses').length,
      'Selesai': tickets.where((t) => t.status == 'Selesai').length,
    };
  }

  void _showAssignDialog(TicketModel ticket) {
    if (_isLoadingHelpdesk || _helpdeskUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada helpdesk tersedia')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Tiket #${ticket.displayId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ticket.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Pilih Helpdesk:'),
            const SizedBox(height: 8),
            ..._helpdeskUsers.map((user) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.name),
              subtitle: Text(user.email),
              onTap: () async {
                Navigator.pop(ctx);
                final success = await ref.read(ticketProvider.notifier)
                    .assignTicket(ticket.id, user.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Tiket diassign ke ${user.name}' : 'Gagal assign tiket',
                      ),
                      backgroundColor: success ? const Color(0xFF2e7d32) : Colors.red,
                    ),
                  );
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Status - #${ticket.displayId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Menunggu', 'Diproses', 'Selesai'].map((status) {
            return RadioListTile<String>(
              title: Text(status),
              value: status,
              groupValue: ticket.status,
              onChanged: (value) async {
                if (value != null) {
                  Navigator.pop(ctx);
                  final success = await ref.read(ticketProvider.notifier)
                      .updateTicketStatus(ticket.id, value);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'Status diubah ke $value' : 'Gagal update status',
                        ),
                        backgroundColor: success ? const Color(0xFF2e7d32) : Colors.red,
                      ),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteDialog(TicketModel ticket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Tiket - #${ticket.displayId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin menghapus tiket ini?'),
            const SizedBox(height: 8),
            Text(
              ticket.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(ticketProvider.notifier)
                  .deleteTicket(ticket.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Tiket berhasil dihapus' : 'Gagal menghapus tiket',
                    ),
                    backgroundColor: success ? const Color(0xFF2e7d32) : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(TicketModel ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketDetailScreen(
          ticketId: ticket.id,
          onToggleTheme: () {},
          themeMode: ThemeMode.system,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodySmall?.color;

    if (user == null || !user.isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Akses ditolak. Admin only.')),
      );
    }

    final filtered = _filteredTickets;
    final stats = _statistics;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Tiket'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(ticketProvider.notifier).fetchTickets(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics strip
          Container(
            padding: const EdgeInsets.all(16),
            color: cardColor,
            child: Row(
              children: [
                _statChip('Total', stats['Total'] ?? 0, primary),
                const SizedBox(width: 8),
                _statChip('Menunggu', stats['Menunggu'] ?? 0, const Color(0xFFf57c00)),
                const SizedBox(width: 8),
                _statChip('Diproses', stats['Diproses'] ?? 0, const Color(0xFF7b1fa2)),
                const SizedBox(width: 8),
                _statChip('Selesai', stats['Selesai'] ?? 0, const Color(0xFF2e7d32)),
              ],
            ),
          ),

          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: cardColor,
            child: Column(
              children: [
                // Search
                TextField(
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Cari tiket...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: dividerColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),

                // Status & Category Filter
                Row(
                  children: [
                    Text(
                      'Status: ',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary),
                    ),
                    DropdownButton<String>(
                      value: _filterStatus,
                      underline: const SizedBox(),
                      dropdownColor: cardColor,
                      style: TextStyle(color: textPrimary),
                      items: ['All', 'Menunggu', 'Diproses', 'Selesai']
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _filterStatus = value ?? 'All'),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Kategori: ',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary),
                    ),
                    DropdownButton<String>(
                      value: _filterCategory,
                      underline: const SizedBox(),
                      dropdownColor: cardColor,
                      style: TextStyle(color: textPrimary),
                      items: ['All', 'Hardware', 'Software', 'Network', 'Lainnya']
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _filterCategory = value ?? 'All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor),

          // Ticket List
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateCard(
                    message: 'Tidak ada tiket',
                    icon: Icons.inbox,
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.all(16),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ticket = filtered[index];
                      return _ticketCard(ticket, textPrimary, textSecondary);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketCard(TicketModel ticket, Color? textPrimary, Color? textSecondary) {
    return AppCard(
      onTap: () => _navigateToDetail(ticket),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.displayId,
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: ticket.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, size: 14, color: textSecondary),
              const SizedBox(width: 4),
              Text(
                ticket.category,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 14, color: textSecondary),
              const SizedBox(width: 4),
              Text(
                ticket.formattedDate,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (ticket.helpdeskId == null || ticket.helpdeskId!.isEmpty)
                ActionButton(
                  label: 'Assign',
                  icon: Icons.person_add,
                  type: ActionButtonType.primary,
                  onTap: () => _showAssignDialog(ticket),
                ),
              ActionButton(
                label: 'Status',
                icon: Icons.edit,
                type: ActionButtonType.secondary,
                onTap: () => _showStatusDialog(ticket),
              ),
              ActionButton(
                label: 'Hapus',
                icon: Icons.delete,
                type: ActionButtonType.danger,
                onTap: () => _showDeleteDialog(ticket),
              ),
            ],
          ),
          if (ticket.helpdeskId != null && ticket.helpdeskId!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: Color(0xFF2e7d32)),
                  const SizedBox(width: 4),
                  const Text(
                    'Assigned to Helpdesk',
                    style: TextStyle(fontSize: 11, color: Color(0xFF2e7d32)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum ActionButtonType { primary, secondary, danger }

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final ActionButtonType type;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    switch (type) {
      case ActionButtonType.primary:
        bgColor = Theme.of(context).primaryColor;
        break;
      case ActionButtonType.secondary:
        bgColor = const Color(0xFF7b1fa2);
        break;
      case ActionButtonType.danger:
        bgColor = const Color(0xFFd32f2f);
        break;
    }

    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}