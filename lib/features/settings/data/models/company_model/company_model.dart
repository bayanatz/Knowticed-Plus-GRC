// date:January/14/2024
// by:MohamedFouad
// lastUpdate:January/14/2024

// ignore_for_file: prefer_null_aware_operators

import 'package:demo_app/core/helper/organization_chart_module/data/models/employee_model/address_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/arabic_font_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/city_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/company_industry_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/company_logo_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/company_name_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/company_size_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/country_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/english_font_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/modules_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/primary_color_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/province_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/secondary_color_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/tax_number_model.dart';
import 'package:demo_app/features/settings/data/models/company_model/zip_code.dart';
import 'package:demo_app/core/helper/employees/data/models/new_employee_model/emplyees_model/email_model.dart';
import 'package:demo_app/core/helper/employees/data/models/new_employee_model/emplyees_model/first_name_model.dart';
import 'package:demo_app/core/helper/employees/data/models/new_employee_model/emplyees_model/last_name_model.dart';
import 'package:demo_app/core/helper/employees/data/models/new_employee_model/emplyees_model/mobile_phone_model.dart';
import 'package:demo_app/core/helper/employees/data/models/new_employee_model/emplyees_model/role_model.dart';
class CompanyModel {
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
  Role? role;  FirstName? firstName;
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

  // factory CompanyModel.fromMap(Map data) {
  //   return CompanyModel(
  //     companyName: CompanyName.fromMap(data['Company_Name']),
  //     taxNumber: TaxNumber.fromMap(data['Tax_Number']),
  //     companyAddress: Address.fromMap(data['Company_Address']),
  //     city: City.fromMap(data['City']),
  //     zipCode: ZipCode.fromMap(data['Zip_Code']),
  //     province: Province.fromMap(data['Province']),
  //     country: Country.fromMap(data['Country']),
  //     companyIndustry: CompanyIndustry.fromMap(data['Company_Industry']),
  //     companySize: CompanySize.fromMap(data['Company_Size']),
  //     modules: CompanyModules.fromMap(data['Modules']),
  //     role: Role.fromMap(data['Role']),
  //     firstName: FirstName.fromMap(data['First_Name']),
  //     lastName: LastName.fromMap(data['Last_Name']),
  //     email: Email.fromMap(data['Email']),
  //     phone: MobilePhone.fromMap(data['Phone']),
  //     companyLogo: CompanyLogo.fromMap(data['Company_Logo']),
  //     primaryColor: PrimaryColor.fromMap(data['Primary_Color']),
  //     secondaryColor: SecondaryColor.fromMap(data['Secondary_Color']),
  //     englishFont: EnglishFont.fromMap(data['English_Font']),
  //     arabicFont: ArabicFont.fromMap(data['Arabic_Font']),
  //     status: data['Status'],
  //   );
  // }

  factory CompanyModel.fromMap(Map data) {
    return CompanyModel(
      companyName: data['Company_Name'] != null
          ? CompanyName.fromMap(data['Company_Name'])
          : null,
      taxNumber: data['Tax_Number'] != null
          ? TaxNumber.fromMap(data['Tax_Number'])
          : null,
      companyAddress: data['Company_Address'] != null
          ? Address.fromMap(data['Company_Address'])
          : null,
      city: data['City'] != null
          ? City.fromMap(data['City'])
          : null,
      zipCode: data['Zip_Code'] != null
          ? ZipCode.fromMap(data['Zip_Code'])
          : null,
      province: data['Province'] != null
          ? Province.fromMap(data['Province'])
          : null,
      country: data['Country'] != null
          ? Country.fromMap(data['Country'])
          : null,
      companyIndustry: data['Company_Industry'] != null
          ? CompanyIndustry.fromMap(data['Company_Industry'])
          : null,
      companySize: data['Company_Size'] != null
          ? CompanySize.fromMap(data['Company_Size'])
          : null,
      modules: data['Modules'] != null
          ? CompanyModules.fromMap(data['Modules'])
          : null,
      role: data['Role'] != null
          ? Role.fromMap(data['Role'])
          : null,
      firstName: data['First_Name'] != null
          ? FirstName.fromMap(data['First_Name'])
          : null,
      lastName: data['Last_Name'] != null
          ? LastName.fromMap(data['Last_Name'])
          : null,
      email: data['Email'] != null
          ? Email.fromMap(data['Email'])
          : null,
      phone: data['Phone'] != null
          ? MobilePhone.fromMap(data['Phone'])
          : null,
      companyLogo: data['Company_Logo'] != null
          ? CompanyLogo.fromMap(data['Company_Logo'])
          : CompanyLogo(companyLogo: [], timestamps: []), // Initialize with empty lists
      primaryColor: data['Primary_Color'] != null
          ? PrimaryColor.fromMap(data['Primary_Color'])
          : PrimaryColor(primaryColor: [], timestamps: []), // Initialize with empty lists
      secondaryColor: data['Secondary_Color'] != null
          ? SecondaryColor.fromMap(data['Secondary_Color'])
          : SecondaryColor(secondaryColor: [], timestamps: []), // Initialize with empty lists
      englishFont: data['English_Font'] != null
          ? EnglishFont.fromMap(data['English_Font'])
          : EnglishFont(englishFont: [], timestamps: []), // Initialize with empty lists
      arabicFont: data['Arabic_Font'] != null
          ? ArabicFont.fromMap(data['Arabic_Font'])
          : ArabicFont(arabicFont: [], timestamps: []), // Initialize with empty lists
      status: data['Status'],
    );
  }

  Map<String, dynamic> toMap() => {
        'Company_Name': companyName != null ? companyName!.toMap() : null,
        'Tax_Number': taxNumber != null ? taxNumber!.toMap() : null,
        'Company_Address':
            companyAddress != null ? companyAddress!.toMap() : null,
        'City': city != null ? city!.toMap() : null,
        'Zip_Code': zipCode != null ? zipCode!.toMap() : null,
        'Province': province != null ? province!.toMap() : null,
        'Country': country != null ? country!.toMap() : null,
        'Company_Industry':
            companyIndustry != null ? companyIndustry!.toMap() : null,
        'Company_Size': companySize != null ? companySize!.toMap() : null,
        'Modules': modules != null ? modules!.toMap() : null,
        'Role': role != null ? role!.toMap() : null,
        'First_Name': firstName != null ? firstName!.toMap() : null,
        'Last_Name': lastName != null ? lastName!.toMap() : null,
        'Email': email != null ? email!.toMap() : null,
        'Phone': phone != null ? phone!.toMap() : null,
        'Company_Logo': companyLogo != null ? companyLogo!.toMap() : null,
        'Primary_Color': primaryColor != null ? primaryColor!.toMap() : null,
        'Secondary_Color':
            secondaryColor != null ? secondaryColor!.toMap() : null,
        'English_Font': englishFont != null ? englishFont!.toMap() : null,
        'Arabic_Font': arabicFont != null ? arabicFont!.toMap() : null,
        'Status': status,
      };
}
