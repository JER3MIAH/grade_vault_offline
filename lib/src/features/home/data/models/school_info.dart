import 'package:grade_vault_offline/src/features/home/data/models/models.dart'
    show GradingSystem, ContactInfo;

class SchoolInfo {
  final String name;
  final String motto;
  final String address;
  final String? logoPath;
  final List<String> branches;
  final ContactInfo contactInfo;
  final String website;
  final String establishedYear;
  final GradingSystem gradingSystem;
  final bool showFinalPosition;
  final List<String> customSubjects;
  final List<String> customClasses;

  SchoolInfo({
    this.name = '',
    this.motto = '',
    this.address = '',
    this.logoPath,
    this.branches = const [],
    ContactInfo? contactInfo,
    this.website = '',
    this.establishedYear = '',
    GradingSystem? gradingSystem,
    this.showFinalPosition = false,
    this.customSubjects = const [],
    this.customClasses = const [],
  }) : contactInfo = contactInfo ?? ContactInfo(),
       gradingSystem = gradingSystem ?? GradingSystem();

  SchoolInfo copyWith({
    String? name,
    String? motto,
    String? address,
    String? logoPath,
    List<String>? branches,
    ContactInfo? contactInfo,
    String? website,
    String? establishedYear,
    GradingSystem? gradingSystem,
    bool? showFinalPosition,
    List<String>? customSubjects,
    List<String>? customClasses,
  }) {
    return SchoolInfo(
      name: name ?? this.name,
      motto: motto ?? this.motto,
      address: address ?? this.address,
      logoPath: logoPath ?? this.logoPath,
      branches: branches ?? this.branches,
      contactInfo: contactInfo ?? this.contactInfo,
      website: website ?? this.website,
      establishedYear: establishedYear ?? this.establishedYear,
      gradingSystem: gradingSystem ?? this.gradingSystem,
      showFinalPosition: showFinalPosition ?? this.showFinalPosition,
      customSubjects: customSubjects ?? this.customSubjects,
      customClasses: customClasses ?? this.customClasses,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'motto': motto,
      'address': address,
      'logoPath': logoPath,
      'branches': branches,
      'contactInfo': contactInfo.toMap(),
      'website': website,
      'establishedYear': establishedYear,
      'gradingSystem': gradingSystem.toMap(),
      'showFinalPosition': showFinalPosition,
      'customSubjects': customSubjects,
      'customClasses': customClasses,
    };
  }

  factory SchoolInfo.fromMap(Map<String, dynamic> map) {
    return SchoolInfo(
      name: map['name'] ?? '',
      motto: map['motto'] ?? '',
      address: map['address'] ?? '',
      logoPath: map['logoPath'] != null ? map['logoPath'] as String : null,
      branches: map['branches'] == null
          ? []
          : List<String>.from(map['branches']),
      contactInfo: map['contactInfo'] != null
          ? ContactInfo.fromMap(map['contactInfo'])
          : ContactInfo(),
      website: map['website'] ?? '',
      establishedYear: map['establishedYear'] ?? '',
      gradingSystem: map['gradingSystem'] != null
          ? GradingSystem.fromMap(map['gradingSystem'])
          : GradingSystem(),
      showFinalPosition: map['showFinalPosition'] as bool? ?? false,
      customSubjects: map['customSubjects'] == null
          ? []
          : List<String>.from(map['customSubjects']),
      customClasses: map['customClasses'] == null
          ? []
          : List<String>.from(map['customClasses']),
    );
  }
}
