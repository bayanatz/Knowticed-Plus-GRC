/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: demo_company_model.dart
/// Purpose: A demo tenant.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).
library;

///*************************** FILE INFO ****************************///
/// File Name: demo_company_model.dart
/// Purpose: Contains main company model.
/// Author: Amr Mesbah
/// Created At: 31/12/2024

import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/models/company_information_model.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/models/contact_information_model.dart';
import 'package:grc_module/features/onboarding/o3_authentication/data/models/demo_details.dart';

class DemoCompanyModel {
  String requestId;
  ApprovalStatus requestStatus;
  CompanyInformationModel companyInformation;
  DemoDetails? demoDetails;
  ContactInformationModel contactInformation;
  List<String> answers = [];

  DemoCompanyModel(
      {required this.requestId,
      required this.companyInformation,
      required this.demoDetails,
      required this.contactInformation,
      required this.answers,
      required this.requestStatus});
  static const String kRequestId = 'Request_Id';
  static const String kCompanyInformation = 'Company_Information';
  static const String kDemoDetails = 'Demo_Details';
  static const String kContactInformation = 'Contact_Information';
  static const String kAnswers = 'Answers';
  static const String kRequestStatus = 'Request_Status';

  Map<String, dynamic> toMap() {
    return {
      kRequestId: requestId,
      kCompanyInformation: companyInformation.toMap(),
      kDemoDetails: demoDetails?.toMap(),
      kContactInformation: contactInformation.toMap(),
      kRequestStatus: requestStatus.name,
      kAnswers: answers,
    };
  }

  factory DemoCompanyModel.fromMap(Map<String, dynamic> map) {
    return DemoCompanyModel(
      requestId: map[kRequestId],
      companyInformation:
          CompanyInformationModel.fromMap(map[kCompanyInformation]),
      demoDetails: map[kDemoDetails] == null
          ? null
          : DemoDetails.fromMap(map[kDemoDetails]),
      contactInformation:
          ContactInformationModel.fromMap(map[kContactInformation]),
      requestStatus: ApprovalStatus.values
          .firstWhere((element) => element.name == map[kRequestStatus]),
      answers: List<String>.from(map[kAnswers]),
    );
  }
}
