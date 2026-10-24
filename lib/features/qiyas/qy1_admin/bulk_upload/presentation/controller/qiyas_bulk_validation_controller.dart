/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_bulk_validation_controller.dart
/// Purpose: Provides validation and formatting logic for Qiyas bulk vision rows.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This extension defines various methods for validating and formatting rows in the bulk
///              vision data, including checking missing fields, wrong text types, email format,
///              language validation, and applying custom text formatting. It also integrates with the
///              QiyasBulkVisionsController to perform row-specific validations and formatting.
/// ********************************************************************* ///
library;

import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/enums/csv_status.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/modules/text_form_field_error.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

extension QiyasBulkValidationController on QiyasBulkVisionsController {
  /// function name: [validateMissingText]
  ///
  /// purpose: Validates that all required fields are filled. If any field is empty, an error message is added.
  ///
  /// parameters: [List<List<dynamic>> fields] - The fields to validate for missing values.
  ///
  /// return type: [void]
  void validateMissingText(List<List<dynamic>> fields) {
    for (int j = 0; j < fields[0].length; j++) {
      for (int i = 1; i < fields.length; i++) {
        String text = fields[i][j]?.toString().trim() ?? "";

        if (text.isEmpty) {
          addError(i - 1, j, "Warning Missing Field",
              "It Looks Like Something Is Missing, Please Fill In The Required Fields To Proceed");
        } else {
          clearError(i - 1, j, "Missing Field");
        }
      }
    }
  }

  /// function name: [validateWrongTextType]
  ///
  /// purpose: Validates that fields have the correct data type. If a value is of the wrong type (such as a number),
  ///          an error message is added.
  ///
  /// parameters: [List<List<dynamic>> fields] - The fields to validate for incorrect data types.
  ///
  /// return type: [void]
  void validateWrongTextType(List<List<dynamic>> fields) {
    for (int j = 1; j < fields[0].length - 2; j++) {
      for (int i = 1; i < fields.length; i++) {
        String text = fields[i][j]?.toString().trim() ?? "";

        if (RegExp(r'^\d+(\.\d+)?$').hasMatch(text)) {
          addError(i - 1, j, "Warning Wrong Entry",
              "It Seems There’s An Issue With Your Entry, Please Double Check And Provide The Correct Information");
        } else {
          clearError(i - 1, j, "Wrong Entry");
        }
      }
    }
  }

  /// function name: [addError]
  ///
  /// purpose: Adds an error message to the specified field in the form. It also changes the border color to indicate
  ///          the error and triggers error icon visibility.
  ///
  /// parameters: [int row, int column, String message, String subMessage] - Specifies which row and column to add
  ///             the error message to and the actual error messages.
  ///
  /// return type: [void]
  void addError(int row, int column, String message, String subMassage) {
    TextFormFieldError error = TextFormFieldError(
      focusNode: textFormFieldData[row][column].focusNode,
      formFieldKey: textFormFieldData[row][column].fieldKeys,
      rowIndex: row,
      columnIndex: column,
    );
    textFormFieldData[row][column].hasErrorIcon = true;
    textFormFieldData[row][column].errorTitle = message;
    textFormFieldData[row][column].errorSubTitle = subMassage;
    textFormFieldData[row][column].border = AppColors.block;

    errors.add(error);
  }

  /// function name: [clearError]
  ///
  /// purpose: Clears the error message from the specified field and resets the error icon and border color.
  ///
  /// parameters: [int row, int column, String textError] - Specifies which row and column to clear the error message from.
  ///
  /// return type: [void]
  void clearError(int row, int column, String textError) {
    if (textFormFieldData[row][column].errorTitle!.contains(textError) ||
        textError == "Date Check") {
      textFormFieldData[row][column].hasErrorIcon = false;
      textFormFieldData[row][column].errorTitle = "";
    }
  }

  /// function name: [validateNameEmail]
  ///
  /// purpose: Validates that the "Control Owner" field contains a valid email address format.
  ///          If the email is invalid, an error message is added.
  ///
  /// parameters: [List<List<dynamic>> fields] - The fields to validate for email correctness.
  ///
  /// return type: [void]
  void validateNameEmail(List<List<dynamic>> fields) {
    int? controlOwnerColumnIndex = fields.first.indexOf("Control Owner");

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (controlOwnerColumnIndex != -1) {
      for (int i = 1; i < fields.length; i++) {
        String text =
            fields[i][controlOwnerColumnIndex]?.toString().trim() ?? "";

        if (!emailRegex.hasMatch(text)) {
          addError(i - 1, controlOwnerColumnIndex, "Warning Control Owner",
              "The control owner entry appears to be in an incorrect format. Please enter a valid email address");
        } else {
          clearError(i - 1, controlOwnerColumnIndex, "Control Owner");
        }
      }
    }
  }

