import '../config/supabase_config.dart';
import 'dart:io';

/// Storage Service - For file uploads
class StorageService {
  static const String _ticketImagesBucket = 'ticket_images';
  static const String _userAvatarBucket = 'user_avatars';

  /// Upload ticket image
  static Future<String?> uploadTicketImage(String userId, File imageFile) async {
    try {
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final fileBytes = await imageFile.readAsBytes();

      await SupabaseConfig.client.storage
          .from(_ticketImagesBucket)
          .uploadBinary(fileName, fileBytes);

      // Get public URL
      final url = SupabaseConfig.client.storage
          .from(_ticketImagesBucket)
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      return null;
    }
  }

  /// Upload user avatar
  static Future<String?> uploadUserAvatar(String userId, File imageFile) async {
    try {
      final fileName = '$userId/avatar_${imageFile.path.split('/').last}';
      final fileBytes = await imageFile.readAsBytes();

      await SupabaseConfig.client.storage
          .from(_userAvatarBucket)
          .uploadBinary(fileName, fileBytes);

      final url = SupabaseConfig.client.storage
          .from(_userAvatarBucket)
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      return null;
    }
  }

  /// Delete ticket image
  static Future<bool> deleteTicketImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.last;
      await SupabaseConfig.client.storage
          .from(_ticketImagesBucket)
          .remove([path]);
      return true;
    } catch (e) {
      return false;
    }
  }
}
