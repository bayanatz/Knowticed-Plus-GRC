// PORTED into services_app under features/settings.
// Source: services_app features/employees/employee_branding/domain/model.dart
// Imports rewired to the equivalents that already exist in services_app.

/// ************************ FILE INFO ********************************///
/// File Name: employee_branding_model.dart
/// Author: Amr Mesbah
/// Created: 2026-01-25
/// Purpose: Model for employee personal branding (colors, fonts, logo)

import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeBrandingModel {
  String employeeId;
  String? logo;
  String? primaryColor;
  String? secondaryColor;
  String? fontEnglish;
  String? fontArabic;
  Timestamp? timestamp;

  EmployeeBrandingModel({
    required this.employeeId,
    this.logo,
    this.primaryColor,
    this.secondaryColor,
    this.fontEnglish,
    this.fontArabic,
    this.timestamp,
  });

  /// Create from Firestore document
  factory EmployeeBrandingModel.fromMap(Map<String, dynamic> map) {
    return EmployeeBrandingModel(
      employeeId: map['employeeId'] ?? '',
      logo: map['logo'],
      primaryColor: map['primaryColor'],
      secondaryColor: map['secondaryColor'],
      fontEnglish: map['fontEnglish'],
      fontArabic: map['fontArabic'],
      timestamp: map['timestamp'],
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'logo': logo,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'fontEnglish': fontEnglish,
      'fontArabic': fontArabic,
      'timestamp': timestamp ?? Timestamp.now(),
    };
  }

  /// Create default branding from company branding
  factory EmployeeBrandingModel.fromCompanyBranding({
    required String employeeId,
    String? companyLogo,
    String? companyPrimaryColor,
    String? companySecondaryColor,
    String? companyFontEnglish,
    String? companyFontArabic,
  }) {
    return EmployeeBrandingModel(
      employeeId: employeeId,
      logo: companyLogo,
      primaryColor: companyPrimaryColor,
      secondaryColor: companySecondaryColor,
      fontEnglish: companyFontEnglish,
      fontArabic: companyFontArabic,
      timestamp: Timestamp.now(),
    );
  }

  /// Check if employee has custom branding (not using defaults)
  bool hasCustomBranding() {
    return logo != null ||
        primaryColor != null ||
        secondaryColor != null ||
        fontEnglish != null ||
        fontArabic != null;
  }

  /// Copy with method for updates
  EmployeeBrandingModel copyWith({
    String? employeeId,
    String? logo,
    String? primaryColor,
    String? secondaryColor,
    String? fontEnglish,
    String? fontArabic,
    Timestamp? timestamp,
  }) {
    return EmployeeBrandingModel(
      employeeId: employeeId ?? this.employeeId,
      logo: logo ?? this.logo,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      fontEnglish: fontEnglish ?? this.fontEnglish,
      fontArabic: fontArabic ?? this.fontArabic,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'EmployeeBrandingModel(employeeId: $employeeId, logo: $logo, '
        'primaryColor: $primaryColor, secondaryColor: $secondaryColor, '
        'fontEnglish: $fontEnglish, fontArabic: $fontArabic)';
  }
}