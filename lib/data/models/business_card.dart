import 'dart:convert';
import 'package:equatable/equatable.dart';

class BusinessCard extends Equatable {
  final String id;
  final String? name;
  final String? designation;
  final String? company;
  final List<String> phones;
  final String? email;
  final String? website;
  final String? address;
  final String? linkedin;
  final String? twitter;
  final String? notes;
  final DateTime createdAt;

  const BusinessCard({
    required this.id,
    this.name,
    this.designation,
    this.company,
    this.phones = const [],
    this.email,
    this.website,
    this.address,
    this.linkedin,
    this.twitter,
    this.notes,
    required this.createdAt,
  });

  BusinessCard copyWith({
    String? id,
    String? name,
    String? designation,
    String? company,
    List<String>? phones,
    String? email,
    String? website,
    String? address,
    String? linkedin,
    String? twitter,
    String? notes,
    DateTime? createdAt,
  }) {
    return BusinessCard(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      company: company ?? this.company,
      phones: phones ?? this.phones,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      linkedin: linkedin ?? this.linkedin,
      twitter: twitter ?? this.twitter,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'designation': designation,
      'company': company,
      'phones': phones,
      'email': email,
      'website': website,
      'address': address,
      'linkedin': linkedin,
      'twitter': twitter,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    return BusinessCard(
      id: json['id'] as String,
      name: json['name'] as String?,
      designation: json['designation'] as String?,
      company: json['company'] as String?,
      phones: (json['phones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
      linkedin: json['linkedin'] as String?,
      twitter: json['twitter'] as String?,
      notes: json['notes'] as String?,
      createdAt: rawCreatedAt != null 
          ? DateTime.parse(rawCreatedAt as String) 
          : DateTime.now(),
    );
  }


  String toJsonString() => jsonEncode(toJson());

  factory BusinessCard.fromJsonString(String source) =>
      BusinessCard.fromJson(jsonDecode(source) as Map<String, dynamic>);

  /// Returns true if the card has meaningful contact data.
  bool get hasContent =>
      (name != null && name!.isNotEmpty) ||
      (email != null && email!.isNotEmpty) ||
      phones.isNotEmpty;

  /// Returns a display name: name if available, or email, or phone, or "Unknown".
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (email != null && email!.isNotEmpty) return email!;
    if (phones.isNotEmpty) return phones.first;
    return 'Unknown';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        designation,
        company,
        phones,
        email,
        website,
        address,
        linkedin,
        twitter,
        notes,
        createdAt,
      ];
}
