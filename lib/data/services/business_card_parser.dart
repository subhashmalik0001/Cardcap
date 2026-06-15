import '../../core/constants/ocr_config.dart';
import '../../core/utils/format_utils.dart';
import '../models/business_card.dart';
import 'ocr_service.dart';
import 'package:uuid/uuid.dart';

class BusinessCardParser {
  static const _uuid = Uuid();

  /// Parse OCR lines into a structured BusinessCard.
  /// Uses a "claimed lines" set to prevent double-classification.
  BusinessCard parse(List<OcrLine> ocrLines) {
    final lines = ocrLines.toList();
    final claimed = <int>{};

    String? email;
    final phones = <String>[];
    String? website;
    String? linkedin;
    String? twitter;
    String? name;
    String? company;
    String? designation;
    String? address;

    // Step 1 — Email extraction
    email = _extractEmail(lines, claimed);

    // Step 2 — Phone extraction
    phones.addAll(_extractPhones(lines, claimed));

    // Step 3 — Website extraction
    website = _extractWebsite(lines, claimed);

    // Step 4 — LinkedIn
    linkedin = _extractLinkedin(lines, claimed);

    // Step 5 — Twitter
    twitter = _extractTwitter(lines, claimed);

    // Step 6 — Name detection
    name = _extractName(lines, claimed);

    // Step 7 — Company detection
    company = _extractCompany(lines, claimed);

    // Step 8 — Designation detection
    designation = _extractDesignation(lines, claimed, name);

    // Step 9 — Address
    address = _extractAddress(lines, claimed);

    return BusinessCard(
      id: _uuid.v4(),
      name: name,
      designation: designation,
      company: company,
      phones: phones,
      email: email,
      website: website,
      address: address,
      linkedin: linkedin,
      twitter: twitter,
      createdAt: DateTime.now(),
    );
  }

  /// Step 1: Extract email
  String? _extractEmail(List<OcrLine> lines, Set<int> claimed) {
    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final match = OcrConfig.emailRegex.firstMatch(lines[i].text);
      if (match != null) {
        claimed.add(i);
        return match.group(0);
      }
    }

