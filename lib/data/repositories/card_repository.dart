import '../models/business_card.dart';
import '../services/card_storage_service.dart';
import '../services/ocr_service.dart';
import '../services/business_card_parser.dart';
import '../services/api_service.dart';

class CardRepository {
  final CardStorageService _storageService;
  final OcrService _ocrService;
  final BusinessCardParser _parser;
  final ApiService _apiService = ApiService();

  CardRepository({
    CardStorageService? storageService,
    OcrService? ocrService,
    BusinessCardParser? parser,
  })  : _storageService = storageService ?? CardStorageService(),
      _ocrService = ocrService ?? OcrService(),
      _parser = parser ?? BusinessCardParser();

  // ── Auth-Aware Storage Operations ──

  Future<List<BusinessCard>> getAllCards() async {
    if (_apiService.hasToken) {
      try {
        final List<dynamic> jsonList = await _apiService.getCards();
        final List<BusinessCard> cards = jsonList
            .map((json) => BusinessCard.fromJson(json as Map<String, dynamic>))
            .toList();
            
        // Silently sync local cache
        await _storageService.syncCache(cards);
        return cards;
      } catch (e) {
        // Fallback to local storage on network failure
        print('CardRepository: Backend fetch failed, falling back to local cache: $e');
        return _storageService.fetchCards();
      }
    }
    // Default to local storage if unauthenticated
    return _storageService.fetchCards();
  }

  Future<void> saveCard(BusinessCard card) async {
    // Save locally first for responsiveness/offline support
    await _storageService.addCard(card);

    if (_apiService.hasToken) {
      try {
        await _apiService.createCard(card.toJson());
      } catch (e) {
        print('CardRepository: Failed to sync new card to backend: $e');
      }
    }
  }

  Future<void> updateCard(BusinessCard card) async {
    // Update locally first
    await _storageService.updateCard(card);

    if (_apiService.hasToken) {
      try {
        await _apiService.updateCard(card.id, card.toJson());
      } catch (e) {
        print('CardRepository: Failed to sync card update to backend: $e');
      }
    }
  }

  Future<void> deleteCard(String id) async {
    // Delete locally first
    await _storageService.deleteCard(id);

    if (_apiService.hasToken) {
      try {
        await _apiService.deleteCard(id);
      } catch (e) {
        print('CardRepository: Failed to sync card deletion to backend: $e');
      }
    }
  }

  // ── Personal Card Operations ──

  Future<BusinessCard?> getMyCard() => _storageService.fetchMyCard();

  Future<void> saveMyCard(BusinessCard card) => _storageService.saveMyCard(card);

  Future<void> deleteMyCard() => _storageService.deleteMyCard();

  // ── OCR Operations ──

  /// Process an image and return a parsed BusinessCard.
  Future<BusinessCard> processImage(String imagePath) async {
    final ocrLines = await _ocrService.recognizeText(imagePath);
    final card = _parser.parse(ocrLines);
    return card;
  }

  void dispose() {
    _ocrService.dispose();
  }
}
