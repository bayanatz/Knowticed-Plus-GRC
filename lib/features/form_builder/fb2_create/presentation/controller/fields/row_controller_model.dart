/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: row_controller_model.dart
/// Description: `RowControllerModel` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/core/custom/helpers/custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/row_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/field_text.dart';

class RowControllerModel {
  // List of field controllers for the row.
  List<FieldController> controllers;
  // Text controller for the number of columns in the row.
  FieldText? numOfColumn;
  // Indicates whether this row is expanded or not.
  bool isRowExpanded;

  /// Constructor that initializes the row model with the given controllers.
  /// By default, the row is expanded and has one column.
  RowControllerModel({this.isRowExpanded = true, required this.controllers}) {
    numOfColumn = FieldText(text: FormDateTimeHelper.formatInt(1));
  }

  /// Creates a duplicate of the current row model.
  RowControllerModel duplicate() {
    var newRow = RowControllerModel(
      controllers: [],
      isRowExpanded: isRowExpanded,
    );
    newRow.numOfColumn?.text = numOfColumn?.text ?? '1';
    for (var element in controllers) {
      newRow.controllers.add(element.duplicate()!);
    }
    return newRow;
  }

  /// Initializes the row model with the given controllers.
  RowEntity toModel({bool isSetData = false}) {
    List<FieldModel> fields = [];
    for (var controller in controllers) {
      fields.add(controller.toModel(isSetAnswer: isSetData));
    }
    return RowEntity(fields: fields);
  }
}
