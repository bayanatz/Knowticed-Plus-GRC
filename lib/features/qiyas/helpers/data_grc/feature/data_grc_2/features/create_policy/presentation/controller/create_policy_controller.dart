import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/entity/policy.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/create_policy/domain/entity/controls_text_fields.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/create_policy/presentation/controller/policy_data_handler.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/create_policy/presentation/controller/policy_ui_handler.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: create_policy_controller.dart
/// Purpose: manages the creation and editing of policies in an application.
/// Author: Mazen Shabaan
/// Created At: 9/10/2024
class CreatePolicyController extends GetxController {
  // controller of the creation
  TextEditingController policyNameEnglish = TextEditingController();
  TextEditingController policyNameArabic = TextEditingController();
  TextEditingController policyNumber = TextEditingController();
  TextEditingController validationStartDate = TextEditingController();
  TextEditingController validationEndDate = TextEditingController();
  TextEditingController policyWeight = TextEditingController();
  TextEditingController policyDescribtionEnglish = TextEditingController();
  TextEditingController policyDescribtionArabic = TextEditingController();
  TextEditingController policyDocument = TextEditingController();

  PolicyDataHandler dataHandler = PolicyDataHandler();
  PolicyUIHandler uiHandler = PolicyUIHandler();

  /// function name: [initializeData]
  ///
  /// purpose: Initializes the data of the policy by populating the text fields and variables
  /// with the details from the provided policy object.
  ///
  /// parameters:
  ///            [policy] Policy: The policy object containing the data to initialize.
  ///
  /// return type: [void]
  void initializeData(Policy policy) {
    dataHandler.initializePolicyData(this, policy);
    update();
  }

  /// function name: [calculateTotalControlWeight]
  ///
  /// purpose: Calculates and updates the total weight of all policy controls.
  ///
  /// parameters:
  ///            [controller] CreatePolicyController: The controller to calculate the total weight of all policy controls.
  void calculateTotalControlWeight() {
    double totalWeight = 0.0;

    for (var control in controlsNew) {
      // Check if the controlWeight is not empty and can be parsed
      if (control.controlWeight.text.isNotEmpty) {
        totalWeight += double.tryParse(control.controlWeight.text) ?? 0.0;
      }
    }
    totalControlsWeight = '${totalWeight.toInt()}';
    update();
  }

  /// function name: [clearData]
  ///
  /// purpose: Clears all the data in the controller
  ///
  /// return type: [void]
  void clearData() {
    dataHandler.clearPolicyData(this);
    update();
  }

  bool isArabicEnabled = false;

  /// function name: [changeArabicState]
  ///
  /// purpose: Toggles the state of Arabic language support.
  ///
  /// return type: [void]
  void changeArabicState() {
    isArabicEnabled = !isArabicEnabled;
    update();
  }

  String? policyImageURL;

  /// function name: [uploadPolicyImage]
  ///
  /// purpose: Uploads a policy image by opening the device's gallery.
  ///
  /// return type: [Future<void>]
  Future<void> uploadPolicyImage() async {
    ImagePicker imagePicker = ImagePicker();

    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {}

    update();
  }

  /// function name: [attachPolicyDocument]
  ///
  /// purpose: Attach Policy Document (Didn't completed).
  ///
  /// return type: [void]
  void attachPolicyDocument() {
    log("attach file");
    // TO DO : put attaching file logic here
  }

  /// function name: [selectDate]
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
  Future<void> selectDate(BuildContext context,
      CalendarDatePicker2Type? calendarType, String where) async {
    uiHandler.selectDateUIHandler(context, calendarType, where, this);
    update();
  }

  bool allowPartialCompliane = false;

  /// function name: [changePartialComplianceState]
  ///
  /// purpose: Toggles the [allowPartialCompliane] flag to allow partial compliance or not in
  ///          the policy creation and updates the ui.
  ///
  /// return type: [void]
  void changePartialComplianceState() {
    allowPartialCompliane = !allowPartialCompliane;
    update();
  }

  /// control section
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<ControlsTextFields> controlsNew = [
    ControlsTextFields(
        auditFrequency: null,
        controlDocument: TextEditingController(),
        controlWeight: TextEditingController(),
        describtion: TextEditingController(),
        describtionArabic: TextEditingController(),
        fixedForAllDepartments: false,
        name: TextEditingController(),
        nameArabic: TextEditingController())
  ];

