import 'package:cloud_firestore/cloud_firestore.dart';
import './base_messaging_interface_parameters.dart';

class UserConnectionInterfaceParameters
    extends BaseMessagingInterfaceParameters {
  Timestamp userAccountActivationTime;
  UserConnectionInterfaceParameters(
      {required super.primaryLanguageName,
      required super.secondaryLanguageName,
      required super.primaryLanguageSubInfo,
      required super.secondaryLanguageSubInfo,
      required super.imageUri,
      required super.userId,
      required super.phone,
      required super.userCategory,
      required this.userAccountActivationTime,
      });
}
