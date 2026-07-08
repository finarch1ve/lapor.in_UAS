import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';
import '../models/history_model.dart';


class TicketService {
  /// Fetch all tickets (Admin only)
  static Future<List<TicketModel>> fetchAllTickets() async {
    final response = await SupabaseConfig.client
        .from('tickets')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  /// Fetch tickets by user ID (User's own tickets)
  static Future<List<TicketModel>> fetchUserTickets(String userId) async {
    final response = await SupabaseConfig.client
        .from('tickets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  /// Fetch tickets assigned to helpdesk
  static Future<List<TicketModel>> fetchAssignedTickets(String helpdeskId) async {
    final response = await SupabaseConfig.client
        .from('tickets')
        .select()
        .eq('helpdesk_id', helpdeskId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  /// Get ticket by ID
  static Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final response = await SupabaseConfig.client
          .from('tickets')
          .select()
          .eq('id', ticketId)
          .single();
      return TicketModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create new ticket
  static Future<TicketModel?> createTicket({
    required String title,
    required String description,
    required String category,
    required String userId,
    String? imageUrl,
  }) async {
    try {
      final ticketData = {
        'title': title,
        'description': description,
        'status': 'Menunggu',
        'category': category,
        'user_id': userId,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      final response = await SupabaseConfig.client
          .from('tickets')
          .insert(ticketData)
          .select()
          .single();

      return TicketModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update ticket status
  static Future<bool> updateTicketStatus(String ticketId, String status) async {
    try {
      await SupabaseConfig.client
          .from('tickets')
          .update({'status': status})
          .eq('id', ticketId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Assign ticket to helpdesk
  static Future<bool> assignTicket(String ticketId, String helpdeskId) async {
    try {
      await SupabaseConfig.client
          .from('tickets')
          .update({
            'helpdesk_id': helpdeskId,
            'status': 'Diproses',
          })
          .eq('id', ticketId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete ticket (soft delete)
  static Future<bool> deleteTicket(String ticketId) async {
    try {
      await SupabaseConfig.client
          .from('tickets')
          .update({'is_deleted': true})
          .eq('id', ticketId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch comments for a ticket
  static Future<List<CommentModel>> fetchComments(String ticketId) async {
    final response = await SupabaseConfig.client
        .from('comments')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);
    return (response as List).map((e) => CommentModel.fromJson(e)).toList();
  }

  /// Add comment
  static Future<bool> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String content,
  }) async {
    try {
      await SupabaseConfig.client.from('comments').insert({
        'ticket_id': ticketId,
        'user_id': userId,
        'user_name': userName,
        'content': content,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch ticket history
  static Future<List<HistoryModel>> fetchHistory(String ticketId) async {
    final response = await SupabaseConfig.client
        .from('ticket_history')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);
    return (response as List).map((e) => HistoryModel.fromJson(e)).toList();
  }

  /// Add history entry
  static Future<bool> addHistory({
    required String ticketId,
    required String action,
    required String performedBy,
    required String performedByName,
  }) async {
    try {
      await SupabaseConfig.client.from('ticket_history').insert({
        'ticket_id': ticketId,
        'action': action,
        'performed_by': performedBy,
        'performed_by_name': performedByName,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get ticket statistics
  static Map<String, int> getStatistics(List<TicketModel> tickets) {
    return {
      'total': tickets.length,
      'Menunggu': tickets.where((t) => t.status == 'Menunggu').length,
      'Diproses': tickets.where((t) => t.status == 'Diproses').length,
      'Selesai': tickets.where((t) => t.status == 'Selesai').length,
    };
  }
}
