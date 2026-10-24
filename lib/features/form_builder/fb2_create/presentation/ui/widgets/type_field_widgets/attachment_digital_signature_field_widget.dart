/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: attachment_digital_signature_field_widget.dart
/// Description: `AttachmentDigitalSignatureFieldWidget` widget.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/utils/enum_dropdown_items.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Keep for .tr translations
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/actions_row_widget.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_textfield.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/ui/widgets/field_text_binder.dart';

/// Widget for creating an attachment digital signature field
///
/// Allows users to:
/// - Input a title for the attachment/signature field
/// - Manage form actions through ActionsRowWidget
class AttachmentDigitalSignatureFieldWidget extends StatelessWidget {
  /// Indices to track the widget's position in the form
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;

  const AttachmentDigitalSignatureFieldWidget({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const SizedBox.shrink();
        }

        // Retrieve specific controller for this attachment digital signature field
        final AttachmentDigitalSignatureFieldController controllers =
            state.pages[pageIndex].rows[rowIndex].controllers[columnIndex]
                as AttachmentDigitalSignatureFieldController;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input field with validation
            _buildTitleField(context, controllers),
            verticalSpace(15),

            // Alignment dropdown
            _buildAlignmentDropdown(context, controllers),

            verticalSpace(18),
            // Actions row for form management
            _buildActionRow(),
          ],
        );
      },
    );
  }

  /// Builds the title input field with validation
  Widget _buildTitleField(
    BuildContext context,
    AttachmentDigitalSignatureFieldController controllers,
  ) {
    return FieldTextBinder(
      text: controllers.title!,
      builder: (context, textController) => CustomTextField(
        readOnly: isReadOnly,
        height: 36,
        label: S.current.fbAddTitle,
        controller: textController,
        onChanged: (value) {
          // Trigger live update in A4 container
          context.read<CreateFormDataCubit>().updateFieldText(
            pageIndex: pageIndex,
            rowIndex: rowIndex,
            columnIndex: columnIndex,
          );
        },
      ),
    );
  }

  /// Builds the action row for additional options
  Widget _buildActionRow() {
    if (isReadOnly) return const SizedBox.shrink();
    return ActionsRowWidget(
      pageIndex: pageIndex,
      columnIndex: columnIndex,
      rowIndex: rowIndex,
    );
  }

  /// Builds the alignment dropdown
  Widget _buildAlignmentDropdown(
    BuildContext context,
    AttachmentDigitalSignatureFieldController controllers,
  ) {
    return DropDownWidget(
      onChanged: (value) {
        if (isReadOnly) return;
        context.read<CreateFormDataCubit>().changeAlignmentValue(
          pageIndex: pageIndex,
          value: value,
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
      },
      title: S.current.fbChooseAlignment,
      hint: S.current.fbChooseAlignment,
      items: EnumDropdownItems.alignment,
      currentValue: controllers.alignment,
    );
  }
}
