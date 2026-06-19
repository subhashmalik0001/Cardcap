import 'package:flutter_test/flutter_test.dart';
import 'package:nebula/data/models/qr_card_payload.dart';

void main() {
  group('QrCardPayload Tests', () {
    test('Should serialize details to compact JSON format', () {
      final payload = QrCardPayload(
        version: 1,
        name: 'John Doe',
        title: 'Software Engineer',
        company: 'Acme Corp',
        phone: '+91-99999-88888',
        email: 'john@acme.com',
        website: 'https://acme.com',
        address: 'Delhi, India',
        linkedin: 'linkedin.com/in/johndoe',
        twitter: '@johndoe',
      );

      final json = payload.toJson();
      expect(json['v'], 1);
      expect(json['n'], 'John Doe');
      expect(json['t'], 'Software Engineer');
      expect(json['c'], 'Acme Corp');
      expect(json['p'], '+91-99999-88888');
      expect(json['e'], 'john@acme.com');
      expect(json['w'], 'https://acme.com');
      expect(json['a'], 'Delhi, India');
      expect(json['l'], 'linkedin.com/in/johndoe');
      expect(json['x'], '@johndoe');
    });

    test('Should generate valid nebula:// QR URI string', () {
      final payload = QrCardPayload(
        name: 'Jane Smith',
        title: 'Product Manager',
        email: 'jane@product.com',
      );

      final qrString = payload.toQrString();
      expect(qrString, startsWith('nebula://contact?v=1&data='));

      final parsed = QrCardPayload.tryParse(qrString);
      expect(parsed, isNotNull);
      expect(parsed!.name, 'Jane Smith');
      expect(parsed.title, 'Product Manager');
      expect(parsed.email, 'jane@product.com');
    });

    test('Should return null when parsing invalid scheme or data', () {
      expect(QrCardPayload.tryParse('invalid://contact'), isNull);
      expect(QrCardPayload.tryParse('nebula://contact?data=invalid_base64_!!!'), isNull);
      expect(QrCardPayload.tryParse('nebula://contact?v=1'), isNull);
    });

    test('Should convert payload to BusinessCard correctly', () {
      final payload = QrCardPayload(
        name: 'Alex Carter',
        title: 'Developer',
        company: 'Code Inc',
        phone: '1234567890',
        email: 'alex@code.com',
        website: 'code.com',
      );

      final businessCard = payload.toBusinessCard();
      expect(businessCard.name, 'Alex Carter');
      expect(businessCard.designation, 'Developer');
      expect(businessCard.company, 'Code Inc');
      expect(businessCard.phones.first, '1234567890');
      expect(businessCard.email, 'alex@code.com');
      expect(businessCard.website, 'code.com');
      expect(businessCard.source, 'qr');
      expect(businessCard.scanMethod, 'qr');
    });
  });
}
