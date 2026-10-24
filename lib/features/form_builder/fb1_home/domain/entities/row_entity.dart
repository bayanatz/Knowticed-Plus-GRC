/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: row_entity.dart
/// Description: `RowEntity`, one row of a page (a list of fields).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';

/// One row of a page.
class RowEntity {
  /// List of fields in the row
  List<FieldModel> fields;

  /// Constructor for initializing the RowEntity instance
  RowEntity({required this.fields});

  /// Method Name: [duplicate]
  ///
  /// Purpose: copies the row and its fields (without answers).
  ///
  /// Returns: the copy.
  RowEntity duplicate() {
    List<FieldModel> newFields = [];
    for (var element in fields) {
      newFields.add(element.duplicate()!);
    }
    return RowEntity(fields: newFields);
  }
}
