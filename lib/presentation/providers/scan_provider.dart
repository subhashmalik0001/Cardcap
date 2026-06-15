import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/business_card.dart';
import '../../data/repositories/card_repository.dart';

enum ScanState { idle, capturing, enhancing, ocr, parsing, done, error }

class ScanProvider extends ChangeNotifier {
  final CardRepository _repository;
  final ImagePicker _picker = ImagePicker();

  ScanProvider({CardRepository? repository})
      : _repository = repository ?? CardRepository();

  String? _capturedImagePath;
  ScanState _state = ScanState.idle;
  BusinessCard? _parsedCard;
  String? _errorMessage;

  // ── Getters ──

  String? get capturedImagePath => _capturedImagePath;
  ScanState get state => _state;
  BusinessCard? get parsedCard => _parsedCard;
  String? get errorMessage => _errorMessage;
  bool get isProcessing =>
      _state == ScanState.enhancing ||
      _state == ScanState.ocr ||
      _state == ScanState.parsing;

  // ── Actions ──

  /// Capture from camera.
  Future<void> captureFromCamera() async {
    _state = ScanState.capturing;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 95,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (photo == null) {
        _state = ScanState.idle;
        notifyListeners();
        return;
      }

      _capturedImagePath = photo.path;
      notifyListeners();

      await _processImage(photo.path);
    } catch (e) {
      _state = ScanState.error;
      _errorMessage = 'Camera capture failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Pick from gallery.
  Future<void> pickFromGallery() async {
    _state = ScanState.capturing;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (image == null) {
        _state = ScanState.idle;
        notifyListeners();
        return;
      }

      _capturedImagePath = image.path;
      notifyListeners();

      await _processImage(image.path);
    } catch (e) {
      _state = ScanState.error;
      _errorMessage = 'Gallery import failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Process the captured image through OCR pipeline.
  Future<void> _processImage(String imagePath) async {
    try {
      // Step 1: Enhancing
      _state = ScanState.enhancing;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));

      // Step 2: OCR
      _state = ScanState.ocr;
      notifyListeners();

      // Step 3: Parsing (combined with OCR processing)
      _state = ScanState.parsing;
      notifyListeners();

      final card = await _repository.processImage(imagePath);

      _parsedCard = card;
      _state = ScanState.done;
      notifyListeners();
    } catch (e) {
      _state = ScanState.error;
      _errorMessage = 'OCR processing failed: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Reset the scan state.
  void reset() {
    _capturedImagePath = null;
    _state = ScanState.idle;
    _parsedCard = null;
    _errorMessage = null;
    notifyListeners();
  }
}