    // Handle split emails (@ on separate line)
    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final text = lines[i].text.trim();
      if (text == '@' || text.startsWith('@') || text.endsWith('@')) {
        // Try to stitch with adjacent lines
        String stitched = text;
        if (text.endsWith('@') && i + 1 < lines.length) {
          stitched = text + lines[i + 1].text.trim();
        } else if (text.startsWith('@') && i > 0) {
          stitched = lines[i - 1].text.trim() + text;
        }
        final match = OcrConfig.emailRegex.firstMatch(stitched);
        if (match != null) {
          claimed.add(i);
          if (i + 1 < lines.length && text.endsWith('@')) claimed.add(i + 1);
          if (i > 0 && text.startsWith('@')) claimed.add(i - 1);
          return match.group(0);
        }
      }
    }
    return null;
  }

  /// Step 2: Extract phone numbers
  List<String> _extractPhones(List<OcrLine> lines, Set<int> claimed) {
    final phones = <String>[];
    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final text = lines[i].text;

      // Look for phone-like patterns
      final matches = OcrConfig.phoneDigitRun.allMatches(text);
      for (final match in matches) {
        final raw = match.group(0)!;
        final digits = raw.replaceAll(RegExp(r'[^\d]'), '');

        if (digits.length >= 10 && digits.length <= 15) {
          String formatted = raw.trim();

          // Format Indian mobile numbers
          if (digits.length == 10 &&
              OcrConfig.indianMobile.hasMatch(digits)) {
            formatted = FormatUtils.formatIndianMobile(digits);
          } else if (digits.length == 11 &&
              OcrConfig.indianLandline.hasMatch(digits)) {
            formatted = digits;
          } else if (raw.trim().startsWith('+')) {
            formatted = raw.trim();
          } else if (digits.length == 12 && digits.startsWith('91')) {
            formatted = FormatUtils.formatIndianMobile(digits.substring(2));
          }

          // Avoid adding duplicates
          if (!phones.contains(formatted)) {
            phones.add(formatted);
            claimed.add(i);
          }
        }
      }
    }
    return phones;
  }

  /// Step 3: Extract website
  String? _extractWebsite(List<OcrLine> lines, Set<int> claimed) {
    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final text = lines[i].text.toLowerCase().trim();

      final match = OcrConfig.websiteRegex.firstMatch(text);
      if (match != null) {
        final url = match.group(0)!;

        // Check blacklist
        bool isBlacklisted = OcrConfig.emailDomainBlacklist.any(
          (domain) => url.contains(domain),
        );
        if (isBlacklisted) continue;

        // Must not be part of an email
        if (text.contains('@')) continue;

        claimed.add(i);
        if (url.startsWith('http')) return url;
        return 'https://$url';
      }
    }
    return null;
  }

  /// Step 4: Extract LinkedIn
  String? _extractLinkedin(List<OcrLine> lines, Set<int> claimed) {
    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final match = OcrConfig.linkedinRegex.firstMatch(lines[i].text);
      if (match != null) {
        claimed.add(i);
        final url = match.group(0)!;
        return url.startsWith('http') ? url : 'https://$url';
      }
    }
    return null;
  }

  /// Step 5: Extract Twitter
  String? _extractTwitter(List<OcrLine> lines, Set<int> claimed) {
    // Check for twitter.com URLs first
    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final match = OcrConfig.twitterRegex.firstMatch(lines[i].text);
      if (match != null) {
        claimed.add(i);
        final url = match.group(0)!;
        return url.startsWith('http') ? url : 'https://$url';
      }
    }

    // Check for @handle (not email)
    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final text = lines[i].text.trim();
      if (text.contains('@') && !text.contains('.')) {
        final match = OcrConfig.twitterHandle.firstMatch(text);
        if (match != null) {
          claimed.add(i);
          return match.group(0);
        }
      }
    }
    return null;
  }

  /// Step 6: Name detection — largest font, 2-4 alphabetic words
  String? _extractName(List<OcrLine> lines, Set<int> claimed) {
    final candidates = <int, double>{};

    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final text = lines[i].text.trim();
      final words = text.split(RegExp(r'\s+'));

      // 2-4 words, alphabetic only, no digits
      if (words.length >= 1 &&
          words.length <= 5 &&
          !RegExp(r'\d').hasMatch(text) &&
          RegExp(r'^[a-zA-Z\s.\-]+$').hasMatch(text)) {
        // Must not contain designation keywords
        final lower = text.toLowerCase();
        bool hasDesignationKeyword = OcrConfig.designationKeywords.any(
          (k) => lower.contains(k),
        );
        bool hasCompanyKeyword = OcrConfig.companyKeywords.any(
          (k) => lower.contains(k),
        );
        if (!hasDesignationKeyword && !hasCompanyKeyword) {
          candidates[i] = lines[i].height;
        }
      }
    }

    if (candidates.isEmpty) return null;

    // Find the candidate with the largest font height
    final bestIdx = candidates.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    claimed.add(bestIdx);
    return FormatUtils.titleCase(lines[bestIdx].text.trim());
  }

  /// Step 7: Company detection
  String? _extractCompany(List<OcrLine> lines, Set<int> claimed) {
    // Look for lines with company keywords
    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final lower = lines[i].text.toLowerCase();
      final hasKeyword = OcrConfig.companyKeywords.any(
        (k) => lower.contains(k),
      );
      if (hasKeyword) {
        claimed.add(i);
        return lines[i].text.trim();
      }
    }

    // ALL-CAPS line in top 25% of card
    if (lines.isNotEmpty) {
      final maxY = lines.map((l) => l.y).reduce((a, b) => a > b ? a : b);
      final top25 = maxY * 0.25;
      for (int i = 0; i < lines.length; i++) {
        if (claimed.contains(i)) continue;
        final text = lines[i].text.trim();
        if (lines[i].y <= top25 &&
            text == text.toUpperCase() &&
            text.length > 3 &&
            RegExp(r'^[A-Z\s&.]+$').hasMatch(text)) {
          claimed.add(i);
          return text;
        }
      }
    }

    return null;
  }

  /// Step 8: Designation detection
  String? _extractDesignation(
    List<OcrLine> lines,
    Set<int> claimed,
    String? name,
  ) {
    // Line containing designation keywords
    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final lower = lines[i].text.toLowerCase();
      final hasKeyword = OcrConfig.designationKeywords.any(
        (k) => lower.contains(k),
      );
      if (hasKeyword) {
        claimed.add(i);
        return lines[i].text.trim();
      }
    }

    // Line directly below name (by Y position)
    if (name != null) {
      final nameIdx = lines.indexWhere(
        (l) => l.text.toLowerCase().contains(name.toLowerCase()),
      );
      if (nameIdx >= 0 && nameIdx + 1 < lines.length) {
        final nextIdx = nameIdx + 1;
        if (!claimed.contains(nextIdx)) {
          final text = lines[nextIdx].text.trim();
          if (!RegExp(r'\d').hasMatch(text) && text.length > 2) {
            claimed.add(nextIdx);
            return text;
          }
        }
      }
    }

    return null;
  }

  /// Step 9: Address extraction
  String? _extractAddress(List<OcrLine> lines, Set<int> claimed) {
    final addressParts = <String>[];

    for (int i = 0; i < lines.length; i++) {
      if (claimed.contains(i)) continue;
      final text = lines[i].text.trim();
      final lower = text.toLowerCase();

      bool hasAddressKeyword = OcrConfig.addressKeywords.any(
        (k) => lower.contains(k),
      );
      bool hasPinCode = OcrConfig.pinCode.hasMatch(text);

      if (hasAddressKeyword || hasPinCode) {
        claimed.add(i);
        addressParts.add(text);
      }
    }

    if (addressParts.isEmpty) return null;
    return addressParts.join(', ');
  }
}
