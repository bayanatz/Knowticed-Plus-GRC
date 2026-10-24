/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: edit_validator.dart
/// Description: `EditValidator`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/address_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/check_box_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/drop_down_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/fields/radio_text_field_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';

mixin EditValidator {
  /// Method Name: [allowEditing]
  ///
  /// Purpose: FB-HOME-03: an edit may change texts, hints and settings, but not the pages, rows, fields or options of a form that already has answers.
  ///
  /// Parameters:
  /// - [old]: the form as saved.
  /// - [edited]: the edited form.
  ///
  /// Returns: true when the edit may be saved.
  bool allowEditing({required FormEntity old, required FormEntity edited}) {
    if (old.numberUsed == 0) {
      return true;
    }
    if (old.pages.length != edited.pages.length) {
      return false;
    }
    for (int pageIndex = 0; pageIndex < old.pages.length; pageIndex++) {
      if (old.pages[pageIndex].rows.length !=
          edited.pages[pageIndex].rows.length) {
        return false;
      }
      for (int rowIndex = 0;
          rowIndex < old.pages[pageIndex].rows.length;
          rowIndex++) {
        if (old.pages[pageIndex].rows[rowIndex].fields.length !=
            edited.pages[pageIndex].rows[rowIndex].fields.length) {
          return false;
        }
        for (int columnIndex = 0;
            columnIndex < old.pages[pageIndex].rows[rowIndex].fields.length;
            columnIndex++) {
          FieldModel oldField =
              old.pages[pageIndex].rows[rowIndex].fields[columnIndex];
          FieldModel? editedField;
          try {
            editedField =
                edited.pages[pageIndex].rows[rowIndex].fields[columnIndex];
          } catch (e) {
            return false;
          }
          if (!isSameField(oldField, editedField)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  /// Method Name: [isSameField]
  ///
  /// Purpose: whether two fields have the same type and the same options.
  ///
  /// Parameters:
  /// - [oldField]: the saved field.
  /// - [editedField]: the edited field.
  ///
  /// Returns: true when the structure is the same.
  bool isSameField(FieldModel oldField, FieldModel editedField) {
    if (oldField.type != editedField.type) {
      return false;
    }
    if (oldField.type == FormFieldType.dropDown) {
      oldField = oldField as DropDownFieldModel;
      editedField = editedField as DropDownFieldModel;
      if (oldField.hints.length > editedField.hints.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.hints.length;
          optionIndex++) {
        if (oldField.hints[optionIndex] != editedField.hints[optionIndex]) {
          return false;
        }
      }
    }

    if (oldField.type == FormFieldType.checkBox) {
      oldField = oldField as CheckBoxFieldModel;
      editedField = editedField as CheckBoxFieldModel;
      if (oldField.options.length > editedField.options.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.options.length;
          optionIndex++) {
        if (oldField.options[optionIndex] != editedField.options[optionIndex]) {
          return false;
        }
      }
    }

    if (oldField.type == FormFieldType.radio) {
      oldField = oldField as RadioFieldModel;
      editedField = editedField as RadioFieldModel;

      if (oldField.hints.length > editedField.hints.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.hints.length;
          optionIndex++) {
        if (oldField.hints[optionIndex] != editedField.hints[optionIndex]) {
          return false;
        }
      }
    }

    if (oldField.type == FormFieldType.radioTextField) {
      oldField = oldField as RadioTextFieldModel;
      editedField = editedField as RadioTextFieldModel;

      if (oldField.hints.length > editedField.hints.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.hints.length;
          optionIndex++) {
        if (oldField.hints[optionIndex] != editedField.hints[optionIndex]) {
          return false;
        }
      }
    }

    if (oldField.type == FormFieldType.location) {
      oldField = oldField as LocationFieldModel;
      editedField = editedField as LocationFieldModel;
      if (oldField.locationType != editedField.locationType) {
        return false;
      }
    }

    if (oldField.type == FormFieldType.address) {
      oldField = oldField as AddressFieldModel;
      editedField = editedField as AddressFieldModel;
      if (oldField.hints.length > editedField.hints.length) {
        return false;
      }
      for (int optionIndex = 0;
          optionIndex < oldField.hints.length;
          optionIndex++) {
        if (oldField.hints[optionIndex] != editedField.hints[optionIndex]) {
          return false;
        }
      }
    }
    return true;
  }
}
