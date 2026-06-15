import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/my_card_details.dart';
import '../../data/models/card_template.dart';
import '../../data/models/card_design.dart';
import '../../data/services/api_service.dart';

enum PhotoShape {
  circle,
  roundedSquare,
  square,
  hexagon,
  diamond,
}

class MyCardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  static const String _storageKey = 'card_capture_my_card_design';

  MyCardDetails? _details;
  CardTemplate _selectedTemplate = CardTemplate.templates.first;
  Map<String, Offset> _fieldPositions = {};
  PhotoShape _photoShape = PhotoShape.circle;
  File? _userPhoto;
  String? _photoUrl;
  Color _textColor = const Color(0xFF1D1D1D);
  Map<String, bool> _visibleFields = {
    'name': true,
    'title': true,
    'company': true,
    'phone': true,
    'email': true,
    'website': false,
    'address': false,
    'photo': false,
  };
  Uint8List? _savedCardImage;
  String? _cardImageUrl;
  String _cardRatio = 'standard'; // 'standard' (1.75:1) or 'square' (1:1)

  bool _isLoading = false;
  String? _error;

  // ── Getters ──
  bool get hasCard => _details != null;
  MyCardDetails? get details => _details;
  CardTemplate get template => _selectedTemplate;
  Map<String, Offset> get fieldPositions => _fieldPositions;
  PhotoShape get photoShape => _photoShape;
  File? get userPhoto => _userPhoto;
  String? get photoUrl => _photoUrl;
  Color get textColor => _textColor;
  Map<String, bool> get visibleFields => _visibleFields;
  Uint8List? get savedCardImage => _savedCardImage;
  String? get cardImageUrl => _cardImageUrl;
  String get cardRatio => _cardRatio;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load
  Future<void> init() async {
    await loadFromStorage();
    if (_apiService.hasToken) {
      await fetchFromServer();
    }
  }

  // ── Modifiers ──

  void updateDetails(MyCardDetails details) {
    _details = details;
    notifyListeners();
  }

  void selectTemplate(CardTemplate template) {
    _selectedTemplate = template;
    _textColor = template.defaultTextColor;
    notifyListeners();
  }

  void updateFieldPosition(String field, Offset position) {
    _fieldPositions[field] = position;
    notifyListeners();
  }

  void toggleField(String field, bool visible) {
    if (field == 'name') return; // Name is always required
    _visibleFields[field] = visible;
    notifyListeners();
  }

  void setPhotoShape(PhotoShape shape) {
    _photoShape = shape;
    notifyListeners();
  }

  void setPhoto(File photo) {
    _userPhoto = photo;
    _photoUrl = null; // Reset remote URL since we have a new local file
    _visibleFields['photo'] = true;
    notifyListeners();
  }

  void removePhoto() {
    _userPhoto = null;
    _photoUrl = null;
    _visibleFields['photo'] = false;
    notifyListeners();
  }

  void setTextColor(Color color) {
    _textColor = color;
    notifyListeners();
  }

  void setCardRatio(String ratio) {
    if (ratio == 'standard' || ratio == 'square') {
      _cardRatio = ratio;
      notifyListeners();
    }
  }

  // ── Storage Operations ──

  /// Persist the design locally to SharedPreferences
  Future<void> _persistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final Map<String, Map<String, double>> fieldPositionsJson = {};
      _fieldPositions.forEach((key, offset) {
        fieldPositionsJson[key] = {
          'dx': offset.dx,
          'dy': offset.dy,
        };
      });

      final design = CardDesign(
        details: _details ?? const MyCardDetails(name: ''),
        templateId: _selectedTemplate.id,
        fieldPositions: fieldPositionsJson,
        photoShape: _photoShape.name,
        photoPath: _userPhoto?.path,
        textColor: '0x${_textColor.value.toRadixString(16).toUpperCase()}',
        visibleFields: _visibleFields,
        cardImageUrl: _cardImageUrl,
        cardRatio: _cardRatio,
      );

      await prefs.setString(_storageKey, jsonEncode(design.toJson()));
      
      if (_savedCardImage != null) {
        await prefs.setString('${_storageKey}_image', base64Encode(_savedCardImage!));
      }
      if (_photoUrl != null) {
        await prefs.setString('${_storageKey}_photoUrl', _photoUrl!);
      }
    } catch (e) {
      print('MyCardProvider: Failed to persist to local storage: $e');
    }
  }

  /// Load the design from SharedPreferences
  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final designString = prefs.getString(_storageKey);
      
      if (designString != null && designString.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(designString);
        final design = CardDesign.fromJson(json);

        _details = design.details.name.isEmpty ? null : design.details;
        _selectedTemplate = CardTemplate.templates.firstWhere(
          (t) => t.id == design.templateId,
          orElse: () => CardTemplate.templates.first,
        );

        _fieldPositions = {};
        design.fieldPositions.forEach((key, val) {
          _fieldPositions[key] = Offset(val['dx'] ?? 0.0, val['dy'] ?? 0.0);
        });

        _photoShape = PhotoShape.values.firstWhere(
          (s) => s.name == design.photoShape,
          orElse: () => PhotoShape.circle,
        );

        if (design.photoPath != null && design.photoPath!.isNotEmpty) {
          final file = File(design.photoPath!);
          if (await file.exists()) {
            _userPhoto = file;
          }
        }

        final hexColor = design.textColor.replaceAll('0x', '');
        _textColor = Color(int.parse(hexColor, radix: 16));

        _visibleFields = Map<String, bool>.from(design.visibleFields);
        _cardImageUrl = design.cardImageUrl;
        _cardRatio = design.cardRatio;

        final imageString = prefs.getString('${_storageKey}_image');
        if (imageString != null && imageString.isNotEmpty) {
          _savedCardImage = base64Decode(imageString);
        }

        _photoUrl = prefs.getString('${_storageKey}_photoUrl');
        notifyListeners();
      }
    } catch (e) {
      print('MyCardProvider: Failed to load from local storage: $e');
    }
  }

  /// Fetch personal card details from the Supabase Express API
  Future<void> fetchFromServer() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMyCard();

      final cardData = response['card'];
      if (cardData != null) {
        _details = MyCardDetails.fromJson(cardData['details'] as Map<String, dynamic>);
        
        final templateId = cardData['template_id'] as String? ?? 'classic';
        _selectedTemplate = CardTemplate.templates.firstWhere(
          (t) => t.id == templateId,
          orElse: () => CardTemplate.templates.first,
        );

        // Parse positions
        _fieldPositions = {};
        final rawPositions = cardData['field_positions'] as Map<String, dynamic>? ?? {};
        rawPositions.forEach((key, val) {
          if (val is Map) {
            _fieldPositions[key] = Offset(
              (val['dx'] as num?)?.toDouble() ?? 0.0,
              (val['dy'] as num?)?.toDouble() ?? 0.0,
            );
          }
        });

        // Shape
        final shapeStr = cardData['photo_shape'] as String? ?? 'circle';
        _photoShape = PhotoShape.values.firstWhere(
          (s) => s.name == shapeStr,
          orElse: () => PhotoShape.circle,
        );

        // Photo URL
        _photoUrl = cardData['photo_url'] as String?;
        _userPhoto = null; // Clear local file if we have remote URL

        // Color
        final hexColor = (cardData['text_color'] as String? ?? '0xFF1D1D1D').replaceAll('0x', '');
        _textColor = Color(int.parse(hexColor, radix: 16));

        // Visibility
        _visibleFields = {
          'name': true,
          'title': true,
          'company': true,
          'phone': true,
          'email': true,
          'website': false,
          'address': false,
          'photo': false,
        };
        final rawVisible = cardData['visible_fields'] as Map<String, dynamic>? ?? {};
        rawVisible.forEach((key, val) {
          _visibleFields[key] = val as bool? ?? false;
        });

        // Snapshots
        _cardImageUrl = cardData['card_image_url'] as String?;
        _cardRatio = cardData['card_ratio'] as String? ?? 'standard';

        // Update local SharedPreferences Cache
        await _persistToStorage();
      }
    } catch (e) {
      _error = e.toString();
      print('MyCardProvider: fetchFromServer error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save personal card layout, snapshot images, and contact form info
  Future<void> saveCard({
    required MyCardDetails details,
    required Uint8List cardImageBytes,
  }) async {
    _isLoading = true;
    _error = null;
    _details = details;
    _savedCardImage = cardImageBytes;
    notifyListeners();

    try {
      // 1. Save locally first for offline availability
      await _persistToStorage();

      // 2. Sync to Server if authenticated
      if (_apiService.hasToken) {
        String? photoBase64;
        if (_userPhoto != null) {
          final bytes = await _userPhoto!.readAsBytes();
          photoBase64 = base64Encode(bytes);
        }

        final cardImageBase64 = base64Encode(cardImageBytes);

        final Map<String, Map<String, double>> fieldPositionsJson = {};
        _fieldPositions.forEach((key, offset) {
          fieldPositionsJson[key] = {
            'dx': offset.dx,
            'dy': offset.dy,
          };
        });

        final body = {
          'details': details.toJson(),
          'templateId': _selectedTemplate.id,
          'fieldPositions': fieldPositionsJson,
          'photoShape': _photoShape.name,
          'textColor': '0x${_textColor.value.toRadixString(16).toUpperCase()}',
          'visibleFields': _visibleFields,
          'cardRatio': _cardRatio,
          if (photoBase64 != null) 'photoBase64': photoBase64,
          if (_photoUrl != null) 'photoUrl': _photoUrl,
          'cardImageBase64': cardImageBase64,
        };

        final response = await _apiService.saveMyCard(body);

        final cardData = response['card'];
        if (cardData != null) {
          _photoUrl = cardData['photo_url'] as String?;
          _cardImageUrl = cardData['card_image_url'] as String?;
          _userPhoto = null; // Remote URL replaces local file

          // Re-persist with the backend image URLs included
          await _persistToStorage();
        }
      }
    } catch (e) {
      _error = e.toString();
      print('MyCardProvider: saveCard error: $e');
      throw Exception('Failed to sync card to server: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete card design and clear local and remote storage
  Future<void> deleteCard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Delete locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove('${_storageKey}_image');
      await prefs.remove('${_storageKey}_photoUrl');

      _details = null;
      _userPhoto = null;
      _photoUrl = null;
      _savedCardImage = null;
      _cardImageUrl = null;
      _textColor = const Color(0xFF1D1D1D);
      _fieldPositions = {};
      _photoShape = PhotoShape.circle;
      _visibleFields = {
        'name': true,
        'title': true,
        'company': true,
        'phone': true,
        'email': true,
        'website': false,
        'address': false,
        'photo': false,
      };

      // 2. Delete on Server if authenticated
      if (_apiService.hasToken) {
        await _apiService.deleteMyCard();
      }
    } catch (e) {
      _error = e.toString();
      print('MyCardProvider: deleteCard error: $e');
      throw Exception('Failed to delete card: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
