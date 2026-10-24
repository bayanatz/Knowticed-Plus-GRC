/// Module: services / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: services_mobile_phone_entity.dart
/// Purpose: An employee phone number as stored by the services module.
/// Author: Knowticed Team
/// Updated: 18/10/2026 by Amr Mesbah - split out of model_employee.dart (H17).
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/helper/phone_number.dart';

class ServicesMobilePhoneEntity {
  // ---- Firestore field keys (in-class, SCREAMING_SNAKE_CASE) ----
  static const String kPhone = 'phone';
  static const String kCountryCode = 'countryCode';
  static const String kCountryApp = 'countryApp';

  final String? phone;
  final String? countryCode;
  final String? countryApp;

  ServicesMobilePhoneEntity({this.phone, this.countryCode, this.countryApp});
  factory ServicesMobilePhoneEntity.fromMobilePhoneEntity(PhoneNumber entity) {
    return ServicesMobilePhoneEntity(
      phone: entity.phone,
      countryCode: entity.countryCode,
      countryApp: entity.countryApp,
    );
  }
  factory ServicesMobilePhoneEntity.fromJson(Map<String, dynamic> json) {
    return ServicesMobilePhoneEntity(
      phone: json[kPhone],
      countryCode: json[kCountryCode],
      countryApp: json[kCountryApp],
    );
  }

  Map<String, dynamic> toJson() {
    return {kPhone: phone, kCountryCode: countryCode, kCountryApp: countryApp};
  }
}
