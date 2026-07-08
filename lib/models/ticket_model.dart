/// Ticket Model
class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status; // 'Menunggu', 'Diproses', 'Selesai'
  final String category; // 'Hardware', 'Software', 'Network', 'Lainnya'
  final String userId;
  final String? helpdeskId;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.userId,
    this.helpdeskId,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      category: json['category'] as String,
      userId: json['user_id'] as String,
      helpdeskId: json['helpdesk_id'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'category': category,
      'user_id': userId,
      'helpdesk_id': helpdeskId,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? category,
    String? userId,
    String? helpdeskId,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      helpdeskId: helpdeskId ?? this.helpdeskId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Format date for display
  String get formattedDate {
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  // Display ID
  String get displayId => '#${id.substring(0, 8).toUpperCase()}';
}
