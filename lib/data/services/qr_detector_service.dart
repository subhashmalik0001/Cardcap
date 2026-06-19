import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../models/qr_card_payload.dart';

class QrDetectorService {
  final _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
  bool _isBusy = false;

  Future<QrCardPayload?> detectQr(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_isBusy) return null;
    _isBusy = true;

    try {
      final inputImage = _buildInputImage(image, camera);
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      _isBusy = false;

      if (barcodes.isEmpty) return null;

      for (final barcode in barcodes) {
        final rawValue = barcode.rawValue;
        if (rawValue != null) {
          final payload = QrCardPayload.tryParse(rawValue);
          if (payload != null) {
            return payload; // Found valid Nebula QR!
          }
        }
      }
      return null;
    } catch (e) {
      _isBusy = false;
      return null;
    }
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

  Future<QrCardPayload?> detectQrFromFile(String filePath) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isEmpty) return null;

      for (final barcode in barcodes) {
        final rawValue = barcode.rawValue;
        if (rawValue != null) {
          final payload = QrCardPayload.tryParse(rawValue);
          if (payload != null) {
            return payload; // Found valid Nebula QR!
          }
        }
      }
      return null;
    } catch (e) {
      print('QrDetectorService: Error processing static file: $e');
      return null;
    }
  }

  void dispose() => _barcodeScanner.close();
}
