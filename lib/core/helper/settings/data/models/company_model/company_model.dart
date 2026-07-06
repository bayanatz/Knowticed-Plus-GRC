/// Module: Settings · Data · Model · CompanyModel
/// File Name: company_model.dart
/// Description: Aggregate root model for a company document. Composes the
///              versioned company sub-models (name, tax number, branding, …).
/// Author: MohamedFouad · Date: 14/01/2024
/// Dependencies: company sub-models, shared employee/org-chart sub-models
/// Revision History:
///   - 14/01/2024 (MohamedFouad): Initial creation.
///   - 26/06/2026 (Amr Mesbah): final fields, const key constants, typed
///       fromMap, added copyWith and Module header.
///   - 01/07/2026: Compacted fromMap/toMap via null-aware helper (≤200 LOC).
library;

import 'package:demo_app/core/helper/organization_chart_module/data/models/employee_model/address_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/arabic_font_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/city_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/company_industry_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/company_logo_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/company_name_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/company_size_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/country_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/english_font_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/modules_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/primary_color_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/province_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/secondary_color_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/tax_number_model.dart';
import 'package:demo_app/core/helper/settings/data/models/company_model/zip_code_model.dart';
// Shared cross-feature sub-models are imported via a single core barrel rather
// than reaching directly into the employee / org-chart feature internals.
import 'package:demo_app/core/models/company_shared_models.dart';

import '../../../../employees/data/models/new_employee_model/emplyees_model/email_model.dart';
import '../../../../employees/data/models/new_employee_model/emplyees_model/first_name_model.dart';
import '../../../../employees/data/models/new_employee_model/emplyees_model/last_name_model.dart';
import '../../../../employees/data/models/new_employee_model/emplyees_model/role_model.dart';

class CompanyModel {
  static const String kCompanyName = 'Company_Name';
  static const String kTaxNumber = 'Tax_Number';
  static const String kCompanyAddress = 'Company_Address';
  static const String kCity = 'City';
  static const String kZipCode = 'Zip_Code';
  static const String kProvince = 'Province';
  static const String kCountry = 'Country';
  static const String kCompanyIndustry = 'Company_Industry';
  static const String kCompanySize = 'Company_Size';
  static const String kModules = 'Modules';
  static const String kRole = 'Role';
  static const String kFirstName = 'First_Name';
  static const String kLastName = 'Last_Name';
  static const String kEmail = 'Email';
  static const String kPhone = 'Phone';
  static const String kCompanyLogo = 'Company_Logo';
  static const String kPrimaryColor = 'Primary_Color';
  static const String kSecondaryColor = 'Secondary_Color';
  static const String kEnglishFont = 'English_Font';
  static const String kArabicFont = 'Arabic_Font';
  static const String kStatus = 'Status';
  CompanyName? companyName;
  TaxNumber? taxNumber;
  Address? companyAddress;
  City? city;
  ZipCode? zipCode;
  Province? province;
  Country? country;
  CompanyIndustry? companyIndustry;
  CompanySize? companySize;
  CompanyModules? modules;
  Role? role;
  FirstName? firstName;
  LastName? lastName;
  Email? email;
  MobilePhone? phone;
  CompanyLogo? companyLogo;
  PrimaryColor? primaryColor;
  SecondaryColor? secondaryColor;
  EnglishFont? englishFont;
  ArabicFont? arabicFont;
  String? status;
  CompanyModel({
    this.companyName,
    this.taxNumber,
    this.companyAddress,
    this.city,
    this.zipCode,
    this.province,
    this.country,
    this.companyIndustry,
    this.companySize,
    this.modules,
    this.role,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.companyLogo,
    this.primaryColor,
    this.secondaryColor,
    this.englishFont,
    this.arabicFont,
    this.status,
  });
  CompanyModel copyWith({
    CompanyName? companyName,
    TaxNumber? taxNumber,
    Address? companyAddress,
    City? city,
    ZipCode? zipCode,
    Province? province,
    Country? country,
    CompanyIndustry? companyIndustry,
    CompanySize? companySize,
    CompanyModules? modules,
    Role? role,
    FirstName? firstName,
    LastName? lastName,
    Email? email,
    MobilePhone? phone,
    CompanyLogo? companyLogo,
    PrimaryColor? primaryColor,
    SecondaryColor? secondaryColor,
    EnglishFont? englishFont,
    ArabicFont? arabicFont,
    String? status,
  }) {
    return CompanyModel(
      companyName: companyName ?? this.companyName,
      taxNumber: taxNumber ?? this.taxNumber,
      companyAddress: companyAddress ?? this.companyAddress,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      province: province ?? this.province,
      country: country ?? this.country,
      companyIndustry: companyIndustry ?? this.companyIndustry,
      companySize: companySize ?? this.companySize,
      modules: modules ?? this.modules,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      companyLogo: companyLogo ?? this.companyLogo,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      englishFont: englishFont ?? this.englishFont,
      arabicFont: arabicFont ?? this.arabicFont,
      status: status ?? this.status,
    );
  }
  /// Null-safe sub-model builder shared by every field below.
  static T? _sub<T>(dynamic raw, T Function(Map<String, dynamic>) build) =>
      raw != null ? build(raw as Map<String, dynamic>) : null;

