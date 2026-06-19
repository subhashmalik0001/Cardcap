import 'ocr_service.dart';

class CardOcrService {
  final OcrService _ocrService = OcrService();

  /// Extracts OCR lines from the given image path using multi-pass recognition.
  Future<List<OcrLine>> extractOcrLines(String path) async {
    return _ocrService.recognizeText(path);
  }

  void dispose() {
    _ocrService.dispose();
  }
}
