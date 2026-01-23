/// Model to hold user display information for chat screens
class ChatUser {
  final int id;
  final String name;
  final String? imageUrl;

  ChatUser({required this.id, required this.name, this.imageUrl});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    // 1. Try to get image from flat 'image_url' (Cache format)
    String? imageUrl = json['image_url'] as String?;

    // 2. Try to get from 'avatar' field (User details API format)
    if (imageUrl == null) {
      imageUrl = json['avatar'] as String?;
    }

    // 3. If null, try to extract from 'images' array (API format)
    if (imageUrl == null) {
      final images = json['images'] as List<dynamic>?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images.first;
        if (firstImage is Map<String, dynamic>) {
          imageUrl = firstImage['url'] as String?;
        } else if (firstImage is String) {
          imageUrl = firstImage;
        }
      }
    }

    return ChatUser(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image_url': imageUrl};
  }
}
