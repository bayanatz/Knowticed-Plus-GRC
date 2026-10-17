/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: contact_information_model.dart
/// Purpose: The contact person on a demo request.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N30: added the missing FILE INFO block.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/helper/single_value_model.dart';
import 'package:grc_module/core/helper/phone_number.dart';

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

  static const String kFirstName = 'First_Name';
  static const String kLastName = 'Last_Name';
  static const String kEmail = 'Email';
  static const String kPhone = 'Phone';
  static const String kApprovalDate = 'Approval_Date';

  Map<String, dynamic> toMap() {
    return {
      kFirstName: firstName.toMap(),
      kLastName: lastName.toMap(),
      kEmail: email.toMap(),
      kPhone: phone.toMap(),
      kApprovalDate: approvalDate,
    };
  }

  factory ContactInformationModel.fromMap(Map<String, dynamic> map) {
    return ContactInformationModel(
      firstName: SingleValueModel<String>.fromMap(map[kFirstName]),
      lastName: SingleValueModel<String>.fromMap(map[kLastName]),
      email: SingleValueModel<String>.fromMap(map[kEmail]),
      phone: PhoneModel.fromMap(map[kPhone]),
      approvalDate: map[kApprovalDate],
    );
  }
}