  /// function name: [extractHighlightedTexts]
  ///
  /// purpose: Extracts the highlighted texts between `$` symbols from the input string.
  ///
  /// parameters: [String input] - The input string containing highlighted texts.
  ///
  /// return type: [List<String>] - A list of extracted highlighted texts.
  List<String> extractHighlightedTexts(String input) {
    final highlightExp = RegExp(r'\$(.*?)\$', dotAll: true);
    final matches = highlightExp.allMatches(input);

    return matches.map((match) => match.group(1)!).toList();
  }

  /// function name: [checkTextFormat]
  ///
  /// purpose: Checks if the text in the specified columns adheres to the required format. If the format is incorrect,
  ///          an error message is added.
  ///
  /// parameters: [List<List<dynamic>> fields] - The fields to check for proper format.
  ///             [CsvStatus status] - The CSV status determines validation behavior.
  ///
  /// return type: [void]
  void checkTextFormat(List<List<dynamic>> fields, CsvStatus status) {
    List<int> columnsToCheck = [fields[0].length - 1, fields[0].length - 2];
    RegExp formatPattern = RegExp(r'^(\w+(\s)?,\s?)+(\w+)$');

    if (status == CsvStatus.control) {
      for (int i = 1; i < fields.length; i++) {
        for (int col in columnsToCheck) {
          String text = fields[i][col]?.toString().trim() ?? "";

          if (!formatPattern.hasMatch(text)) {
            addError(i - 1, col, "Warning Format Issue",
                "Invalid separator detected. Please use a comma (,) as the correct separator format");
          } else {
            clearError(i - 1, col, 'Format Issue');
          }
        }
      }
    }
  }

  /// function name: [checkTextLanguage]
  ///
  /// purpose: Validates that text in certain columns uses the correct language (English or Arabic). If there is a mismatch,
  ///          an error message is added.
  ///
  /// parameters: [List<List<dynamic>> fields] - The fields to validate for language.
  ///             [CsvStatus status] - The CSV status determines validation behavior.
  ///
  /// return type: [void]
  void checkTextLanguage(List<List<dynamic>> fields, CsvStatus status) {
    List<int> englishColumns = [1, 3];
    List<int> arabicColumns = [2, 4];
    status == CsvStatus.control
        ? englishColumns = [0, 2, 8]
        : englishColumns = [1, 3];
    status == CsvStatus.control
        ? arabicColumns = [1, 3]
        : arabicColumns = [2, 4];

    RegExp englishPattern = RegExp(r'^[A-Za-z0-9 .,!?]+$');
    RegExp arabicPattern =
        RegExp(r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF0-9 .,!?]*$');

    for (int i = 1; i < fields.length; i++) {
      for (int col in englishColumns) {
        String text = fields[i][col]?.toString().trim() ?? "";
        if (text.isEmpty) continue;
        if (!englishPattern.hasMatch(text)) {
          addError(i - 1, col, "Warning Language Check",
              "There is an issue with your entry. Please ensure you use the required language");
        } else {
          clearError(i - 1, col, 'Language Check');
        }
      }
      for (int col in arabicColumns) {
        String text = fields[i][col]?.toString().trim() ?? "";
        if (text.isEmpty) continue;
        if (!arabicPattern.hasMatch(text)) {
          addError(i - 1, col, "Warning Language Check",
              "There is an issue with your entry. Please ensure you use the required language");
        } else {
          clearError(i - 1, col, 'Language Check');
        }
      }
    }
  }

  /// function name: [makeAllValidations]
  ///
  /// purpose: Performs all necessary validations on the provided vision data (missing text, wrong text type, email, language, format, etc.).
  ///          This method ensures that all rows in the vision data meet the required criteria.
  ///
  /// parameters: [List<List<dynamic>> visionData] - The vision data to validate.
  ///             [CsvStatus status] - The CSV status determines validation behavior.
  ///
  /// return type: [void]
  void makeAllValidations(List<List<dynamic>> visionData, CsvStatus status) {
    errors.clear();
    validateWrongTextType(visionData);
    validateNameEmail(visionData);
    // checkDataIsUniqueWithFirestore(policyData, status);
    checkTextLanguage(visionData, status);
    validateMissingText(visionData);
    checkTextFormat(visionData, status);
    validateInvalidColumnHeaders(visionData, status);
  }
}
