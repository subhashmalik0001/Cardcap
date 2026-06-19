import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class CardCropperService {
  Future<File> cropCard({
    required String imagePath,
    required Rect normalizedRect, // 0.0–1.0 normalized coordinates
  }) async {
    // Load full image
    final bytes = await File(imagePath).readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) {
      throw Exception('Failed to decode card image');
    }

    // Auto-rotate based on EXIF orientation
    originalImage = img.bakeOrientation(originalImage);

    final imgWidth = originalImage.width;
    final imgHeight = originalImage.height;

    // Convert normalized rect to pixel coordinates
    final x = (normalizedRect.left * imgWidth).toInt();
    final y = (normalizedRect.top * imgHeight).toInt();
    final w = (normalizedRect.width * imgWidth).toInt();
    final h = (normalizedRect.height * imgHeight).toInt();

    // Add padding (5% on each side)
    final padX = (w * 0.05).toInt();
    final padY = (h * 0.05).toInt();

    final cropX = (x - padX).clamp(0, imgWidth);
    final cropY = (y - padY).clamp(0, imgHeight);
    final cropW = (w + padX * 2).clamp(0, imgWidth - cropX);
    final cropH = (h + padY * 2).clamp(0, imgHeight - cropY);

    // Crop
    final cropped = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    // Enhance: increase contrast and brightness slightly for better OCR
    final enhanced = img.adjustColor(
      cropped,
      contrast: 1.15,
      brightness: 1.05,
    );

    // Save cropped image to temp directory
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/card_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(img.encodeJpg(enhanced, quality: 95));

    return outputFile;
  }
}
