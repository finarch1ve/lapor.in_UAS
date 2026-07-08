/// History Model for tracking ticket activities
class HistoryModel {
  final String id;
  final String ticketId;
  final String action;
  final String performedBy;
  final String performedByName;
  final DateTime createdAt;

  HistoryModel({
    required this.id,
    required this.ticketId,
    required this.action,
    required this.performedBy,
    required this.performedByName,
    required this.createdAt,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String,
      action: json['action'] as String,
      performedBy: json['performed_by'] as String,
      performedByName: json['performed_by_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'action': action,
      'performed_by': performedBy,
      'performed_by_name': performedByName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Format time for display
  String get formattedTime {
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
