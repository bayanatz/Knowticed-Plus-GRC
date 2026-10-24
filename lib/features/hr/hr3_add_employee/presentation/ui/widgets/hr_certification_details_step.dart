// ***************************** FILE INFO ***************************** //
// File Name: hr_certification_details_step.dart
// Purpose: Renders optional certification details in the add-employee flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/layout/custom_grid_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/utils/add_employee_document_type.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/utils/add_employee_form_options.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/utils/enum_bulk_value.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/utils/add_employee_step.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/presentation/controller/add_employee_cubit.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/presentation/controller/add_employee_state.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/presentation/ui/widgets/hr_document_upload_field.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/presentation/ui/widgets/add_employee_date_field.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/presentation/ui/widgets/add_employee_dropdown.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/presentation/ui/widgets/add_employee_read_only_scope.dart';
import 'package:knowticed_plus/features/hr/hr3_add_employee/presentation/ui/widgets/add_employee_text_field.dart';
import 'package:knowticed_plus/features/hr/presentation/ui/widgets/dynamic_height_grid.dart';

/// Renders an optional certification form for a new employee.
class HrCertificationDetailsStep extends StatelessWidget {
  const HrCertificationDetailsStep({
    super.key,
    this.isReadOnly = false,
    this.useForm = true,
    this.scrollable = true,
  });

  final bool isReadOnly;
  final bool useForm;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddEmployeeCubit, AddEmployeeState>(
      builder: (context, _) {
        final localization = S.of(context);
        final cubit = context.read<AddEmployeeCubit>();
        final content = DynamicHeightGrid(
          widgets: [
            AddEmployeeTextField(
                controller: cubit.institutionNameController,
                label: localization.institutionName,
                hint: localization.textHere,
                isRequired: false),
            _optionDropdown(
                context,
                cubit.degreeController,
                localization.degreeOrCertification,
                AddEmployeeStandardOptions.degrees,
                (option) => option.title),
            _optionDropdown(
                context,
                cubit.fieldOfStudyController,
                localization.fieldOfStudy,
                AddEmployeeStandardOptions.fieldsOfStudy,
                (option) => option.title),
            AddEmployeeDateField(
              isRequired: false,
              value: DateTime.tryParse(
                  cubit.certificationStartDateController.text),
              label: localization.startDate,
              hint: localization.selectDate,
              onChanged: (date) => cubit.updateValue(
                  cubit.certificationStartDateController, _formatDate(date)),
            ),
            AddEmployeeDateField(
                value: DateTime.tryParse(
                    cubit.certificationEndDateController.text),
                label: localization.endDate,
                hint: localization.selectDate,
                onChanged: (date) => cubit.updateValue(
                    cubit.certificationEndDateController, _formatDate(date)),
                isRequired: false,
                validator: (date) => _validateEndDate(date,
                    cubit.certificationStartDateController.text, localization)),
            AddEmployeeTextField(
                controller: cubit.gradeOrScoreController,
                label: localization.gradeOrScore,
                hint: localization.textHere,
                isRequired: false),
            AddEmployeeTextField(
                controller: cubit.certificateIdController,
                label: localization.certificateId,
                hint: localization.textHere,
                isRequired: false),
            _optionDropdown(
                context,
                cubit.issuingAuthorityController,
                localization.issuingAuthority,
                AddEmployeeStandardOptions.issuingAuthorities,
                (option) => option.title),
          ],
          crossAxisCount: CrossAxisCountHelperResponsive
              .getCrossAxisCountForDefaultTabletResponsive(context),
          horizontalSpacing: 16.sp,
          verticalSpacing: 20.sp,
        );
        final certificationContent = Column(
          spacing: 20.sp,
          children: [
            content,
            _certificateUploadField(
              context,
              HrDocumentUploadField(
                  label: localization.upload,
                  file: cubit.certificationDocument,
                  isRequired: false,
                  onChanged: (file) => cubit.updateDocument(
                      AddEmployeeDocumentType.certification, file)),
            ),
            AddEmployeeTextField(
                controller: cubit.certificationNotesController,
                label: localization.notes,
                hint: localization.textHere,
                isRequired: false,
                maxLines: 4),
            Container(),
          ],
        );
        final formContent = useForm
            ? Form(
                key: cubit
                    .stepFormKeys[AddEmployeeStep.certificationDetails.index],
                child: certificationContent,
              )
            : certificationContent;
        return AddEmployeeReadOnlyScope(
          isReadOnly: isReadOnly,
          child: scrollable
              ? SingleChildScrollView(child: formContent)
              : formContent,
        );
      },
    );
  }

  /// Method Name: [_certificateUploadField]
  ///
  /// Purpose: Keeps the certificate document control full-width on mobile and
  /// aligned to half of a form row on larger views.
  ///
  /// Parameters:
  /// - [context]: Context used to determine the responsive breakpoint.
  /// - [child]: Certificate upload control to place in the form row.
  ///
  /// Returns: A responsive certificate upload layout.
  Widget _certificateUploadField(BuildContext context, Widget child) {
    final isMobile = kpIsPhoneLayout(context);
    if (isMobile) return child;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: child),
        SizedBox(width: 16.sp),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }

  Widget _optionDropdown<T extends Enum>(
    BuildContext context,
    TextEditingController controller,
    String label,
    List<T> options,
    String Function(T) title,
  ) {
    final localization = S.of(context);
    return AddEmployeeDropdown<String>(
        value: controller.text.isEmpty ? null : controller.text,
        items: options
            .map((option) =>
                DropdownItem(value: option.value, label: title(option)))
            .toList(),
        label: label,
        hint: localization.select,
        isRequired: false,
        onChanged: (value) =>
            context.read<AddEmployeeCubit>().updateValue(controller, value));
  }

  String? _validateEndDate(
      DateTime? endDate, String startDateValue, S localization) {
    if (endDate == null || startDateValue.isEmpty) return null;
    final startDate = DateTime.tryParse(startDateValue);
    return startDate != null && endDate.isBefore(startDate)
        ? localization.endDateBeforeStartDate
        : null;
  }

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;
}
