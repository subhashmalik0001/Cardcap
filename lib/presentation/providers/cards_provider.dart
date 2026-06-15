import 'package:flutter/foundation.dart';
import '../../data/models/business_card.dart';
import '../../data/repositories/card_repository.dart';

class CardsProvider extends ChangeNotifier {
  final CardRepository _repository;

  CardsProvider({CardRepository? repository})
      : _repository = repository ?? CardRepository();

  List<BusinessCard> _cards = [];
  List<BusinessCard> _filteredCards = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  BusinessCard? _myCard;

  // ── Getters ──

  List<BusinessCard> get cards => _cards;
  List<BusinessCard> get filteredCards =>
      _searchQuery.isEmpty ? _cards : _filteredCards;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get cardCount => _cards.length;
  BusinessCard? get myCard => _myCard;

  // ── Actions ──

  /// Load all cards from storage.
  Future<void> loadCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cards = await _repository.getAllCards();
      _applyFilter();
    } catch (e) {
      _error = 'Failed to load contacts: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new card.
  Future<void> addCard(BusinessCard card) async {
    try {
      await _repository.saveCard(card);
      _cards.insert(0, card);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save contact: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Delete a card by ID.
  Future<void> deleteCard(String id) async {
    try {
      await _repository.deleteCard(id);
      _cards.removeWhere((c) => c.id == id);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete contact: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update a card.
  Future<void> updateCard(BusinessCard card) async {
    try {
      await _repository.updateCard(card);
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index >= 0) {
        _cards[index] = card;
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update contact: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Set search query and filter cards.
  void setSearch(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// Clear any error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredCards = _cards;
      return;
    }
    final q = _searchQuery.toLowerCase();
    _filteredCards = _cards.where((card) {
      return (card.name?.toLowerCase().contains(q) ?? false) ||
          (card.company?.toLowerCase().contains(q) ?? false) ||
          (card.email?.toLowerCase().contains(q) ?? false) ||
          (card.designation?.toLowerCase().contains(q) ?? false) ||
          card.phones.any((p) => p.contains(q));
    }).toList();
  }

  // ── Personal Card (My Card) Actions ──

  Future<void> loadMyCard() async {
    try {
      _myCard = await _repository.getMyCard();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load personal card: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> saveMyCard(BusinessCard card) async {
    try {
      await _repository.saveMyCard(card);
      _myCard = card;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save personal card: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteMyCard() async {
    try {
      await _repository.deleteMyCard();
      _myCard = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete personal card: ${e.toString()}';
      notifyListeners();
    }
  }
}
