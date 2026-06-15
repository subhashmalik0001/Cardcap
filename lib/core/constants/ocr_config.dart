class OcrConfig {
  OcrConfig._();

  /// Minimum confidence threshold for OCR text blocks (0.0 to 1.0).
  static const double confidenceThreshold = 0.65;

  /// Max image dimension for OCR processing.
  static const int maxImageDimension = 1280;

  /// JPEG quality for re-encoded pass.
  static const int jpegQuality = 100;

  /// Resized dimension for sharpness pass.
  static const int sharpnessPassSize = 900;

  /// Email regex pattern.
  static final RegExp emailRegex = RegExp(
    r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
  );

  /// Phone digit run pattern (10–15 digits, possibly with separators).
  static final RegExp phoneDigitRun = RegExp(
    r'[\+]?[\d\s\-\(\)\.]{10,20}',
  );

  /// Indian mobile: starts with 6/7/8/9, 10 digits.
  static final RegExp indianMobile = RegExp(r'^[6789]\d{9}$');

  /// Landline: starts with 0 + 10 digits.
  static final RegExp indianLandline = RegExp(r'^0\d{10}$');

  /// International: starts with +.
  static final RegExp internationalPhone = RegExp(r'^\+\d{10,15}$');

  /// Website domain regex.
  static final RegExp websiteRegex = RegExp(
    r'(?:https?://)?(?:www\.)?[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}(?:/[^\s]*)?',
    caseSensitive: false,
  );

  /// LinkedIn profile regex.
  static final RegExp linkedinRegex = RegExp(
    r'linkedin\.com/in/[\w\-]+',
    caseSensitive: false,
  );

  /// Twitter profile regex.
  static final RegExp twitterRegex = RegExp(
    r'(?:twitter\.com|x\.com)/[\w]+',
    caseSensitive: false,
  );

  /// Twitter handle regex (not email).
  static final RegExp twitterHandle = RegExp(
    r'(?<!\S)@[a-zA-Z]\w{1,14}(?!\S)',
  );

  /// PIN code (Indian 6-digit).
  static final RegExp pinCode = RegExp(r'\b\d{6}\b');

  /// Email domain blacklist (not websites).
  static const List<String> emailDomainBlacklist = [
    'gmail.com',
    'yahoo.com',
    'hotmail.com',
    'outlook.com',
    'live.com',
    'icloud.com',
    'rediffmail.com',
    'aol.com',
  ];

  /// Company keywords for heuristic detection.
  static const List<String> companyKeywords = [
    'pvt',
    'ltd',
    'inc',
    'corp',
    'llc',
    'solutions',
    'technologies',
    'consulting',
    'services',
    'group',
    'associates',
    'enterprises',
    'systems',
    'digital',
    'agency',
    'studio',
    'labs',
    'foundation',
    'trust',
    'institute',
    'academy',
    'healthcare',
    'industries',
    'network',
    'limited',
    'private',
    'company',
    'corporation',
  ];

  /// Designation keywords for heuristic detection.
  static const List<String> designationKeywords = [
    'ceo',
    'cto',
    'cfo',
    'coo',
    'cmo',
    'founder',
    'co-founder',
    'director',
    'manager',
    'engineer',
    'developer',
    'designer',
    'consultant',
    'analyst',
    'architect',
    'officer',
    'president',
    'vice president',
    'vp',
    'head',
    'lead',
    'senior',
    'junior',
    'executive',
    'specialist',
    'associate',
    'partner',
    'coordinator',
    'administrator',
    'advisor',
    'strategist',
    'editor',
    'producer',
    'professor',
  ];

  /// Address keywords for heuristic detection.
  static const List<String> addressKeywords = [
    'street',
    'st.',
    'road',
    'rd.',
    'avenue',
    'ave.',
    'lane',
    'ln.',
    'nagar',
    'colony',
    'sector',
    'block',
    'phase',
    'area',
    'district',
    'city',
    'state',
    'floor',
    'building',
    'tower',
    'complex',
    'plaza',
    'near',
    'opposite',
    'pin',
    'pincode',
    'zip',
    'suite',
    'office',
    'plot',
    'no.',
  ];
}
