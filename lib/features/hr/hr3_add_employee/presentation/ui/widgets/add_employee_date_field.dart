// ***************************** FILE INFO ***************************** //
// File Name: add_employee_date_field.dart
// Purpose: Provides the AddEmployeeDateField widget for add-employee forms.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/pickers/custom_date_field.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/presentation/ui/widgets/add_employee_read_only_scope.dart';

/// A validated adapter for the shared [CustomDateField].
class AddEmployeeDateField extends StatelessWidget {
  const AddEmployeeDateField({
    super.key,
    required this.value,
    required this.label,
    required this.hint,
    required this.isRequired,
    required this.onChanged,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  final DateTime? value;
  final String label;
  final String hint;
  final ValueChanged<DateTime> onChanged;
  final FormFieldValidator<DateTime>? validator;
  final bool isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: value,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => CustomDateField(
        value: value,
        label: label,
        hint: hint,
        required: false,
        enabled: AddEmployeeReadOnlyScope.isEnabled(context),
        errorText: field.errorText,
        fillColor: AppColors.background,
        firstDate: firstDate,
        lastDate: lastDate,
        onChanged: (selected) {
          if (selected == null) return;
          field.didChange(selected);
          onChanged(selected);
        },
      ),
    );
  }
}
