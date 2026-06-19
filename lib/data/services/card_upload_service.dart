import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class CardUploadService {
  final _supabase = Supabase.instance.client;

  // Upload cropped card image to Supabase Storage
  // Returns public URL of uploaded image
  Future<String> uploadCardImage({
    required File imageFile,
    required String userId,
  }) async {
    final fileName = 'cards/${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final bytes = await imageFile.readAsBytes();

    await _supabase.storage
        .from('card-images') // Supabase storage bucket name
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    // Get public URL
    final publicUrl = _supabase.storage
        .from('card-images')
        .getPublicUrl(fileName);

    return publicUrl;
  }
}
