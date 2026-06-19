import '../models/my_card_details.dart';
import '../models/qr_card_payload.dart';

class QrCardService {
  
  // Build the QR payload from the user's saved MyCardDetails
  QrCardPayload buildPayloadFromDetails(MyCardDetails details) {
    return QrCardPayload(
      name: details.name,
      title: details.title,
      company: details.company,
      phone: details.phone,
      email: details.email,
      website: details.website,
      address: details.address,
    );
  }

  // Generates the raw string to feed into QrImageView
  String generateQrString(MyCardDetails details) {
    return buildPayloadFromDetails(details).toQrString();
  }

  // Validate QR data size — QR codes have a data capacity limit
  // If payload too large, trim address/website to keep QR scannable
  String generateSafeQrString(MyCardDetails details) {
    var payload = buildPayloadFromDetails(details);
    var qrString = payload.toQrString();
    
    // QR alphanumeric practical limit ~800 chars for reliable scanning
    if (qrString.length > 800) {
      // Trim address first (least critical for quick-save)
      payload = QrCardPayload(
        name: payload.name,
        title: payload.title,
        company: payload.company,
        phone: payload.phone,
        email: payload.email,
        website: payload.website,
        address: null,  // drop address if too long
      );
      qrString = payload.toQrString();
    }
    
    // If still too long, drop website
    if (qrString.length > 800) {
      payload = QrCardPayload(
        name: payload.name,
        title: payload.title,
        company: payload.company,
        phone: payload.phone,
        email: payload.email,
        website: null,
        address: null,
      );
      qrString = payload.toQrString();
    }
    
    return qrString;
  }
}
