/// ************************ FILE INFO ****************************///
/// File Name: group_message_model.dart
/// Purpose: Entity for group message component in the home screen
/// Author: Mohamed Elrashidy
/// Created at: 21/9/2025

import 'package:demo_app/features/home/home_page/domain/enum/home_components.dart';
import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

class GroupMessageModel extends HomeComponentModel {
  List<String> groupIds;
  GroupMessageModel(
      {required super.component,
      required this.groupIds,
      required super.rowNumber,
      required super.columnNumber});

  static const String groupIdsKey = 'Group_Ids';

  toMap() {
    return {
      ...super.toMap(),
      groupIdsKey: groupIds,
    };
  }

  factory GroupMessageModel.fromMap(Map<String, dynamic> map) {
    return GroupMessageModel(
      component: HomeComponents.values.firstWhere(
          (e) => e.databaseName == map[HomeComponentModel.componentKey]),
      groupIds: List<String>.from(map[groupIdsKey]),
      rowNumber: map[HomeComponentModel.rowNumberKey],
      columnNumber: map[HomeComponentModel.columnNumberKey],
    );
  }
}