  /// function name: [addControls]
  ///
  /// purpose: Adds a new control to the list of controls in the policy creation and updates the ui.
  ///
  /// return type: [void]
  void addControls() {
    controlsNew.add(ControlsTextFields(
        auditFrequency: null,
        controlDocument: TextEditingController(),
        controlWeight: TextEditingController(),
        describtion: TextEditingController(),
        describtionArabic: TextEditingController(),
        fixedForAllDepartments: false,
        name: TextEditingController(),
        nameArabic: TextEditingController()));
    update();
  }

  /// function name: [removeControls]
  ///
  /// purpose: Removes the control at the given [index] from the list of controls in the policy creation and updates the ui.
  ///
  /// return type: [void]
  void removeControls(int index) {
    controlsNew.removeAt(index);
    update();
  }

  /// function name: [validateField]
  ///
  /// purpose: If the controller is empty.
  ///
  /// parameters:
  ///            [controller] TextEditingController: the controller to validate
  ///            [errorMessage] String: the error message to return if the controller is empty
  ///
  /// return type: [String?] - it returns [errorMessage] Otherwise, it returns null.
  String? validateField(TextEditingController controller, String errorMessage) {
    if (controller.text == '') {
      return errorMessage;
    }
    return null;
  }

  /// function name: [validateDropdown]
  ///
  /// purpose: Checks if the provided [value] is null or empty
  ///
  /// parameters:
  ///            [value] String?: the Dropdown value to validate
  ///            [errorMessage] String: the error message to return if the controller is empty
  ///
  /// return type: [String?] - it returns [errorMessage] Otherwise, it returns null.
  String? validateDropdown(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  /// function name: [validateAllControls]
  ///
  /// purpose: validate all controls.
  ///
  /// return type: [bool?] - returns true if all are valid, or false if any are invalid.
  bool validateAllControls() {
    return formKey.currentState?.validate() ?? false;
  }

  /// function name: [validateControlFields]
  ///
  /// purpose: validate fields in a control.
  ///
  /// parameters:
  ///            [index] int?: the index of the control to validate
  ///
  /// return type: [String?] - returns true if all are valid, or false if any are invalid.
  String? validateControlFields(int index) {
    return uiHandler.validateControlFieldsUIHandler(index, this);
  }

  /// function name: [validateControlFields]
  ///
  /// purpose: attach the Control Document.
  ///
  /// parameters:
  ///            [index] int?: the index of the control
  ///
  /// return type: [void]
  void attachControlDocument(int index) {
    log("attach file");
  }

  String totalControlsWeight = '';
  String policyDetailsSearch = '';

  /// function name: [onSearchPolicyDetails]
  ///
  /// purpose: Updates the [policyDetailsSearch] variable with the given [value] and update.
  ///
  /// parameters:
  ///            [value] string: the value to set the policyDetailsSearch
  ///
  /// return type: [void]
  void onSearchPolicyDetails(String value) {
    policyDetailsSearch = value;
    update();
  }

  int policyDetailsIndex = 0;

  /// function name: [policyDetailsIndexState]
  ///
  /// purpose: set the policyDetailsIndex a new value
  ///
  /// parameters:
  ///            [value] int: the value to set the policyDetailsIndex
  ///
  /// return type: [void]
  void policyDetailsIndexState(int value) {
    policyDetailsIndex = value;
    update();
  }

  String? statusPolicyDetailsFilter;

  /// function name: [statusPolicyDetailsFilterState]
  ///
  /// purpose: Updates the [statusPolicyDetailsFilter] variable with the given [value] and update
  ///
  /// parameters:
  ///            [value] String?: the value to set the policyDetailsIndex
  ///
  /// return type: [void]
  void statusPolicyDetailsFilterState(String? value) {
    statusPolicyDetailsFilter = value;
    update();
  }

  TextEditingController filterLastEditPolicyDetails = TextEditingController();
  TextEditingController filterWeightsPolicyDetails = TextEditingController();
  bool isFilterPolicyDetailsEnabled = false;

  /// function name: [resetFilterPolicyDetails]
  ///
  /// purpose: Resets all filter fields related to policy details.
  ///
  /// return type: [void]
  void resetFilterPolicyDetails() {
    uiHandler.resetFilter(this);
    update();
  }

  /// function name: [applyFilterPolicyDetails]
  ///
  /// purpose: Enables or disables the policy details filter based on whether any of the
  ///          filter fields have values.
  ///
  /// return type: [void]
  void applyFilterPolicyDetails() {
    uiHandler.applyFilter(this);
    update();
  }
}