  factory CompanyModel.fromMap(Map<String, dynamic> data) {
    return CompanyModel(
      companyName: _sub(data[kCompanyName], CompanyName.fromMap),
      taxNumber: _sub(data[kTaxNumber], TaxNumber.fromMap),
      companyAddress: _sub(data[kCompanyAddress], Address.fromMap),
      city: _sub(data[kCity], City.fromMap),
      zipCode: _sub(data[kZipCode], ZipCode.fromMap),
      province: _sub(data[kProvince], Province.fromMap),
      country: _sub(data[kCountry], Country.fromMap),
      companyIndustry: _sub(data[kCompanyIndustry], CompanyIndustry.fromMap),
      companySize: _sub(data[kCompanySize], CompanySize.fromMap),
      modules: _sub(data[kModules], CompanyModules.fromMap),
      role: _sub(data[kRole], Role.fromMap),
      firstName: _sub(data[kFirstName], FirstName.fromMap),
      lastName: _sub(data[kLastName], LastName.fromMap),
      email: _sub(data[kEmail], Email.fromMap),
      phone: _sub(data[kPhone], MobilePhone.fromMap),
      companyLogo: _sub(data[kCompanyLogo], CompanyLogo.fromMap) ?? CompanyLogo(companyLogo: [], timestamps: []),
      primaryColor: _sub(data[kPrimaryColor], PrimaryColor.fromMap) ?? PrimaryColor(primaryColor: [], timestamps: []),
      secondaryColor: _sub(data[kSecondaryColor], SecondaryColor.fromMap) ?? SecondaryColor(secondaryColor: [], timestamps: []),
      englishFont: _sub(data[kEnglishFont], EnglishFont.fromMap) ?? EnglishFont(englishFont: [], timestamps: []),
      arabicFont: _sub(data[kArabicFont], ArabicFont.fromMap) ?? ArabicFont(arabicFont: [], timestamps: []),
      status: data[kStatus],
    );
  }

  Map<String, dynamic> toMap() => {
        kCompanyName: companyName?.toMap(),
        kTaxNumber: taxNumber?.toMap(),
        kCompanyAddress: companyAddress?.toMap(),
        kCity: city?.toMap(),
        kZipCode: zipCode?.toMap(),
        kProvince: province?.toMap(),
        kCountry: country?.toMap(),
        kCompanyIndustry: companyIndustry?.toMap(),
        kCompanySize: companySize?.toMap(),
        kModules: modules?.toMap(),
        kRole: role?.toMap(),
        kFirstName: firstName?.toMap(),
        kLastName: lastName?.toMap(),
        kEmail: email?.toMap(),
        kPhone: phone?.toMap(),
        kCompanyLogo: companyLogo?.toMap(),
        kPrimaryColor: primaryColor?.toMap(),
        kSecondaryColor: secondaryColor?.toMap(),
        kEnglishFont: englishFont?.toMap(),
        kArabicFont: arabicFont?.toMap(),
        kStatus: status,
      };
}
