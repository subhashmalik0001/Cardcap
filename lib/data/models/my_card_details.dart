class MyCardDetails {
  final String name;
  final String? title;
  final String? company;
  final String? phone;
  final String? email;
  final String? website;
  final String? address;

  const MyCardDetails({
    required this.name,
    this.title,
    this.company,
    this.phone,
    this.email,
    this.website,
    this.address,
  });

  MyCardDetails copyWith({
    String? name,
    String? title,
    String? company,
    String? phone,
    String? email,
    String? website,
    String? address,
  }) {
    return MyCardDetails(
      name: name ?? this.name,
      title: title ?? this.title,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
      'company': company,
      'phone': phone,
      'email': email,
      'website': website,
      'address': address,
    };
  }

  factory MyCardDetails.fromJson(Map<String, dynamic> json) {
    return MyCardDetails(
      name: json['name'] as String? ?? '',
      title: json['title'] as String?,
      company: json['company'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      address: json['address'] as String?,
    );
  }
}
