// PORTED into services_app under features/settings.
// Source: services_app features/employees/domain/entities/emergency_contact_entity.dart
// Imports rewired to the equivalents that already exist in services_app.

import 'package:grc_module/features/settings/se5_emergency_contact/data/models/emergency_contacts_model.dart';

class EmergencyContactEntity {
  String employeeId;
  String? firstContactFirstName;
  String? firstContactMiddleName;
  String? firstContactLastName;
  String? firstContactRelationShip;
  String? firstContactPhone;
  String? firstContactCountryCode;
  String? firstContactEmail;
  String? firstContactCountry;
  String? firstContactProvionce;
  String? firstContactCity;
  String? firstContactStreet;
  String? firstContactLanguage; // ADD THIS
  String? secondContactFirstName;
  String? secondContactMiddleName;
  String? secondContactLastName;
  String? secondContactRelationShip;
  String? secondContactPhone;
  String? secondContactCountryCode;
  String? secondContactEmail;
  String? secondContactCountry;
  String? secondContactProvionce;
  String? secondContactCity;
  String? secondContactStreet;
  String? secondContactLanguage; // ADD THIS
  String? firstContactCountryApp;
  String? secondContactCountryApp;

  EmergencyContactEntity({
    required this.employeeId,
    this.firstContactFirstName,
    this.firstContactMiddleName,
    this.firstContactLastName,
    this.firstContactRelationShip,
    this.firstContactPhone,
    this.firstContactCountryCode,
    this.firstContactEmail,
    this.firstContactCountry,
    this.firstContactProvionce,
    this.firstContactCity,
    this.firstContactStreet,
    this.firstContactLanguage, // ADD THIS
    this.secondContactFirstName,
    this.secondContactMiddleName,
    this.secondContactLastName,
    this.secondContactRelationShip,
    this.secondContactPhone,
    this.secondContactCountryCode,
    this.secondContactEmail,
    this.secondContactCountry,
    this.secondContactProvionce,
    this.secondContactCity,
    this.secondContactStreet,
    this.secondContactLanguage, // ADD THIS
    required this.firstContactCountryApp,
    required this.secondContactCountryApp,
  });

  factory EmergencyContactEntity.fromModel(
      EmergencyContactsModel emergencyContactsModel) {
    return EmergencyContactEntity(
      employeeId: emergencyContactsModel.employeeId,
      firstContactFirstName: emergencyContactsModel
          .firstEmergencyContact?.firstName.values.lastOrNull,
      firstContactMiddleName: emergencyContactsModel
          .firstEmergencyContact?.middleName.values.lastOrNull,
      firstContactLastName: emergencyContactsModel
          .firstEmergencyContact?.lastName.values.lastOrNull,
      firstContactRelationShip: emergencyContactsModel
          .firstEmergencyContact?.relationShip.values.lastOrNull,
      firstContactPhone: emergencyContactsModel
          .firstEmergencyContact?.phone.phones?.lastOrNull,
      firstContactCountryCode: emergencyContactsModel
          .firstEmergencyContact?.phone.countryCode!.lastOrNull,
      firstContactCountryApp: emergencyContactsModel
          .firstEmergencyContact?.phone.countryApp!.lastOrNull,
      firstContactEmail:
      emergencyContactsModel.firstEmergencyContact?.email.values.lastOrNull,
      firstContactCountry: emergencyContactsModel
          .firstEmergencyContact?.country.values.lastOrNull,
      firstContactProvionce: emergencyContactsModel
          .firstEmergencyContact?.provionce.values.lastOrNull,
      firstContactCity:
      emergencyContactsModel.firstEmergencyContact?.city?.values.lastOrNull,
      firstContactStreet: emergencyContactsModel
          .firstEmergencyContact?.street.values.lastOrNull,
      firstContactLanguage: emergencyContactsModel // ADD THIS
          .firstEmergencyContact?.language?.values.lastOrNull,
      secondContactFirstName: emergencyContactsModel
          .secondEmergencyContact?.firstName.values.lastOrNull,
      secondContactMiddleName: emergencyContactsModel
          .secondEmergencyContact?.middleName.values.lastOrNull,
      secondContactLastName: emergencyContactsModel
          .secondEmergencyContact?.lastName.values.lastOrNull,
      secondContactRelationShip: emergencyContactsModel
          .secondEmergencyContact?.relationShip.values.lastOrNull,
      secondContactPhone: emergencyContactsModel
          .secondEmergencyContact?.phone.phones?.lastOrNull,
      secondContactCountryCode: emergencyContactsModel
          .secondEmergencyContact?.phone.countryCode!.lastOrNull,
      secondContactCountryApp: emergencyContactsModel
          .secondEmergencyContact?.phone.countryApp!.lastOrNull,
      secondContactEmail: emergencyContactsModel
          .secondEmergencyContact?.email.values.lastOrNull,
      secondContactCountry: emergencyContactsModel
          .secondEmergencyContact?.country.values.lastOrNull,
      secondContactProvionce: emergencyContactsModel
          .secondEmergencyContact?.provionce.values.lastOrNull,
      secondContactCity:
      emergencyContactsModel.secondEmergencyContact?.city.values.lastOrNull,
      secondContactStreet: emergencyContactsModel
          .secondEmergencyContact?.street.values.lastOrNull,
      secondContactLanguage: emergencyContactsModel // ADD THIS
          .secondEmergencyContact?.language?.values.lastOrNull,
    );
  }
}