import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'business_card.dart';

class QrCardPayload {
  final int version;
  final String name;
  final String? title;
  final String? company;
  final String? phone;
  final String? email;
  final String? website;
  final String? address;
  final String? linkedin;
  final String? twitter;
  final String? cardImageUrl;

  QrCardPayload({
    this.version = 1,
    required this.name,
    this.title,
    this.company,
    this.phone,
    this.email,
    this.website,
    this.address,
    this.linkedin,
    this.twitter,
    this.cardImageUrl,
  });

  // Convert to compact JSON map (short keys to keep QR dense)
  Map<String, dynamic> toJson() => {
    'v': version,
    'n': name,
    if (title != null && title!.isNotEmpty) 't': title,
    if (company != null && company!.isNotEmpty) 'c': company,
    if (phone != null && phone!.isNotEmpty) 'p': phone,
    if (email != null && email!.isNotEmpty) 'e': email,
    if (website != null && website!.isNotEmpty) 'w': website,
    if (address != null && address!.isNotEmpty) 'a': address,
    if (linkedin != null && linkedin!.isNotEmpty) 'l': linkedin,
    if (twitter != null && twitter!.isNotEmpty) 'x': twitter,
    if (cardImageUrl != null && cardImageUrl!.isNotEmpty) 'u': cardImageUrl,
  };

  factory QrCardPayload.fromJson(Map<String, dynamic> json) => QrCardPayload(
    version: json['v'] ?? 1,
    name: json['n'] ?? '',
    title: json['t'],
    company: json['c'],
    phone: json['p'],
    email: json['e'],
    website: json['w'],
    address: json['a'],
    linkedin: json['l'],
    twitter: json['x'],
    cardImageUrl: json['u'],
  );

  // Encode full URI string for QR generation
  String toQrString() {
    final jsonStr = jsonEncode(toJson());
    final encoded = base64Url.encode(utf8.encode(jsonStr));
    return 'nebula://contact?v=$version&data=$encoded';
  }

  // Decode from a scanned QR string. Returns null if not a valid Nebula QR.
  static QrCardPayload? tryParse(String raw) {
    try {
      if (!raw.startsWith('nebula://contact')) return null;
      final uri = Uri.parse(raw);
      final dataParam = uri.queryParameters['data'];
      if (dataParam == null) return null;
      final decoded = utf8.decode(base64Url.decode(dataParam));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return QrCardPayload.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // Convert to BusinessCard model for saving to contacts/DB
  BusinessCard toBusinessCard() => BusinessCard(
    id: const Uuid().v4(),
    name: name,
    designation: title,
    company: company,
    phones: phone != null && phone!.isNotEmpty ? [phone!] : [],
    email: email,
    website: website,
    address: address,
    linkedin: linkedin,
    twitter: twitter,
    createdAt: DateTime.now(),
    cardImageUrl: cardImageUrl,
    scanMethod: 'qr',
    source: 'qr',
  );
}
