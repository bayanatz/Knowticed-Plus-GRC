
import 'package:demo_app/core/helper/messaging/core/generic_models/single_value_tracking_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/mobile_phone_model.dart';

/// **************************** FILE INFO **************************** ///
/// Purpose: Model for employee insurance data
/// Author: Mohamed Elrashidy
/// created At: 20/11/2024

class HealthInsuranceModel {
  String? employeeId;
  SingleValueTrackingModel<String> insuranceProviderName;
  SingleValueTrackingModel<String> postalCode;
  MobilePhone insuranceProviderContact;
  SingleValueTrackingModel<String> insurancePolicyNumber;

  HealthInsuranceModel(
      {required this.employeeId,
      required this.insuranceProviderName,
      required this.insuranceProviderContact,
      required this.insurancePolicyNumber,
      required this.postalCode});

  static const String employeeIdKey = 'Employee_Id';
  static const String insuranceProviderNameKey = 'Insurance_Provider_Name';
  static const String insuranceProviderContactKey =
      'Insurance_Provider_Contact';
  static const String insurancePolicyNumberKey = 'Insurance_Policy_Number';
  static const String postalCodeKey = 'Postal_Code';

  Map<String, dynamic> toMap() {
    return {
      employeeIdKey: employeeId,
      insuranceProviderNameKey: insuranceProviderName.toMap(),
      insuranceProviderContactKey: insuranceProviderContact.toMap(),
      insurancePolicyNumberKey: insurancePolicyNumber.toMap(),
      postalCodeKey: postalCode.toMap()
    };
  }

  factory HealthInsuranceModel.fromMap(Map<String, dynamic> map) {
    return HealthInsuranceModel(
      postalCode: SingleValueTrackingModel<String>.fromMap(
          map[postalCodeKey] as Map<String, dynamic>),
      employeeId: map[employeeIdKey] as String,
      insuranceProviderName: SingleValueTrackingModel<String>.fromMap(
          map[insuranceProviderNameKey] as Map<String, dynamic>),
      insuranceProviderContact: MobilePhone.fromMap(
          map[insuranceProviderContactKey] as Map<String, dynamic>?),
      insurancePolicyNumber: SingleValueTrackingModel<String>.fromMap(
          map[insurancePolicyNumberKey] as Map<String, dynamic>),
    );
  }
}
