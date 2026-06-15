import 'package:flutter/services.dart';
import 'image_enhancement_service.dart';

/// Represents a single OCR-detected line with position data.
class OcrLine {
  final String text;
  final double x;
  final double y;
  final double height;
  final double width;

  const OcrLine({
    required this.text,
    required this.x,
    required this.y,
    required this.height,
    required this.width,
  });

  @override
  String toString() => 'OcrLine("$text", y=$y, h=$height)';
}

class OcrService {
  final ImageEnhancementService _imageService = ImageEnhancementService();
  static const MethodChannel _channel = MethodChannel('com.cardcapture.cardCapture/ocr');

  /// Multi-pass OCR strategy:
  /// Pass 1: Original enhanced image
  /// Pass 2: JPEG re-encoded at 100% quality (contrast boost)
  /// Pass 3: Resized to 900×900 PNG (sharpness)
  /// Merge all TextBlock results, deduplicate by text similarity,
  /// sort by Y then X position.
  Future<List<OcrLine>> recognizeText(String imagePath) async {
    final tempFiles = <String>[];
    try {
      // Prepare enhanced versions
      final enhancedPath = await _imageService.enhanceImage(imagePath);
      tempFiles.add(enhancedPath);

      final hqJpegPath = await _imageService.createHighQualityJpeg(imagePath);
      tempFiles.add(hqJpegPath);

      final sharpPngPath = await _imageService.createSharpnessPng(imagePath);
      tempFiles.add(sharpPngPath);

      // Run OCR on all three variants
      final allLines = <OcrLine>[];

      for (final path in [enhancedPath, hqJpegPath, sharpPngPath]) {
        final lines = await _runOcrOnFile(path);
        allLines.addAll(lines);
      }

      // Deduplicate by normalized text similarity
      final deduped = _deduplicateLines(allLines);

      // Sort by Y position then X
      deduped.sort((a, b) {
        final yDiff = a.y - b.y;
        if (yDiff.abs() < 10) {
          return a.x.compareTo(b.x);
        }
        return yDiff.toInt();
      });

      return deduped;
    } finally {
      // Clean up temp files
      await _imageService.cleanupTempFiles(tempFiles);
    }
  }

  Future<List<OcrLine>> _runOcrOnFile(String filePath) async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('recognizeText', {
        'imagePath': filePath,
      });

      if (result == null) return [];

      final lines = <OcrLine>[];
      for (final item in result) {
        final map = Map<String, dynamic>.from(item);
        lines.add(OcrLine(
          text: map['text'] as String,
          x: (map['x'] as num).toDouble(),
          y: (map['y'] as num).toDouble(),
          width: (map['width'] as num).toDouble(),
          height: (map['height'] as num).toDouble(),
        ));
      }
      return lines;
    } on PlatformException catch (e) {
      print("Native Vision OCR failed: ${e.message}");
      return [];
    }
  }

  List<OcrLine> _deduplicateLines(List<OcrLine> lines) {
    final result = <OcrLine>[];
    for (final line in lines) {
      final normalized = _normalize(line.text);
      bool isDuplicate = false;
      for (final existing in result) {
        if (_isSimilar(normalized, _normalize(existing.text))) {
          // Keep the one with longer text (more data)
          if (line.text.length > existing.text.length) {
            result.remove(existing);
            result.add(line);
          }
          isDuplicate = true;
          break;
        }
      }
      if (!isDuplicate) {
        result.add(line);
      }
    }
    return result;
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9@.+]'), '')
        .trim();
  }

  bool _isSimilar(String a, String b) {
    if (a == b) return true;
    if (a.isEmpty || b.isEmpty) return false;
    // Check if one contains the other
    if (a.contains(b) || b.contains(a)) return true;
    // Levenshtein distance check for short strings
    if (a.length < 5 || b.length < 5) return false;
    final maxLen = a.length > b.length ? a.length : b.length;
    final distance = _levenshtein(a, b);
    return distance / maxLen < 0.2; // 80% similarity
  }

  int _levenshtein(String a, String b) {
    final la = a.length;
    final lb = b.length;
    final d = List.generate(la + 1, (_) => List.filled(lb + 1, 0));
    for (int i = 0; i <= la; i++) d[i][0] = i;
    for (int j = 0; j <= lb; j++) d[0][j] = j;
    for (int i = 1; i <= la; i++) {
      for (int j = 1; j <= lb; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1,
          d[i][j - 1] + 1,
          d[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return d[la][lb];
  }

  void dispose() {}
}
