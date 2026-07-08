import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/history_model.dart';
import '../config/supabase_config.dart';
import 'auth_provider.dart';
import 'notification_provider.dart';
import '../services/notification_service.dart';
import 'dart:io';

/// Ticket State
class TicketState {
  final bool isLoading;
  final List<TicketModel> tickets;
  final List<TicketModel> myTickets;
  final List<TicketModel> assignedTickets;
  final Map<String, List<CommentModel>> comments;
  final Map<String, List<HistoryModel>> history;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool hasMore;

  TicketState({
    this.isLoading = false,
    this.tickets = const [],
    this.myTickets = const [],
    this.assignedTickets = const [],
    this.comments = const {},
    this.history = const {},
    this.errorMessage,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  TicketState copyWith({
    bool? isLoading,
    List<TicketModel>? tickets,
    List<TicketModel>? myTickets,
    List<TicketModel>? assignedTickets,
    Map<String, List<CommentModel>>? comments,
    Map<String, List<HistoryModel>>? history,
    String? errorMessage,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return TicketState(
      isLoading: isLoading ?? this.isLoading,
      tickets: tickets ?? this.tickets,
      myTickets: myTickets ?? this.myTickets,
      assignedTickets: assignedTickets ?? this.assignedTickets,
      comments: comments ?? this.comments,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Get comments for a ticket
  List<CommentModel> getComments(String ticketId) {
    return comments[ticketId] ?? [];
  }

  /// Get history for a ticket
  List<HistoryModel> getHistory(String ticketId) {
    return history[ticketId] ?? [];
  }
}

/// Ticket StateNotifier
class TicketNotifier extends StateNotifier<TicketState> {
  TicketNotifier(this._ref) : super(TicketState()) {
    _init();
  }

  final Ref _ref;
  AppAuthState? _lastAuthState;
  static const int _pageSize = 15;
  int _currentPage = 0;

  void _init() {
    _ref.listen<AppAuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated != _lastAuthState?.isAuthenticated ||
          next.user?.id != _lastAuthState?.user?.id) {
        _lastAuthState = next;
        if (next.user != null) {
          fetchTickets(reset: true);
        } else {
          state = TicketState();
          _currentPage = 0;
        }
      }
    });

    final authState = _ref.read(authProvider);
    _lastAuthState = authState;
    if (authState.isAuthenticated) {
      fetchTickets(reset: true);
    }
  }

  /// Helper: find a ticket by id from current state (all lists combined)
  TicketModel? _findTicket(String ticketId) {
    final all = [...state.tickets, ...state.myTickets, ...state.assignedTickets];
    try {
      return all.firstWhere((t) => t.id == ticketId);
    } catch (_) {
      return null;
    }
  }

  /// Fetch tickets based on user role with pagination
  Future<void> fetchTickets({bool reset = false}) async {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null) return;

    if (reset) {
      _currentPage = 0;
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        hasMore: true,
      );
    }

    try {
      // Fetch based on role with pagination
      List<TicketModel> result;
      final rangeStart = _currentPage * _pageSize;
      final rangeEnd = rangeStart + _pageSize - 1;

      if (user.isAdmin) {
        // Admin sees all tickets
        final response = await SupabaseConfig.client
            .from('tickets')
            .select()
            .order('created_at', ascending: false)
            .range(rangeStart, rangeEnd);
        result = (response as List).map((e) => TicketModel.fromJson(e)).toList();
      } else if (user.isHelpdesk) {
        // Helpdesk sees assigned tickets
        final response = await SupabaseConfig.client
            .from('tickets')
            .select()
            .eq('helpdesk_id', user.id)
            .order('created_at', ascending: false)
            .range(rangeStart, rangeEnd);
        result = (response as List).map((e) => TicketModel.fromJson(e)).toList();
      } else {
        // User sees own tickets
        final response = await SupabaseConfig.client
            .from('tickets')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .range(rangeStart, rangeEnd);
        result = (response as List).map((e) => TicketModel.fromJson(e)).toList();
      }

      final hasMore = result.length == _pageSize;
      final currentTickets = reset ? result : [...state.tickets, ...result];

      state = state.copyWith(
        isLoading: false,
        tickets: currentTickets,
        myTickets: currentTickets.where((t) => t.userId == user.id).toList(),
        assignedTickets: currentTickets.where((t) => t.helpdeskId == user.id).toList(),
        hasMore: hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat tiket: ${e.toString()}',
      );
    }
  }

