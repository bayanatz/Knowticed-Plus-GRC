import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/entity/policy.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/create_policy/domain/entity/controls_text_fields.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/data_grc_2/features/create_policy/presentation/controller/create_policy_controller.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_data_handler.dart
/// Purpose:  manages policy data operations, like initializing, clearing, manipulating
///           policy details and calculating total control weight.
/// Author: Abdelrahman Rashad
/// Created At: 29/1/2025
class PolicyDataHandler {
  /// function name: [initializePolicyData]
  ///
  /// purpose: It sets the policy data. Additionally, it clears the existing
  /// controls and adds new ones based on the policy's controls list, then
  /// calculates the total control weight.
  ///
  /// parameters:
  ///            [policy] Policy: The policy object containing the data to initialize.
  ///            [controller] CreatePolicyController: Set the data of the policy by populating the text fields and variables
  ///                                                 with the details from the provided policy object
  ///
  /// return type: [void]
  void initializePolicyData(CreatePolicyController controller, Policy policy) {
    controller.policyNameEnglish.text = policy.name;
    controller.policyNameArabic.text = policy.nameArabic;
    controller.policyImageURL = policy.imageUrl;
    controller.policyNumber.text = policy.policyNumber;
    controller.validationStartDate.text = policy.startDate;
    controller.validationEndDate.text = policy.endDate;
    controller.policyWeight.text = '${policy.weight}';
    controller.policyDescribtionEnglish.text = policy.describtion;
    controller.policyDescribtionArabic.text = policy.describtionArabic;
    controller.policyDocument.text = policy.policyDocument;
    controller.allowPartialCompliane = policy.allowPartialCompliance;
    controller.isArabicEnabled = policy.hasArabicVersion ?? false;
    // totalControlsWeight = '';
    controller.controlsNew.clear();
    for (var control in policy.controls) {
      controller.controlsNew.add(
        ControlsTextFields(
            auditFrequency: control.auditFrequency,
            controlDocument:
                TextEditingController(), // Replace with actual control data if needed
            controlWeight:
                TextEditingController(text: control.controlWeight.toString()),
            describtion: TextEditingController(text: control.describtion),
            describtionArabic:
                TextEditingController(), // Add translation or keep empty
            fixedForAllDepartments: false, // Adjust as per your logic
            name: TextEditingController(text: control.controlName),
            nameArabic: TextEditingController() // Add translation or keep empty
            ),
      );
    }
    controller.calculateTotalControlWeight();
  }

  /// function name: [clearPolicyData]
  ///
  /// purpose: Clears all policy data, resets controls
  ///
  /// parameters:
  ///            [controller] CreatePolicyController: The controller to clear its data
  ///
  /// return type: [void]
  void clearPolicyData(CreatePolicyController controller) {
    controller.policyNameEnglish.clear();
    controller.policyNameArabic.clear();
    controller.policyImageURL = null;
    controller.policyNumber.clear();
    controller.validationStartDate.clear();
    controller.validationEndDate.clear();
    controller.policyWeight.clear();
    controller.policyDescribtionEnglish.clear();
    controller.policyDescribtionArabic.clear();
    controller.policyDocument.clear();
    controller.allowPartialCompliane = false;
    controller.totalControlsWeight = '';
    controller.controlsNew = [
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
    controller.update();
  }
}
