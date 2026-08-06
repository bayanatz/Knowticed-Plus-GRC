import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/helper/main_helper/single_value_model.dart';
import 'package:grc_module/core/helper/main_helper/phone_number.dart';

class ContactInformationModel {
  SingleValueModel<String> firstName;
  SingleValueModel<String> lastName;
  SingleValueModel<String> email;
  PhoneModel phone;
  Timestamp approvalDate;

  ContactInformationModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.approvalDate,
  });

  static const String FIRST_NAME = 'First_Name';
  static const String LAST_NAME = 'Last_Name';
  static const String EMAIL = 'Email';
  static const String PHONE = 'Phone';
  static const String APPROVAL_DATE = 'Approval_Date';

  Map<String, dynamic> toMap() {
    return {
      FIRST_NAME: firstName.toMap(),
      LAST_NAME: lastName.toMap(),
      EMAIL: email.toMap(),
      PHONE: phone.toMap(),
      APPROVAL_DATE: approvalDate,
    };
  }

  factory ContactInformationModel.fromMap(Map<String, dynamic> map) {
    return ContactInformationModel(
      firstName: SingleValueModel<String>.fromMap(map[FIRST_NAME]),
      lastName: SingleValueModel<String>.fromMap(map[LAST_NAME]),
      email: SingleValueModel<String>.fromMap(map[EMAIL]),
      phone: PhoneModel.fromMap(map[PHONE]),
      approvalDate: map[APPROVAL_DATE],
    );
  }
}
