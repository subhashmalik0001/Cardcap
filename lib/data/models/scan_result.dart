import 'dart:io';
import 'business_card.dart';

class ScanResult {
  final File croppedCardFile;
  final BusinessCard parsedCard;

  const ScanResult({
    required this.croppedCardFile,
    required this.parsedCard,
  });
}
