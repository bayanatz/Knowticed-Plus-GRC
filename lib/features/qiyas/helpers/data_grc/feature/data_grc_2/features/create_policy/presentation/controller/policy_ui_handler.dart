import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/core/constants/constants.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/create_policy/presentation/controller/create_policy_controller.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_date_pic.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_ui_handler.dart
/// Purpose:   manage and apply/reset filters for a policy creation form, controlling
///            the partial compliance setting based on user input.
/// Author: Abdelrahman Rashad
/// Created At: 29/1/2025
class PolicyUIHandler {
  /// function name: [applyFilter]
  ///
  /// purpose: set the allowPartialCompliance property of the CreatePolicyController based on whether certain
  ///          fields (policy document, policy weight, or Arabic language setting) are not empty or enabled.
  ///
  /// parameters:
  ///            [controller] CreatePolicyController: The controller to apply the filter on
  ///
  /// return type: [void]
  void applyFilter(CreatePolicyController controller) {
    controller.filterLastEditPolicyDetails.text != '' ||
            controller.filterWeightsPolicyDetails.text != '' ||
            controller.statusPolicyDetailsFilter != null
        ? controller.isFilterPolicyDetailsEnabled = true
        : controller.isFilterPolicyDetailsEnabled = false;
    controller.update();
  }

  /// function name: [resetFilter]
  ///
  /// purpose: clearing the policy document and weight, and setting allowPartialCompliance to false.
  ///
  /// parameters:
  ///            [controller] CreatePolicyController: The controller to apply the reset filter on
  ///
  /// return type: [void]
  void resetFilter(CreatePolicyController controller) {
    controller.filterLastEditPolicyDetails.clear();
    controller.filterWeightsPolicyDetails.clear();

    controller.statusPolicyDetailsFilter = null;
    controller.statusPolicyDetailsFilterState(null);
    controller.isFilterPolicyDetailsEnabled = false;
    controller.update();
  }

  DateTime? selectedDate;
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];

  /// function name: [selectDateUIHandler]
  ///
  /// purpose:Shows a date picker dialog to the user.
  /// parameters:
  ///            [context] BuildContext: used to show the dialog.
  ///            [calendarType] parameter specifies the type of date picker dialog to show.
  ///                           If it is null, it will show a single date picker dialog.
  ///            [where] String: where to update the text controllers:
  ///                                  If it is 'startValid', it will update the [validationStartDate].
  ///                                  If it is 'endValid', it will update the [validationEndDate].
  ///                                  If it is 'filterPolicyDetails', it will update the [filterLastEditPolicyDetails].
  ///            [controller] CreatePolicyController: The controller to get the selected date and update the text controllers.
  ///
  /// return type: [Future<void>]
  Future<void> selectDateUIHandler(
      BuildContext context,
      CalendarDatePicker2Type? calendarType,
      String where,
      CreatePolicyController controller) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(context,
        _rangeDatePickerValueWithDefaultValue, DateTime.now(), calendarType);
    // change the selected the  with the picked date
    // ignore: unrelated_type_equality_checks
    if (picked != null) {
      _rangeDatePickerValueWithDefaultValue = picked;
      selectedDate = picked[
          0]; // get the first element in the array which is the selected date
      if (where == Texts.startValid) {
        controller.validationStartDate.text =
            "${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year}";
      } else if (where == Texts.endValid) {
        controller.validationEndDate.text =
            "${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year}";
      } else if (where == Texts.filterPolicyDetails) {
        controller.filterLastEditPolicyDetails.text =
            "${'From'.tr} ${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year} ${'To'.tr} ${picked.last!.day} ${DateFormat.MMM().format(picked.last!)} ${picked.last!.year}";
      }
    }
  }

  /// function name: [validateControlFieldsUIHandler]
  ///
  /// purpose: validate fields in a control.
  ///
  /// parameters:
  ///            [index] int?: the index of the control to validate
  ///            [controller] CreatePolicyController: The controller to apply validate the field
  ///
  /// return type: [String?] - returns true if all are valid, or false if any are invalid.
  String? validateControlFieldsUIHandler(
      int index, CreatePolicyController controller) {
    final control = controller.controlsNew[index];
    if (controller.validateField(control.name, 'Enter Control Name') != null ||
        controller.validateField(
                control.nameArabic, 'Enter Arabic Control Name') !=
            null ||
        controller.validateField(
                control.describtion, 'Enter Control Description') !=
            null ||
        controller.validateField(control.describtionArabic,
                'Enter Arabic Control Description') !=
            null ||
        controller.validateField(
                control.controlWeight, 'Enter Control Weight') !=
            null ||
        controller.validateDropdown(
                control.auditFrequency, 'Select Audit Frequency') !=
            null ||
        controller.validateField(
                control.controlDocument, 'Attach Control Document') !=
            null) {
      return 'Incomplete fields'; // If any field fails validation
    }
    return null; // All fields are valid
  }
}
