class UserActivity {
  final int userId;
  final bool isActive;
  final DateTime? lastSeen;
  final int? typingToUserId;

  UserActivity({
    required this.userId,
    required this.isActive,
    this.lastSeen,
    this.typingToUserId,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      userId: json['user_id'] as int,
      isActive: json['is_active'] as bool? ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      typingToUserId: json['typing_to_user_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'is_active': isActive,
      if (lastSeen != null) 'last_seen': lastSeen!.toIso8601String(),
      if (typingToUserId != null) 'typing_to_user_id': typingToUserId,
    };
  }

  UserActivity copyWith({
    int? userId,
    bool? isActive,
    DateTime? lastSeen,
    int? typingToUserId,
  }) {
    return UserActivity(
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      lastSeen: lastSeen ?? this.lastSeen,
      typingToUserId: typingToUserId ?? this.typingToUserId,
    );
  }

  @override
  String toString() {
    return 'UserActivity(userId: $userId, isActive: $isActive, lastSeen: $lastSeen, typingToUserId: $typingToUserId)';
  }
}
