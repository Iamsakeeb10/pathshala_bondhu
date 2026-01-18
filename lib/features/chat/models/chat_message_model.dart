class ChatMessage {
  final int? id;
  final int fromUserId;
  final int toUserId;
  final String source;
  final String message;
  final DateTime createdAt;
  final bool isSent;
  final bool isSeen;

  ChatMessage({
    this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.source,
    required this.message,
    required this.createdAt,
    this.isSent = false,
    this.isSeen = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    bool isSeen = false;

    if (json.containsKey('is_seen')) {
      isSeen = json['is_seen'] as bool? ?? false;
    } else {
      final seenAt = json['seen_at'];
      isSeen = seenAt != null;
    }

    return ChatMessage(
      id: json['id'] as int?,
      fromUserId: json['from_user_id'] as int,
      toUserId: json['to_user_id'] as int,
      source: json['source'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isSent: json['is_sent'] as bool? ?? true,
      isSeen: isSeen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'source': source,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_sent': isSent,
      'is_seen': isSeen,
    };
  }

  ChatMessage copyWith({
    int? id,
    int? fromUserId,
    int? toUserId,
    String? source,
    String? message,
    DateTime? createdAt,
    bool? isSent,
    bool? isSeen,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      source: source ?? this.source,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isSent: isSent ?? this.isSent,
      isSeen: isSeen ?? this.isSeen,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, from: $fromUserId, to: $toUserId, message: $message, isSent: $isSent, isSeen: $isSeen)';
  }
}
