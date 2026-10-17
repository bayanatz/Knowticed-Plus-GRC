/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: company_information_model.dart
/// Purpose: The company details captured at demo signup.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).
library;

///************************** FILE INFO **************************///
/// File Name: company_information_model.dart
/// Purpose: Contains the model for holding company information over time.
/// Author: Amr Mesbah
/// Created At: 31/12/2024

import 'package:grc_module/features/onboarding/helpers/enum_single_value_tracking_model.dart';

import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/company_size_list.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/industry.dart';
import 'package:grc_module/core/helper/single_value_model.dart';

class CompanyInformationModel {
  SingleValueModel<String> companyName;
  SingleValueModel<String> companyAddress;
  SingleValueModel<String> taxNumber;
  SingleValueModel<String> country;
  SingleValueModel<String> city;
  SingleValueModel<String> province;
  SingleValueModel<String> zipCode;
  EnumSingleValueTrackingModel<Industry> companyIndustry;
  EnumSingleValueTrackingModel<CompanySize> companySize;

  CompanyInformationModel({
    required this.companyName,
    required this.companyAddress,
    required this.taxNumber,
    required this.country,
    required this.city,
    required this.province,
    required this.zipCode,
    required this.companyIndustry,
    required this.companySize,
  });

  static const String kCompanyName = 'Company_Name';
  static const String kCompanyAddress = 'Company_Address';
  static const String kTaxNumber = 'Tax_Number';
  static const String kCountry = 'Country';
  static const String kCity = 'City';
  static const String kProvince = 'Province';
  static const String kZipCode = 'Zip_Code';
  static const String kCompanyIndustry = 'Company_Industry';
  static const String kCompanySize = 'Company_Size';

  Map<String, dynamic> toMap() {
    return {
      kCompanyName: companyName.toMap(),
      kCompanyAddress: companyAddress.toMap(),
      kTaxNumber: taxNumber.toMap(),
      kCountry: country.toMap(),
      kCity: city.toMap(),
      kProvince: province.toMap(),
      kZipCode: zipCode.toMap(),
      kCompanyIndustry: companyIndustry.toMap(),
      kCompanySize: companySize.toMap(),
    };
  }

  factory CompanyInformationModel.fromMap(Map<String, dynamic> map) {
    return CompanyInformationModel(
      companyName: SingleValueModel<String>.fromMap(map[kCompanyName]),
      companyAddress: SingleValueModel<String>.fromMap(map[kCompanyAddress]),
      taxNumber: SingleValueModel<String>.fromMap(map[kTaxNumber]),
      country: SingleValueModel<String>.fromMap(map[kCountry]),
      city: SingleValueModel<String>.fromMap(map[kCity]),
      province: SingleValueModel<String>.fromMap(map[kProvince]),
      zipCode: SingleValueModel<String>.fromMap(map[kZipCode]),
      companyIndustry:
          EnumSingleValueTrackingModel<Industry>.fromMap(map[kCompanyIndustry]),
      companySize:
          EnumSingleValueTrackingModel<CompanySize>.fromMap(map[kCompanySize]),
    );
  }
}
