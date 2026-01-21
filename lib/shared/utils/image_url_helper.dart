import '../../app/constants/api_constants.dart';

class ImageUrlHelper {
  ImageUrlHelper._(); // private constructor

  static String resolveAvatarUrl(String? avatar) {
    if (avatar == null || avatar.isEmpty) return '';

    // If already full URL, return as-is
    if (avatar.startsWith('http')) {
      return avatar;
    }

    // Build full URL: baseUrl + /storage + avatar
    return '${ApiConstants.baseUrl.replaceAll('/api/v1', '')}/storage/$avatar';
  }
}
