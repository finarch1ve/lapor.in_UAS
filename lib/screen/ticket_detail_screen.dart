import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_uts/providers/auth_provider.dart';
import 'package:ticketing_uts/providers/ticket_provider.dart';
import 'package:ticketing_uts/models/ticket_model.dart';
import 'package:ticketing_uts/config/supabase_config.dart';
import 'package:ticketing_uts/widgets/status_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  TicketModel? _ticket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTicket();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTicket() async {
    setState(() => _isLoading = true);
    try {
      final ticketState = ref.read(ticketProvider);
      final allTickets = [
        ...ticketState.tickets,
        ...ticketState.myTickets,
        ...ticketState.assignedTickets,
      ];
      _ticket = allTickets.firstWhere((t) => t.id == widget.ticketId);
    } catch (e) {
      debugPrint('Error loading ticket: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadComments() async {
    await ref.read(ticketProvider.notifier).fetchComments(widget.ticketId);
    await ref.read(ticketProvider.notifier).fetchHistory(widget.ticketId);
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final success = await ref.read(ticketProvider.notifier).addComment(
      widget.ticketId,
      _commentController.text.trim(),
    );

    if (success && mounted) {
      _commentController.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _showAssignDialog() async {
    final user = ref.read(currentUserProvider);
    if (user == null || !user.isAdmin) return;

    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('role', 'helpdesk')
          .eq('is_active', true);

      final helpdesks = (response as List).map((e) => {
        'id': e['id'],
        'name': e['name'],
        'email': e['email'],
      }).toList();

      if (!mounted) return;

      if (helpdesks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada helpdesk tersedia')),
        );
        return;
      }

      final selectedHelpdesk = await showDialog<Map>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pilih Helpdesk'),
          content: ListView.separated(
            shrinkWrap: true,
            itemCount: helpdesks.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final hd = helpdesks[index];
              return ListTile(
                title: Text(hd['name']),
                subtitle: Text(hd['email']),
                onTap: () => Navigator.pop(context, hd),
              );
            },
          ),
        ),
      );

      if (selectedHelpdesk != null) {
        final success = await ref.read(ticketProvider.notifier).assignTicket(
          widget.ticketId,
          selectedHelpdesk['id'],
        );

        if (success && mounted) {
          setState(() {});
          _loadComments();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tiket diassign ke ${selectedHelpdesk['name']}'),
              backgroundColor: const Color(0xFF2e7d32),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat helpdesk: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showStatusDialog() async {
    final currentStatus = _ticket!.status;
    String? newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status Tiket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Menunggu', 'Diproses', 'Selesai'].map((status) {
            return RadioListTile<String>(
              title: Text(status),
              value: status,
              groupValue: currentStatus,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );

    if (newStatus != null && newStatus != currentStatus) {
      await ref.read(ticketProvider.notifier).updateTicketStatus(widget.ticketId, newStatus);
      if (mounted) {
        setState(() {});
        _loadComments();
      }
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Tiket #${_ticket!.displayId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin menghapus tiket ini?'),
            const SizedBox(height: 8),
            Text(
              _ticket!.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(ticketProvider.notifier).deleteTicket(widget.ticketId);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus tiket'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final ticketState = ref.watch(ticketProvider);
    final comments = ticketState.getComments(widget.ticketId);
    final history = ticketState.getHistory(widget.ticketId);
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodySmall?.color;
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;
    final primary = theme.primaryColor;

    if (_isLoading || _ticket == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Detail Tiket ${_ticket!.displayId}'),
        actions: [
          if (user?.isAdmin == true || user?.isHelpdesk == true)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'status') {
                  await _showStatusDialog();
                } else if (value == 'assign') {
                  await _showAssignDialog();
                } else if (value == 'delete') {
                  await _showDeleteDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'status', child: Text('Update Status')),
                if (user?.isAdmin == true)
                  const PopupMenuItem(value: 'assign', child: Text('Assign Helpdesk')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus Tiket', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _ticket!.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      StatusBadge(status: _ticket!.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _ticket!.formattedDate,
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.category, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _ticket!.category,
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Deskripsi:',
                    style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(_ticket!.description, style: TextStyle(color: textPrimary)),
                  if (_ticket!.imageUrl != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: _ticket!.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(
                          height: 200,
                          child: Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // History section
            Text(
              'Riwayat Aktivitas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dividerColor),
              ),
              child: history.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Belum ada riwayat', style: TextStyle(color: textSecondary)),
                    )
                  : Column(
                      children: List.generate(history.length, (i) {
                        final h = history[i];
                        final isLast = i == history.length - 1;
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: isLast ? primary : dividerColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(width: 2, color: dividerColor),
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
                                          color: textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${h.formattedTime} • oleh ${h.performedByName}',
                                        style: TextStyle(color: textSecondary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
            ),
            const SizedBox(height: 20),

            // Comments section
            Text(
              'Komentar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dividerColor),
              ),
              child: comments.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Belum ada komentar', style: TextStyle(color: textSecondary)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => Divider(color: dividerColor),
                      itemBuilder: (context, i) {
                        final c = comments[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    c.userName.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.userName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(c.content, style: TextStyle(color: textPrimary)),
                                  ],
                                ),
                              ),
                              Text(
                                c.formattedTime,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // Comment input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dividerColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: 3,
                      minLines: 1,
                      style: TextStyle(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: dividerColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: primary),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendComment,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}