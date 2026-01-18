class Conversation {
  final int userId;
  final String userName;
  final String? userImage;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool lastMessageSentByMe;
  final bool lastMessageSeen;

  Conversation({
    required this.userId,
    required this.userName,
    this.userImage,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.lastSeen,
    this.lastMessageSentByMe = false,
    this.lastMessageSeen = false,
  });

  factory Conversation.fromMessages({
    required int currentUserId,
    required List<Map<String, dynamic>> messages,
  }) {
    if (messages.isEmpty) {
      throw Exception('Cannot create conversation from empty messages');
    }

    final firstMessage = messages.first;
    final int otherUserId = firstMessage['from_user_id'] == currentUserId
        ? firstMessage['to_user_id']
        : firstMessage['from_user_id'];

    final latestMessage = messages.last;
    final lastMessage = latestMessage['message'] as String?;
    final lastMessageTime = latestMessage['created_at'] != null
        ? DateTime.parse(latestMessage['created_at'] as String)
        : null;

    final lastMessageSentByMe = latestMessage['from_user_id'] == currentUserId;
    final lastMessageSeen = latestMessage['seen_at'] != null;

    int unreadCount = 0;
    for (final msg in messages) {
      if (msg['to_user_id'] == currentUserId) {
        final seenAt = msg['seen_at'];
        if (seenAt == null) {
          unreadCount++;
        }
      }
    }

    return Conversation(
      userId: otherUserId,
      userName: 'User $otherUserId',
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      lastMessageSentByMe: lastMessageSentByMe,
      lastMessageSeen: lastMessageSeen,
    );
  }

  Conversation copyWith({
    int? userId,
    String? userName,
    String? userImage,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isOnline,
    DateTime? lastSeen,
    bool? lastMessageSentByMe,
    bool? lastMessageSeen,
  }) {
    return Conversation(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      lastMessageSentByMe: lastMessageSentByMe ?? this.lastMessageSentByMe,
      lastMessageSeen: lastMessageSeen ?? this.lastMessageSeen,
    );
  }
}