  /// Load more tickets (pagination)
  Future<void> loadMoreTickets() async {
    if (state.isLoadingMore || !state.hasMore) return;

    _currentPage++;
    state = state.copyWith(isLoadingMore: true);

    try {
      final authState = _ref.read(authProvider);
      final user = authState.user;
      if (user == null) return;

      final rangeStart = _currentPage * _pageSize;
      final rangeEnd = rangeStart + _pageSize - 1;

      List<TicketModel> newTickets;

      if (user.isAdmin) {
        final response = await SupabaseConfig.client
            .from('tickets')
            .select()
            .order('created_at', ascending: false)
            .range(rangeStart, rangeEnd);
        newTickets = (response as List).map((e) => TicketModel.fromJson(e)).toList();
      } else if (user.isHelpdesk) {
        final response = await SupabaseConfig.client
            .from('tickets')
            .select()
            .eq('helpdesk_id', user.id)
            .order('created_at', ascending: false)
            .range(rangeStart, rangeEnd);
        newTickets = (response as List).map((e) => TicketModel.fromJson(e)).toList();
      } else {
        final response = await SupabaseConfig.client
            .from('tickets')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .range(rangeStart, rangeEnd);
        newTickets = (response as List).map((e) => TicketModel.fromJson(e)).toList();
      }

      final hasMore = newTickets.length == _pageSize;
      final updatedTickets = [...state.tickets, ...newTickets];

      state = state.copyWith(
        isLoadingMore: false,
        tickets: updatedTickets,
        myTickets: updatedTickets.where((t) => t.userId == user.id).toList(),
        assignedTickets: updatedTickets.where((t) => t.helpdeskId == user.id).toList(),
        hasMore: hasMore,
      );
    } catch (e) {
      _currentPage--; // Revert page increment on error
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Gagal memuat tiket tambahan: ${e.toString()}',
      );
    }
  }

  /// Create new ticket
  Future<bool> createTicket(
    String title,
    String description,
    String category, {
    File? imageFile,
  }) async {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        final fileBytes = await imageFile.readAsBytes();
        final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        await SupabaseConfig.client.storage
            .from('ticket_images')
            .uploadBinary(fileName, fileBytes);

        imageUrl = SupabaseConfig.client.storage
            .from('ticket_images')
            .getPublicUrl(fileName);
      }

      // Create ticket
      final ticketData = {
        'title': title,
        'description': description,
        'status': 'Menunggu',
        'category': category,
        'user_id': user.id,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final response = await SupabaseConfig.client
          .from('tickets')
          .insert(ticketData)
          .select()
          .single();

      // Add history entry
      await _addHistory(response['id'], 'Tiket dibuat', user.id, user.name);

      // Refresh tickets
      await fetchTickets(reset: true);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal membuat tiket: ${e.toString()}',
      );
      return false;
    }
  }

  /// Update ticket status
  Future<bool> updateTicketStatus(String ticketId, String status) async {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null) return false;

    try {
      final ticket = _findTicket(ticketId);

      await SupabaseConfig.client
          .from('tickets')
          .update({'status': status})
          .eq('id', ticketId);

      // Add history entry
      await _addHistory(ticketId, 'Status diubah ke $status', user.id, user.name);

      // Notify ticket owner about status change
      if (ticket != null) {
        await NotificationService.notifyTicketStatusChange(
          ticketId: ticketId,
          ticketTitle: ticket.title,
          userId: ticket.userId,
          newStatus: status,
        );
        // Refresh notifications if the current user is the recipient (e.g. re-check)
        _ref.read(notificationProvider.notifier).fetchNotifications();
      }

      await fetchTickets(reset: true);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update status: ${e.toString()}');
      return false;
    }
  }

  /// Assign ticket to helpdesk
  Future<bool> assignTicket(String ticketId, String helpdeskId) async {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null || !user.isAdmin) return false;

    try {
      final ticket = _findTicket(ticketId);

      await SupabaseConfig.client
          .from('tickets')
          .update({
            'helpdesk_id': helpdeskId,
            'status': 'Diproses',
          })
          .eq('id', ticketId);

      // Add history entry
      await _addHistory(ticketId, 'Tiket diassign ke Helpdesk', user.id, user.name);

      // Notify the assigned helpdesk
      await NotificationService.notifyTicketAssignment(
        ticketId: ticketId,
        ticketTitle: ticket?.title ?? 'Tiket',
        helpdeskId: helpdeskId,
      );

      // Also notify ticket owner that their ticket is being processed
      if (ticket != null) {
        await NotificationService.notifyTicketStatusChange(
          ticketId: ticketId,
          ticketTitle: ticket.title,
          userId: ticket.userId,
          newStatus: 'Diproses',
        );
      }

      _ref.read(notificationProvider.notifier).fetchNotifications();

      await fetchTickets(reset: true);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal assign tiket: ${e.toString()}');
      return false;
    }
  }

  /// Delete ticket (soft delete)
  Future<bool> deleteTicket(String ticketId) async {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null || (!user.isAdmin && !user.isHelpdesk)) return false;

    try {
      // Soft delete by setting is_deleted to true
      await SupabaseConfig.client
          .from('tickets')
          .update({'is_deleted': true})
          .eq('id', ticketId);

      await fetchTickets(reset: true);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal menghapus tiket: ${e.toString()}');
      return false;
    }
  }

  /// Permanently delete ticket (admin only)
  Future<bool> permanentDeleteTicket(String ticketId) async {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null || !user.isAdmin) return false;

    try {
      await SupabaseConfig.client
          .from('tickets')
          .delete()
          .eq('id', ticketId);

      await fetchTickets(reset: true);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal menghapus tiket permanen: ${e.toString()}');
      return false;
    }
  }

  /// Fetch comments for a ticket
  Future<void> fetchComments(String ticketId) async {
    try {
      final response = await SupabaseConfig.client
          .from('comments')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final comments =
          (response as List).map((e) => CommentModel.fromJson(e)).toList();

      final newComments = Map<String, List<CommentModel>>.from(state.comments);
      newComments[ticketId] = comments;

      state = state.copyWith(comments: newComments);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal memuat komentar: ${e.toString()}');
    }
  }

  /// Add comment
  Future<bool> addComment(String ticketId, String content) async {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null) return false;

    try {
      final commentData = {
        'ticket_id': ticketId,
        'user_id': user.id,
        'user_name': user.name,
        'content': content,
      };

      await SupabaseConfig.client.from('comments').insert(commentData);

      // Notify other relevant parties (ticket owner and/or assigned helpdesk),
      // excluding the commenter themself
      final ticket = _findTicket(ticketId);
      if (ticket != null) {
        final recipients = <String>{};
        if (ticket.userId != user.id) recipients.add(ticket.userId);
        if (ticket.helpdeskId != null && ticket.helpdeskId != user.id) {
          recipients.add(ticket.helpdeskId!);
        }

        for (final recipientId in recipients) {
          await NotificationService.notifyNewComment(
            ticketId: ticketId,
            ticketTitle: ticket.title,
            userId: recipientId,
            commenterName: user.name,
          );
        }

        _ref.read(notificationProvider.notifier).fetchNotifications();
      }

      await fetchComments(ticketId);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal mengirim komentar: ${e.toString()}');
      return false;
    }
  }

  /// Fetch history for a ticket
  Future<void> fetchHistory(String ticketId) async {
    try {
      final response = await SupabaseConfig.client
          .from('ticket_history')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final history =
          (response as List).map((e) => HistoryModel.fromJson(e)).toList();

      final newHistory = Map<String, List<HistoryModel>>.from(state.history);
      newHistory[ticketId] = history;

      state = state.copyWith(history: newHistory);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal memuat riwayat: ${e.toString()}');
    }
  }

  /// Add history entry
  Future<void> _addHistory(
    String ticketId,
    String action,
    String performedBy,
    String performedByName,
  ) async {
    final historyData = {
      'ticket_id': ticketId,
      'action': action,
      'performed_by': performedBy,
      'performed_by_name': performedByName,
    };

    await SupabaseConfig.client.from('ticket_history').insert(historyData);
  }

  /// Get ticket statistics
  Map<String, int> getStatistics() {
    final authState = _ref.read(authProvider);
    final user = authState.user;
    if (user == null) return {};

    final tickets = user.isAdmin
        ? state.tickets
        : user.isHelpdesk
            ? state.assignedTickets
            : state.myTickets;

    return {
      'total': tickets.length,
      'Menunggu': tickets.where((t) => t.status == 'Menunggu').length,
      'Diproses': tickets.where((t) => t.status == 'Diproses').length,
      'Selesai': tickets.where((t) => t.status == 'Selesai').length,
    };
  }
}

/// Ticket Provider
final ticketProvider = StateNotifierProvider<TicketNotifier, TicketState>((ref) {
  return TicketNotifier(ref);
});