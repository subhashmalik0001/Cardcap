import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageEnhancementService {
  /// Enhance the image for OCR processing.
  /// 1. Resize to max 1280×1280 preserving aspect ratio
  /// 2. Auto-rotate using EXIF
  /// 3. Save to temp directory
  /// Returns new file path.
  Future<String> enhanceImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();

    // Decode image (handles EXIF auto-rotation)
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Auto-rotate based on EXIF orientation
    image = img.bakeOrientation(image);

    // Resize to max 1280×1280 preserving aspect ratio
    const maxDim = 1280;
    if (image.width > maxDim || image.height > maxDim) {
      if (image.width > image.height) {
        image = img.copyResize(image, width: maxDim);
      } else {
        image = img.copyResize(image, height: maxDim);
      }
    }

    // Enhance contrast slightly for better OCR
    image = img.adjustColor(image, contrast: 1.1);

    // Save enhanced image to temp directory
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final enhancedPath = path.join(tempDir.path, 'enhanced_$timestamp.jpg');
    final enhancedFile = File(enhancedPath);
    await enhancedFile.writeAsBytes(img.encodeJpg(image, quality: 95));

    return enhancedPath;
  }

  /// Create a high-quality JPEG re-encode for OCR pass 2.
  Future<String> createHighQualityJpeg(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception('Failed to decode image');

    image = img.bakeOrientation(image);
    image = img.adjustColor(image, contrast: 1.15, brightness: 1.05);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final jpegPath = path.join(tempDir.path, 'hq_$timestamp.jpg');
    await File(jpegPath).writeAsBytes(img.encodeJpg(image, quality: 100));

    return jpegPath;
  }

  /// Create a resized PNG for OCR pass 3 (sharpness).
  Future<String> createSharpnessPng(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception('Failed to decode image');

    image = img.bakeOrientation(image);

    // Resize to 900×900 max
    const targetSize = 900;
    if (image.width > targetSize || image.height > targetSize) {
      if (image.width > image.height) {
        image = img.copyResize(image, width: targetSize);
      } else {
        image = img.copyResize(image, height: targetSize);
      }
    }

    // Sharpen
    image = img.adjustColor(image, contrast: 1.2);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final pngPath = path.join(tempDir.path, 'sharp_$timestamp.png');
    await File(pngPath).writeAsBytes(img.encodePng(image));

    return pngPath;
  }

  /// Clean up temp files.
  Future<void> cleanupTempFiles(List<String> paths) async {
    for (final p in paths) {
      try {
        final file = File(p);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Silently ignore cleanup errors
      }
    }
  }
}
