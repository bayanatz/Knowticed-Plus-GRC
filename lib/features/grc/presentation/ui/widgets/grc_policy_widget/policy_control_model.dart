/// Module: GRC Policy Management
/// Description: Data model for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK
/// Revision History: 2026-07-01 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_control_model.dart
/// Purpose: Contains PolicyControlModel, the model holding text controllers
///          and state for a single control card in the controls list.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:flutter/material.dart';

import 'policy_document_info.dart';

/// class name: [PolicyControlModel]
///
/// purpose: holds the TextEditingControllers and mutable state for one
///          control card. Each item in AddPolicyControlsPage's list is
///          an independent instance of this model.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyControlModel {
  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;

  String? frequency;
  PolicyDocumentInfo? document;

  PolicyControlModel({
    TextEditingController? nameController,
    TextEditingController? nameArController,
    TextEditingController? descriptionController,
    TextEditingController? descriptionArController,
    TextEditingController? weightController,
    this.frequency,
    this.document,
  })  : nameController = nameController ?? TextEditingController(),
        nameArController = nameArController ?? TextEditingController(),
        descriptionController =
            descriptionController ?? TextEditingController(),
        descriptionArController =
            descriptionArController ?? TextEditingController(),
        weightController = weightController ?? TextEditingController();

  void dispose() {
    nameController.dispose();
    nameArController.dispose();
    descriptionController.dispose();
    descriptionArController.dispose();
    weightController.dispose();
  }
}
