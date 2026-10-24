// This class definition creates a data model for a control in a policy, with various text fields and a boolean value. Here's a breakdown of what each field does:

// name: a text controller for the control's name
// nameArabic: a text controller for the control's Arabic name
// describtion: a text controller for the control's description
// describtionArabic: a text controller for the control's Arabic description
// controlWeight: a text controller for the control's weight
// fixedforAllDepartments: a boolean indicating whether the control is fixed for all departments
// auditFrequency: a string representing the audit frequency (optional)
// controlDocument: a text controller for the control's document
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/control_owner/features/home/domain/entity/control_owner.dart';

class ControlsTextFields {
  TextEditingController name;
  TextEditingController nameArabic;
  TextEditingController describtion;
  TextEditingController describtionArabic;
  TextEditingController controlWeight;
  bool fixedForAllDepartments;
  String? auditFrequency;
  String? department;
  List<ControlOwner>? controlOwnerList;
  TextEditingController controlDocument;

  ControlsTextFields(
      {required this.auditFrequency,
      required this.controlDocument,
      required this.controlWeight,
      required this.describtion,
      required this.describtionArabic,
      required this.fixedForAllDepartments,
      required this.name,
      this.department,
      this.controlOwnerList,
      required this.nameArabic});
}
