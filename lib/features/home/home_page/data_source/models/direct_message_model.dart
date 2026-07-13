import 'package:demo_app/features/home/home_page/domain/enum/home_components.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

/// ************************ FILE INFO ****************************///
/// File Name: direct_message_model.dart
/// Purpose: Entity for direct message component in the home screen
/// Author: Mohamed Elrashidy
/// Created at: 21/9/2025

class DirectMessageModel extends HomeComponentModel {
  List<String> usersEmails;
  DirectMessageModel(
      {required super.component,
      required this.usersEmails,
      required super.rowNumber,
      required super.columnNumber});

  static const String usersEmailsKey = 'Users_Emails';

  toMap() {
    return {
      ...super.toMap(),
      usersEmailsKey: usersEmails,
    };
  }

  factory DirectMessageModel.fromMap(Map<String, dynamic> map) {
    return DirectMessageModel(
      component: HomeComponents.values.firstWhere(
          (e) => e.databaseName == map[HomeComponentModel.componentKey]),
      usersEmails: List<String>.from(map[usersEmailsKey]),
      rowNumber: map[HomeComponentModel.rowNumberKey],
      columnNumber: map[HomeComponentModel.columnNumberKey],
    );
  }
}
