import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardDetectorService {
  final _textRecognizer = TextRecognizer();
  bool _isBusy = false;

  Future<CardDetectionResult?> detectCard(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_isBusy) return null;
    _isBusy = true;

    try {
      final inputImage = _buildInputImage(image, camera);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.blocks.isEmpty) {
        _isBusy = false;
        return null;
      }

      // Find bounding box that contains all text blocks
      final cardRect = _computeCardBoundingRect(recognizedText.blocks);

      // Validate card boundaries and aspect ratio
      if (_isValidCardRect(cardRect, recognizedText.blocks)) {
        _isBusy = false;
        return CardDetectionResult(
          boundingRect: cardRect,
          confidence: _computeConfidence(recognizedText.blocks),
          textBlocks: recognizedText.blocks,
        );
      }

      _isBusy = false;
      return null;
    } catch (e) {
      _isBusy = false;
      return null;
    }
  }

  Rect _computeCardBoundingRect(List<TextBlock> blocks) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = 0, maxY = 0;

    for (final block in blocks) {
      final bb = block.boundingBox;
      if (bb.left < minX) minX = bb.left;
      if (bb.top < minY) minY = bb.top;
      if (bb.right > maxX) maxX = bb.right;
      if (bb.bottom > maxY) maxY = bb.bottom;
    }

    // Add 8% padding around detected text area
    final padX = (maxX - minX) * 0.08;
    final padY = (maxY - minY) * 0.08;

    return Rect.fromLTRB(
      (minX - padX).clamp(0, double.infinity),
      (minY - padY).clamp(0, double.infinity),
      maxX + padX,
      maxY + padY,
    );
  }

  bool _isValidCardRect(Rect rect, List<TextBlock> blocks) {
    if (blocks.length < 2) return false; // Need multiple text elements
    final aspectRatio = rect.width / rect.height;
    // Handle both portrait and landscape orientation ratios
    final ratio = aspectRatio < 1.0 ? 1 / aspectRatio : aspectRatio;
    if (ratio < 1.3 || ratio > 2.5) return false; // Business card ratio check
    if (rect.width < 100 || rect.height < 60) return false; // Minimum size check
    return true;
  }

  double _computeConfidence(List<TextBlock> blocks) {
    if (blocks.length >= 5) return 0.95;
    if (blocks.length >= 3) return 0.80;
    return 0.65;
  }

  InputImage _buildInputImage(CameraImage image, CameraDescription camera) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final rotation = InputImageRotationValue.fromRawValue(
          camera.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;

    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  void dispose() => _textRecognizer.close();
}

class CardDetectionResult {
  final Rect boundingRect;
  final double confidence;
  final List<TextBlock> textBlocks;

  const CardDetectionResult({
    required this.boundingRect,
    required this.confidence,
    required this.textBlocks,
  });
}
