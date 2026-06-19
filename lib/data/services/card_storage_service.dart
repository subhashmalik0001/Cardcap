import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/business_card.dart';

class CardStorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Fetch all saved cards, sorted by createdAt descending.
  Future<List<BusinessCard>> fetchCards() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(AppConstants.storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      final seed = _getSeedCards();
      await _saveCards(seed);
      return seed;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final cards = jsonList
          .map((json) => BusinessCard.fromJson(json as Map<String, dynamic>))
          .toList();
      cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return cards;
    } catch (e) {
      return [];
    }
  }

  List<BusinessCard> _getSeedCards() {
    final now = DateTime.now();
    return [
      BusinessCard(
        id: 'seed-1',
        name: 'Sofia Martinez',
        designation: 'Product Designer',
        company: 'Stripe',
        phones: const ['+1 (555) 019-2834'],
        email: 'sofia.m@stripe.com',
        website: 'stripe.com',
        address: '510 Townsend St, San Francisco, CA 94103',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      BusinessCard(
        id: 'seed-2',
        name: 'Edwards Vance',
        designation: 'VP of Engineering',
        company: 'Plaid',
        phones: const ['+1 (555) 048-1290'],
        email: 'edwards.vance@plaid.com',
        website: 'plaid.com',
        address: '950 Tennessee St, San Francisco, CA 94107',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      BusinessCard(
        id: 'seed-3',
        name: 'Warren Buffett',
        designation: 'Chairman & CEO',
        company: 'Berkshire',
        phones: const ['+1 (555) 001-9988'],
        email: 'warren@berkshire.com',
        website: 'berkshirehathaway.com',
        address: '3555 Farnam St, Omaha, NE 68131',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      BusinessCard(
        id: 'seed-4',
        name: 'Ingrid Bergman',
        designation: 'Chief Operations Officer',
        company: 'Revolut',
        phones: const ['+44 20 7946 0912'],
        email: 'ingrid.b@revolut.com',
        website: 'revolut.com',
        address: '7 Westferry Circus, London E14 4HD, UK',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      BusinessCard(
        id: 'seed-5',
        name: 'Aditya Sheral',
        designation: 'Founder & CEO',
        company: 'Nebula',
        phones: const ['+1 (555) 987-6543'],
        email: 'aditya@nebula.app',
        website: 'nebula.app',
        address: '100 Pin St, San Francisco, CA 94111',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }

  /// Add a new card (prepend to list).
  Future<void> addCard(BusinessCard card) async {
    final cards = await fetchCards();
    cards.insert(0, card);
    await _saveCards(cards);
  }

  /// Update an existing card by ID.
  Future<void> updateCard(BusinessCard card) async {
    final cards = await fetchCards();
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index >= 0) {
      cards[index] = card;
      await _saveCards(cards);
    }
  }

  /// Delete a card by ID.
  Future<void> deleteCard(String id) async {
    final cards = await fetchCards();
    cards.removeWhere((c) => c.id == id);
    await _saveCards(cards);
  }

  /// Get a single card by ID.
  Future<BusinessCard?> getCard(String id) async {
    final cards = await fetchCards();
    try {
      return cards.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCards(List<BusinessCard> cards) async {
    final prefs = await _preferences;
    final jsonList = cards.map((c) => c.toJson()).toList();
    await prefs.setString(AppConstants.storageKey, jsonEncode(jsonList));
  }

  /// Synchronize the local cache with backend cards directly.
  Future<void> syncCache(List<BusinessCard> cards) async {
    await _saveCards(cards);
  }


  // ── Personal Card (My Card) Storage ──

  static const String _myCardKey = 'card_capture_my_card';

  Future<BusinessCard?> fetchMyCard() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_myCardKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return BusinessCard.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveMyCard(BusinessCard card) async {
    final prefs = await _preferences;
    await prefs.setString(_myCardKey, jsonEncode(card.toJson()));
  }

  Future<void> deleteMyCard() async {
    final prefs = await _preferences;
    await prefs.remove(_myCardKey);
  }
}
