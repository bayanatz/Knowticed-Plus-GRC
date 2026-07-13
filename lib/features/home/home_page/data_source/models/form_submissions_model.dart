import 'package:demo_app/features/home/home_page/data_source/models/home_component_model.dart';

import 'package:demo_app/features/home/home_page/domain/enum/home_components.dart';

class FormSubmissionsModel extends HomeComponentModel {
  String formId;
  FormSubmissionsModel(
      {required super.component,
      required super.rowNumber,
      required super.columnNumber,
      required this.formId});
  static const String formIdKey = 'Form_Id';
  @override
  toMap() {
    return {
      ...super.toMap(),
      formIdKey: formId,
    };
  }

  factory FormSubmissionsModel.fromMap(Map<String, dynamic> map) {
    return FormSubmissionsModel(
      component: HomeComponents.values.firstWhere(
          (e) => e.databaseName == map[HomeComponentModel.componentKey]),
      formId: map[formIdKey],
      rowNumber: map[HomeComponentModel.rowNumberKey],
      columnNumber: map[HomeComponentModel.columnNumberKey],
    );
  }
}
