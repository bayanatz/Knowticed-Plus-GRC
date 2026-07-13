import 'package:demo_app/features/home/home_page/domain/enum/home_components.dart';

/// *********************** FILE INFO *****************************
/// File Name: home_component_model.dart
/// Purpose: Entity for hold component information to be used in the home screen
/// Author: Mohamed Elrashidy
/// Created at: 21/9/2025

class HomeComponentModel {
  HomeComponents component;
  int rowNumber;
  int columnNumber;

  HomeComponentModel(
      {required this.component,
      required this.rowNumber,
      required this.columnNumber});
  static const String componentKey = 'Component';
  static const String rowNumberKey = 'Row_Number';
  static const String columnNumberKey = 'Column_Number';

  toMap() {
    return {
      componentKey: component.databaseName,
      rowNumberKey: rowNumber,
      columnNumberKey: columnNumber,
    };
  }

  factory HomeComponentModel.fromMap(Map<String, dynamic> map) {
    return HomeComponentModel(
      component: HomeComponents.values
          .firstWhere((e) => e.databaseName == map[componentKey]),
      rowNumber: map[rowNumberKey],
      columnNumber: map[columnNumberKey],
    );
  }
}
