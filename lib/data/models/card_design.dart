import 'my_card_details.dart';

class CardDesign {
  final MyCardDetails details;
  final String templateId;
  final Map<String, Map<String, double>> fieldPositions; // fieldKey -> {'dx': x, 'dy': y}
  final String photoShape;
  final String? photoPath; // Local path or remote URL
  final String textColor;  // Hex string representation
  final Map<String, bool> visibleFields;
  final String? cardImageUrl;
  final String cardRatio; // 'standard' (1.75:1) or 'square' (1:1)
  final double photoSize;
  final Map<String, double> textSizes;
  final bool showIcons;

  const CardDesign({
    required this.details,
    required this.templateId,
    required this.fieldPositions,
    required this.photoShape,
    this.photoPath,
    required this.textColor,
    required this.visibleFields,
    this.cardImageUrl,
    this.cardRatio = 'standard',
    this.photoSize = 56.0,
    this.textSizes = const {},
    this.showIcons = true,
  });

  CardDesign copyWith({
    MyCardDetails? details,
    String? templateId,
    Map<String, Map<String, double>>? fieldPositions,
    String? photoShape,
    String? photoPath,
    String? textColor,
    Map<String, bool>? visibleFields,
    String? cardImageUrl,
    String? cardRatio,
    double? photoSize,
    Map<String, double>? textSizes,
    bool? showIcons,
  }) {
    return CardDesign(
      details: details ?? this.details,
      templateId: templateId ?? this.templateId,
      fieldPositions: fieldPositions ?? this.fieldPositions,
      photoShape: photoShape ?? this.photoShape,
      photoPath: photoPath ?? this.photoPath,
      textColor: textColor ?? this.textColor,
      visibleFields: visibleFields ?? this.visibleFields,
      cardImageUrl: cardImageUrl ?? this.cardImageUrl,
      cardRatio: cardRatio ?? this.cardRatio,
      photoSize: photoSize ?? this.photoSize,
      textSizes: textSizes ?? this.textSizes,
      showIcons: showIcons ?? this.showIcons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'details': details.toJson(),
      'templateId': templateId,
      'fieldPositions': fieldPositions,
      'photoShape': photoShape,
      'photoPath': photoPath,
      'textColor': textColor,
      'visibleFields': visibleFields,
      'cardImageUrl': cardImageUrl,
      'cardRatio': cardRatio,
      'photoSize': photoSize,
      'textSizes': textSizes,
      'showIcons': showIcons,
    };
  }

  factory CardDesign.fromJson(Map<String, dynamic> json) {
    // Parse fieldPositions map safely
    final rawPositions = json['fieldPositions'] as Map<dynamic, dynamic>? ?? {};
    final Map<String, Map<String, double>> parsedPositions = {};
    rawPositions.forEach((key, val) {
      if (val is Map) {
        parsedPositions[key.toString()] = {
          'dx': (val['dx'] as num?)?.toDouble() ?? 0.0,
          'dy': (val['dy'] as num?)?.toDouble() ?? 0.0,
        };
      }
    });

    // Parse visibleFields map safely
    final rawVisible = json['visibleFields'] as Map<dynamic, dynamic>? ?? {};
    final Map<String, bool> parsedVisible = {};
    rawVisible.forEach((key, val) {
      parsedVisible[key.toString()] = val as bool? ?? false;
    });

    // Parse textSizes map safely
    final rawTextSizes = json['textSizes'] as Map<dynamic, dynamic>? ?? {};
    final Map<String, double> parsedTextSizes = {};
    rawTextSizes.forEach((key, val) {
      parsedTextSizes[key.toString()] = (val as num?)?.toDouble() ?? 11.0;
    });

    return CardDesign(
      details: MyCardDetails.fromJson(json['details'] as Map<String, dynamic>? ?? {}),
      templateId: json['templateId'] as String? ?? 'classic',
      fieldPositions: parsedPositions,
      photoShape: json['photoShape'] as String? ?? 'circle',
      photoPath: json['photoPath'] as String?,
      textColor: json['textColor'] as String? ?? '0xFF1D1D1D',
      visibleFields: parsedVisible,
      cardImageUrl: json['cardImageUrl'] as String?,
      cardRatio: json['cardRatio'] as String? ?? 'standard',
      photoSize: (json['photoSize'] as num?)?.toDouble() ?? 56.0,
      textSizes: parsedTextSizes,
      showIcons: json['showIcons'] as bool? ?? true,
    );
  }
}
