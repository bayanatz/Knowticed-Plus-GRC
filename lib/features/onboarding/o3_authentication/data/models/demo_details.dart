/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: demo_details.dart
/// Purpose: Trial window and temporary credentials for a demo tenant.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).
library;

///******************************** FILE INFO *******************************///
/// File Name: demo_details.dart
/// Purpose: Contains company demo details.
/// Author: Amr Mesbah
/// Created At: 31/12/2024

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/helper/single_value_model.dart';

class DemoDetails {
  String? reasonOfRejection;
  SingleValueModel<int>? numberOfUsers;
  SingleValueModel<Timestamp>? accessBegin;
  SingleValueModel<Timestamp>? accessEnd;
  SingleValueModel<String>? userName;
  SingleValueModel<String>? temporaryPassword;
  Timestamp responseTime;
  SingleValueModel<String> updatedBy;
  Map<Modules, SingleValueModel<bool>>? modules;
  DemoDetails({
    required this.reasonOfRejection,
    this.numberOfUsers,
    this.accessBegin,
    this.accessEnd,
    this.userName,
    this.temporaryPassword,
    required this.responseTime,
    required this.updatedBy,
    this.modules,
  });

  static const String kReasonOfRejection = 'Reason_Of_Rejection';
  static const String kNumberOfUsers = 'Number_Of_Users';
  static const String kAccessBegin = 'Access_Begin';
  static const String kAccess = 'Access_End';
  static const String kUserName = 'User_Name';
  static const String kTemporaryPassword = 'Temporary_Password';
  static const String kResponseTime = 'Response_Time';
  static const String kUpdatedBy = 'Updated_By';
  static const String kModules = 'Modules';

  Map<String, dynamic> toMap() {
    return {
      kReasonOfRejection: reasonOfRejection,
      kNumberOfUsers: numberOfUsers?.toMap(),
      kAccessBegin: accessBegin?.toMap(),
      kAccess: accessEnd?.toMap(),
      kUserName: userName?.toMap(),
      kTemporaryPassword: temporaryPassword?.toMap(),
      kResponseTime: responseTime,
      kUpdatedBy: updatedBy.toMap(),
      kModules: modules?.map((key, value) => MapEntry(key.name, value.toMap())),
    };
  }

  factory DemoDetails.fromMap(Map<String, dynamic> map) {
    return DemoDetails(
      reasonOfRejection: map[kReasonOfRejection],
      numberOfUsers: map[kNumberOfUsers] == null
          ? null
          : SingleValueModel.fromMap(map[kNumberOfUsers]),
      accessBegin: map[kAccessBegin] == null
          ? null
          : SingleValueModel.fromMap(map[kAccessBegin]),
      accessEnd:
          map[kAccess] == null ? null : SingleValueModel.fromMap(map[kAccess]),
      userName: map[kUserName] == null
          ? null
          : SingleValueModel.fromMap(map[kUserName]),
      temporaryPassword: map[kTemporaryPassword] == null
          ? null
          : SingleValueModel.fromMap(map[kTemporaryPassword]),
      responseTime: map[kResponseTime],
      updatedBy: SingleValueModel.fromMap(map[kUpdatedBy]),
      modules: map[kModules]?.map<Modules, SingleValueModel<bool>>(
        (key, value) => MapEntry(
            Modules.values.firstWhere((element) => element.name == key),
            SingleValueModel<bool>.fromMap(value)),
      ),
    );
  }
}
